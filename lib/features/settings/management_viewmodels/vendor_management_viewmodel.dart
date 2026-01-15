import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../../core/models/models.dart' as models;
import '../../../core/services/budget_service.dart';
import '../../../core/services/participant_service.dart';
import '../../../core/context.dart';
import '../../../core/data/database.dart' show VendorMatchHistory;

/// Manages vendor and vendor-account associations
/// Shows all vendor match history entries with ability to delete relationships
class VendorManagementViewModel extends ChangeNotifier {
  final BudgetService _budgetService;
  final ParticipantService _participantService;
  final AppContext _appContext;
  final Logger _logger = Logger("VendorManagementViewModel");

  VendorManagementViewModel(
    this._budgetService,
    this._participantService,
    this._appContext,
  );

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // ========== State Management ==========

  List<models.Vendor> _vendors = [];
  List<models.Vendor> get vendors => _vendors;

  Map<int, List<VendorMatchHistory>> _vendorMatchHistories = {};

  List<VendorAccountAssociation> _associations = [];
  List<VendorAccountAssociation> get associations => _associations;

  int? _selectedVendorId;
  int? get selectedVendorId => _selectedVendorId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ========== Current User Info ==========

  models.Participant? get currentUser => _appContext.currentParticipant;
  bool get isManager => currentUser?.role == models.Role.manager;

  // ========== Initialization ==========

  /// Load all vendors and their associations
  Future<void> initialize() async {
    await loadVendors();
    await loadAllAssociations();
  }

