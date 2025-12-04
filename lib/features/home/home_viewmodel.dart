// lib/features/home/home_viewmodel.dart

import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/core/models/client_models.dart' as client_models;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:logging/logging.dart';
import '../../core/context.dart';
import '../../core/models/client_models.dart';
import '../../core/models/models.dart' as models;
import '../../core/services/document_service.dart';
import '../../core/services/participant_service.dart';
import '../../core/services/budget_service.dart';
import '../../core/utils/fuzzy_search.dart';
import '../../core/services/transaction_service.dart';

class HomeViewModel extends ChangeNotifier {
  final DocumentService _documentService;
  final ParticipantService _participantService;
  final BudgetService _budgetService;
  final AppContext _appContext;
  final Logger _logger = Logger('HomeViewModel');

  // State
  List<UploadedDocument> _uploadedDocuments = [];
  List<ParsedTransaction> _extractedTransactions = [];
  List<models.Participant> _participants = [];
  List<models.Template> _templateHistory = [];
  bool _isLoading = false;
  bool _hasRunAudit = false;
  String? _errorMessage;

  HomeViewModel({
    required DocumentService documentService,
    required ParticipantService participantService,
    required BudgetService budgetService,
    required AppContext appContext,
  })  : _documentService = documentService,
        _participantService = participantService,
        _budgetService = budgetService,
        _appContext = appContext {
    _initialize();
  }

  // Getters
  List<UploadedDocument> get uploadedDocuments => _uploadedDocuments;
  List<ParsedTransaction> get extractedTransactions => _extractedTransactions;
  List<models.Participant> get participants => _participants;
  List<models.Template> get templateHistory => _templateHistory;
  bool get isLoading => _isLoading;
  bool get hasRunAudit => _hasRunAudit;
  String? get errorMessage => _errorMessage;
  bool get hasDocuments => _uploadedDocuments.isNotEmpty;
  bool get hasTransactions => _extractedTransactions.isNotEmpty;

  int? get currentParticipantId =>
      _appContext.currentParticipant?.participantId;

  models.Template? get currentTemplate => _appContext.currentTemplate;
  bool get hasActiveTemplate => _appContext.currentTemplate != null;

  Future<void> _initialize() async {
    await loadParticipants();
    await loadTemplateHistory();
  }

  /// Gets recommended accounts for a vendor based on history
  Future<List<client_models.AccountData>> getVendorRecommendations(
      int vendorId) async {
    try {
      final history = await _budgetService.transactionService
          .getVendorMatchHistory(vendorId);

      if (history.isEmpty) return [];

      // Get unique account IDs from history, sorted by lastUsed desc
      final accountIds = <int>[];
      for (final entry in history) {
        if (!accountIds.contains(entry.accountId)) {
          accountIds.add(entry.accountId);
        }
      }

      // Fetch account details
      final recommendations = <client_models.AccountData>[];
      if (_appContext.currentTemplate != null) {
        final allAccounts = await _budgetService.accountService
            .getAllAccountsForTemplate(_appContext.currentTemplate!.templateId);

        for (final accountId in accountIds) {
          final account =
              allAccounts.where((a) => a.accountId == accountId).firstOrNull;

          if (account != null) {
            recommendations.add(client_models.AccountData(
              id: account.accountId.toString(),
              name: account.accountName,
              budgetAmount: account.budgetAmount,
              color: Color(int.parse(account.colorHex.substring(1), radix: 16) +
                  0xFF000000),
              participants: _participants
                  .where((p) =>
                      p.participantId == account.responsibleParticipantId)
                  .toList(),
            ));
          }
        }
      }

      return recommendations;
    } catch (e, st) {
      _logger.severe('Error getting vendor recommendations', e, st);
      return [];
    }
  }

  /// Deletes a vendor recommendation (removes from VendorMatchHistory)
  Future<void> deleteVendorRecommendation(int vendorId, int accountId) async {
    if (currentParticipantId == null) return;

    try {
      await _budgetService.transactionService.deleteVendorMatchHistory(
        vendorId: vendorId,
        accountId: accountId,
        participantId: currentParticipantId!,
      );
      _logger.info(
          'Deleted vendor recommendation: vendor=$vendorId, account=$accountId');

      // Refresh recommendations for affected transactions
      await matchTransactions();
    } catch (e, st) {
      _logger.severe('Error deleting vendor recommendation', e, st);
    }
  }