  /// Load all vendors from the database
  Future<void> loadVendors() async {
    _setLoading(true);
    try {
      _vendors = await _budgetService.transactionService.getAllVendors();
      _clearError();
      _logger.info('Loaded ${_vendors.length} vendors');
    } catch (e) {
      _logger.severe('Failed to load vendors', e);
      _setError('Failed to load vendors: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load all vendor-account associations across all vendors
  Future<void> loadAllAssociations() async {
    _setLoading(true);
    try {
      _associations = [];

      for (final vendor in _vendors) {
        final matchHistories = await _budgetService.transactionService
            .getVendorMatchHistory(vendor.vendorId);

        _vendorMatchHistories[vendor.vendorId] = matchHistories;

        // Convert each match history to an association
        for (final history in matchHistories) {
          final account = await _getAccountDetails(history.accountId);
          final participant = await _participantService.getParticipant(
            history.participantId,
          );

          if (account != null && participant != null) {
            _associations.add(VendorAccountAssociation(
              vendorMatchId: history.vendorMatchId,
              vendor: vendor,
              account: account,
              participant: participant,
              useCount: history.useCount,
              lastUsed: history.lastUsed,
            ));
          }
        }
      }

      // Sort by last used (most recent first)
      _associations.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));

      _clearError();
      _logger
          .info('Loaded ${_associations.length} vendor-account associations');
    } catch (e) {
      _logger.severe('Failed to load associations', e);
      _setError('Failed to load associations: $e');
      _associations = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Select a vendor to filter associations
  Future<void> selectVendor(int? vendorId) async {
    _selectedVendorId = vendorId;
    notifyListeners();
  }

  /// Get filtered associations based on selected vendor
  List<VendorAccountAssociation> get filteredAssociations {
    if (_selectedVendorId == null) {
      return _associations;
    }
    return _associations
        .where((a) => a.vendor.vendorId == _selectedVendorId)
        .toList();
  }

  // ========== Delete Association ==========

  /// Delete a specific vendor-account association
  /// This removes one relationship, not the vendor or account itself
  /// Returns true if successful
  Future<bool> deleteAssociation(VendorAccountAssociation association) async {
    _setLoading(true);
    try {
      final success =
          await _budgetService.transactionService.deleteVendorMatchHistory(
        vendorId: association.vendor.vendorId,
        accountId: association.account.accountId,
        participantId: association.participant.participantId,
      );

      if (success) {
        _logger.info(
          'Successfully deleted association: vendor=${association.vendor.vendorId}, '
          'account=${association.account.accountId}',
        );

        // Refresh associations
        await loadAllAssociations();
        _clearError();
        return true;
      } else {
        _setError('Failed to delete association');
        return false;
      }
    } catch (e) {
      _logger.severe('Error deleting association', e);
      _setError('Error deleting association: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete all associations for a specific vendor
  /// Returns the number of associations deleted
  Future<int> deleteAllAssociationsForVendor(int vendorId) async {
    _setLoading(true);
    int deletedCount = 0;

    try {
      final vendorAssociations =
          _associations.where((a) => a.vendor.vendorId == vendorId).toList();

      for (final association in vendorAssociations) {
        final success =
            await _budgetService.transactionService.deleteVendorMatchHistory(
          vendorId: association.vendor.vendorId,
          accountId: association.account.accountId,
          participantId: association.participant.participantId,
        );

        if (success) {
          deletedCount++;
        }
      }

      _logger.info('Deleted $deletedCount associations for vendor $vendorId');

      // Refresh associations
      await loadAllAssociations();
      _clearError();

      return deletedCount;
    } catch (e) {
      _logger.severe('Error deleting vendor associations', e);
      _setError('Error deleting associations: $e');
      return deletedCount;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Helper Methods ==========

  void _setLoading(bool loading) {
    if (!_isDisposed) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (!_isDisposed) {
      _error = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (!_isDisposed) {
      _error = null;
      notifyListeners();
    }
  }

  /// Get account details by ID
  Future<models.Account?> _getAccountDetails(int accountId) async {
    try {
      // Get all templates to find the account
      final templates = await _budgetService.templateService.getAllTemplates();

      for (final template in templates) {
        final accounts = await _budgetService.accountService
            .getAllAccountsForTemplate(template.templateId);

        final account =
            accounts.where((a) => a.accountId == accountId).firstOrNull;
        if (account != null) {
          return account;
        }
      }

      return null;
    } catch (e) {
      _logger.severe('Error getting account details', e);
      return null;
    }
  }

  /// Get association count for a vendor
  int getAssociationCount(int vendorId) {
    return _associations.where((a) => a.vendor.vendorId == vendorId).length;
  }

  /// Get total use count for a vendor across all associations
  int getTotalUseCount(int vendorId) {
    return _associations
        .where((a) => a.vendor.vendorId == vendorId)
        .fold(0, (sum, a) => sum + a.useCount);
  }

  /// Get most recent use date for a vendor
  DateTime? getMostRecentUse(int vendorId) {
    final vendorAssociations =
        _associations.where((a) => a.vendor.vendorId == vendorId).toList();

    if (vendorAssociations.isEmpty) return null;

    vendorAssociations.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return vendorAssociations.first.lastUsed;
  }

  /// Search/filter vendors by name
  List<models.Vendor> searchVendors(String query) {
    if (query.isEmpty) return _vendors;

    final lowerQuery = query.toLowerCase();
    return _vendors.where((v) {
      return v.vendorName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Search/filter associations by vendor or account name
  List<VendorAccountAssociation> searchAssociations(String query) {
    if (query.isEmpty) return filteredAssociations;

    final lowerQuery = query.toLowerCase();
    return filteredAssociations.where((a) {
      return a.vendor.vendorName.toLowerCase().contains(lowerQuery) ||
          a.account.accountName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Data class representing a vendor-account association with full details
class VendorAccountAssociation {
  final int vendorMatchId;
  final models.Vendor vendor;
  final models.Account account;
  final models.Participant participant;
  final int useCount;
  final DateTime lastUsed;

  VendorAccountAssociation({
    required this.vendorMatchId,
    required this.vendor,
    required this.account,
    required this.participant,
    required this.useCount,
    required this.lastUsed,
  });
}