  /// Loads all participants from the database
  Future<void> loadParticipants() async {
    try {
      _participants = await _participantService.getAllParticipants();
      notifyListeners();
    } catch (e, st) {
      _logger.severe('Error loading participants', e, st);
    }
  }

  /// Loads template history for the current user
  Future<void> loadTemplateHistory() async {
    try {
      _templateHistory = await _budgetService.templateService.getAllTemplates();
      notifyListeners();
    } catch (e, st) {
      _logger.severe('Error loading template history', e, st);
    }
  }

  /// Refreshes history data (participants and templates) without clearing document state
  Future<void> refreshHistory() async {
    await loadParticipants();
    await loadTemplateHistory();
  }

  /// Adds a document to the upload queue
  Future<bool> addDocument({
    required String fileName,
    required String filePath,
    String? password,
    required int ownerParticipantId,
    required FinancialInstitution institution,
  }) async {
    try {
      _errorMessage = null;

      // Validate PDF
      if (!_documentService.isValidPdf(filePath)) {
        _errorMessage = 'Invalid PDF file. Please select a valid PDF document.';
        notifyListeners();
        return false;
      }

      // Create document
      final document = _documentService.createUploadedDocument(
        fileName: fileName,
        filePath: filePath,
        password: password,
        ownerParticipantId: ownerParticipantId,
        institution: institution,
      );

      // Validate document can be parsed
      _isLoading = true;
      notifyListeners();

      final validationResult =
          await _documentService.validateDocument(document);

      _isLoading = false;

      if (!validationResult.canParse) {
        _errorMessage = validationResult.errorMessage ??
            'Document could not be understood. Please check:\n'
                '${validationResult.missingCheckpoints.join('\n')}';
        notifyListeners();
        return false;
      }

      // Add to list
      _uploadedDocuments.add(document);
      _logger.info('Document added: $fileName');
      notifyListeners();
      return true;
    } catch (e, st) {
      _logger.severe('Error adding document', e, st);
      _errorMessage = 'Failed to add document: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Removes a document from the upload queue
  void removeDocument(String documentId) {
    final document = _uploadedDocuments.firstWhere(
      (doc) => doc.id == documentId,
      orElse: () => throw Exception('Document not found'),
    );

    _uploadedDocuments.removeWhere((doc) => doc.id == documentId);
    _documentService.cleanupDocument(document);
    _logger.info('Document removed: ${document.fileName}');
    notifyListeners();
  }

  /// Runs audit on all uploaded documents
  Future<void> runAudit() async {
    if (_uploadedDocuments.isEmpty) {
      _errorMessage =
          'Please upload at least one document before running audit.';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      _extractedTransactions.clear();
      notifyListeners();

      // Parse each document
      for (final document in _uploadedDocuments) {
        final parseResult = await _documentService.parseDocument(document);

        if (parseResult.success) {
          _extractedTransactions.addAll(parseResult.transactions);
        } else {
          _logger.warning(
            'Failed to parse ${document.fileName}: ${parseResult.errorMessage}',
          );
        }
      }

      _hasRunAudit = true;
      _isLoading = false;
      _logger.info(
          'Audit completed. Found ${_extractedTransactions.length} transactions.');

      // Run matching logic
      await matchTransactions();

      notifyListeners();
    } catch (e, st) {
      _logger.severe('Error running audit', e, st);
      _errorMessage = 'Failed to run audit: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Matches transactions to vendors and accounts
  Future<void> matchTransactions() async {
    if (_appContext.currentTemplate == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final vendors = await _budgetService.transactionService.getAllVendors();
      final vendorNames = vendors.map((v) => v.vendorName).toList();

      // Fetch all accounts for the current template to map IDs to names/colors
      final accounts = await _budgetService.accountService
          .getAllAccountsForTemplate(_appContext.currentTemplate!.templateId);
      final accountMap = {for (var a in accounts) a.accountId: a};

      final updatedTransactions = <ParsedTransaction>[];

      for (final transaction in _extractedTransactions) {
        var matchStatus = MatchStatus.critical;
        List<String> potentialMatches = [];
        client_models.AccountData? suggestedAccount;
        String finalVendorName = transaction.vendorName;
        int? vendorId;

        // Store original status on first match
        final originalStatus =
            transaction.originalStatus ?? transaction.matchStatus;

        // 1. Exact Match
        final exactMatch = vendors
            .where((v) =>
                v.vendorName.toLowerCase() ==
                transaction.vendorName.toLowerCase())
            .firstOrNull;

        if (exactMatch != null) {
          vendorId = exactMatch.vendorId;
          finalVendorName = exactMatch.vendorName;

          // Check history
          final history = await _budgetService.transactionService
              .getVendorMatchHistory(exactMatch.vendorId);

          if (history.isNotEmpty) {
            final bestMatch = history.first;

            // Check if ambiguous (multiple accounts used)
            final distinctAccounts = history.map((h) => h.accountId).toSet();

            if (distinctAccounts.length > 1) {
              matchStatus = MatchStatus.ambiguous;
            } else {
              matchStatus = MatchStatus.confident;
            }

            final account = accountMap[bestMatch.accountId];
            if (account != null) {
              suggestedAccount = client_models.AccountData(
                id: account.accountId.toString(),
                name: account.accountName,
                budgetAmount: account.budgetAmount,
                color: Color(
                    int.parse(account.colorHex.substring(1), radix: 16) +
                        0xFF000000),
              );
            }
          } else {
            matchStatus = MatchStatus.critical;
          }
        } else {
          // 2. Fuzzy Match
          potentialMatches =
              FuzzySearch.findSimilar(transaction.vendorName, vendorNames);
          if (potentialMatches.isNotEmpty) {
            matchStatus = MatchStatus.potential;
          }
        }

        updatedTransactions.add(transaction.copyWith(
          vendorName: finalVendorName,
          matchStatus: matchStatus,
          potentialMatches: potentialMatches,
          suggestedAccount: suggestedAccount,
          account: suggestedAccount?.name,
          vendorId: vendorId,
          originalStatus: originalStatus, // Preserve original status
          // Keep existing modification flags
          userModified: transaction.userModified,
          autoUpdated: transaction.autoUpdated,
        ));
      }

      _extractedTransactions = updatedTransactions;
    } catch (e, st) {
      _logger.severe('Error matching transactions', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Splits a transaction into two
  void splitTransaction(
      String originalTransactionId, double splitAmount, String newAccountName) {
    final index =
        _extractedTransactions.indexWhere((t) => t.id == originalTransactionId);
    if (index == -1) {
      _logger
          .warning('Transaction not found for split: $originalTransactionId');
      return;
    }

    final original = _extractedTransactions[index];
    final originalAmount = original.amount.abs();

    if (splitAmount <= 0 || splitAmount >= originalAmount) {
      _logger.warning(
          'Invalid split amount: $splitAmount for total $originalAmount');
      return;
    }

    final remainingAmount = originalAmount - splitAmount;
    final isNegative = original.amount < 0;

    // 1. Update original transaction (Remaining amount)
    final updatedOriginal = original.copyWith(
      amount: isNegative ? -remainingAmount : remainingAmount,
      userModified: true, // Mark as modified since user initiated the split
    );

    // 2. Create new transaction (Split part) - inherits original properties
    final splitId =
        '${original.id}_split_${DateTime.now().millisecondsSinceEpoch}';

    // Find the account data for the new account
    client_models.AccountData? splitAccount;
    // This would need to be passed or looked up - for now we'll create a minimal version

    final newTransaction = original.copyWith(
      id: splitId,
      amount: isNegative ? -splitAmount : splitAmount,
      account: newAccountName,
      suggestedAccount: splitAccount, // Would need proper account lookup
      matchStatus: MatchStatus.critical, // Needs review
      userModified: true,
      autoUpdated: false,
      originalStatus: original.originalStatus ??
          original.matchStatus, // Inherit original status
    );

    // Replace original and insert new transaction immediately after it
    _extractedTransactions[index] = updatedOriginal;
    _extractedTransactions.insert(index + 1, newTransaction);

    _logger.info(
        'Transaction split: $originalTransactionId -> $splitAmount to $newAccountName');
    notifyListeners();
  }

  /// Updates a parsed transaction with auto-update propagation
  void updateTransaction(ParsedTransaction updatedTransaction) {
    final index = _extractedTransactions.indexWhere(
      (t) => t.id == updatedTransaction.id,
    );

    if (index == -1) return;

    // Store the update
    _extractedTransactions[index] = updatedTransaction;

    // AUTO-UPDATE LOGIC: If user manually selected an account for a vendor,
    // update all other transactions with the same vendor that haven't been modified
    if (updatedTransaction.userModified &&
        updatedTransaction.vendorId != null &&
        updatedTransaction.suggestedAccount != null) {
      _logger.info('Propagating vendor-account association: '
          'vendor=${updatedTransaction.vendorId}, '
          'account=${updatedTransaction.suggestedAccount!.name}');

      // Find all transactions with the same vendor that haven't been manually updated
      for (int i = 0; i < _extractedTransactions.length; i++) {
        if (i == index) continue; // Skip the current transaction

        final txn = _extractedTransactions[i];

        // Only auto-update if:
        // 1. Same vendor
        // 2. User hasn't manually modified this transaction yet
        // 3. Not already auto-updated to this account
        if (txn.vendorId == updatedTransaction.vendorId &&
            !txn.userModified &&
            txn.suggestedAccount?.id !=
                updatedTransaction.suggestedAccount!.id) {
          _extractedTransactions[i] = txn.copyWith(
            account: updatedTransaction.suggestedAccount!.name,
            suggestedAccount: updatedTransaction.suggestedAccount,
            matchStatus: MatchStatus.confident,
            autoUpdated: true, // Mark as auto-updated
            userModified: false, // Explicitly not user-modified
          );

          _logger.fine(
              'Auto-updated transaction ${txn.id} to account ${updatedTransaction.suggestedAccount!.name}');
        }
      }
    }

    notifyListeners();
  }

  /// Toggles the "Use Memory" checkbox for a transaction
  void toggleUseMemory(String transactionId) {
    final index =
        _extractedTransactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = _extractedTransactions[index];
      _extractedTransactions[index] = transaction.copyWith(
        useMemory: !transaction.useMemory,
        userModified: true,
      );
      notifyListeners();
    }
  }

  /// Refreshes the extracted transactions (re-parses documents)
  Future<void> refreshTransactions() async {
    await runAudit();
  }

  /// Clears all extracted transactions
  void clearTransactions() {
    _extractedTransactions.clear();
    _hasRunAudit = false;
    notifyListeners();
  }

  /// Clears all documents and resets state
  void reset() {
    for (final doc in _uploadedDocuments) {
      _documentService.cleanupDocument(doc);
    }
    _uploadedDocuments.clear();
    _extractedTransactions.clear();
    _hasRunAudit = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Deletes a template from history
  Future<void> deleteTemplate(int templateId) async {
    try {
      final success =
          await _budgetService.templateService.deleteTemplate(templateId);
      if (success) {
        _templateHistory.removeWhere((t) => t.templateId == templateId);
        _logger.info('Template deleted: $templateId');
        notifyListeners();
      }
    } catch (e, st) {
      _logger.severe('Error deleting template', e, st);
      _errorMessage = 'Failed to delete template: $e';
      notifyListeners();
    }
  }

  /// Fetches full details (categories and accounts) for a specific template
  Future<List<client_models.CategoryData>> getTemplateDetails(
      int templateId) async {
    try {
      final categories = await _budgetService.categoryService
          .getCategoriesForTemplate(templateId);

      final accounts = await _budgetService.accountService
          .getAllAccountsForTemplate(templateId);

      return categories.map((category) {
        final categoryAccounts = accounts
            .where((a) => a.categoryId == category.categoryId)
            .map((a) => client_models.AccountData(
                  id: a.accountId.toString(),
                  name: a.accountName,
                  budgetAmount: a.budgetAmount,
                  color: a.color,
                  participants: _participants
                      .where(
                          (p) => p.participantId == a.responsibleParticipantId)
                      .toList(),
                ))
            .toList();

        return client_models.CategoryData(
          id: category.categoryId.toString(),
          name: category.categoryName,
          color: category.color,
          accounts: categoryAccounts,
        );
      }).toList();
    } catch (e, st) {
      _logger.severe('Error fetching template details for $templateId', e, st);
      return [];
    }
  }

  @override
  void dispose() {
    for (final doc in _uploadedDocuments) {
      _documentService.cleanupDocument(doc);
    }
    super.dispose();
  }
}
