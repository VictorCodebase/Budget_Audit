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

/// Groups transactions by their source document
class DocumentTransactionGroup {
  final UploadedDocument document;
  final List<ParsedTransaction> transactions;
  bool isComplete;

  DocumentTransactionGroup({
    required this.document,
    required this.transactions,
    this.isComplete = false,
  });

  /// Check if all transactions have been assigned accounts
  bool get hasAllAccountsAssigned {
    return transactions.isNotEmpty &&
        transactions.every((txn) =>
            txn.suggestedAccount != null &&
            (txn.userModified || txn.autoUpdated));
  }

  /// Count of unassigned transactions
  int get unassignedCount {
    return transactions
        .where((txn) =>
            txn.suggestedAccount == null ||
            (!txn.userModified && !txn.autoUpdated))
        .length;
  }
}

class HomeViewModel extends ChangeNotifier {
  final DocumentService _documentService;
  final ParticipantService _participantService;
  final BudgetService _budgetService;
  final AppContext _appContext;
  final Logger _logger = Logger('HomeViewModel');

  // State
  List<UploadedDocument> _uploadedDocuments = [];
  Map<String, List<ParsedTransaction>> _transactionsByDocument = {};
  List<models.Participant> _participants = [];
  List<models.Template> _templateHistory = [];
  bool _isLoading = false;
  bool _hasRunAudit = false;
  String? _errorMessage;
  int _currentDocumentIndex = 0;
  Set<String> _completedDocumentIds = {};
  bool _autoUpdateVendorAssociations = true; // Toggle for vendor auto-update
  bool _auditCompletedSuccessfully = false;

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
  List<models.Participant> get participants => _participants;
  List<models.Template> get templateHistory => _templateHistory;
  bool get isLoading => _isLoading;
  bool get hasRunAudit => _hasRunAudit;
  String? get errorMessage => _errorMessage;
  bool get hasDocuments => _uploadedDocuments.isNotEmpty;
  int get currentDocumentIndex => _currentDocumentIndex;
  int get totalDocuments => _uploadedDocuments.length;
  bool get autoUpdateVendorAssociations => _autoUpdateVendorAssociations;
  bool get auditCompletedSuccessfully => _auditCompletedSuccessfully;

  /// Get all document groups with auto-computed completion status
  List<DocumentTransactionGroup> get documentGroups {
    return _uploadedDocuments.map((doc) {
      final transactions = _transactionsByDocument[doc.id] ?? [];
      final group = DocumentTransactionGroup(
        document: doc,
        transactions: transactions,
        isComplete: _completedDocumentIds.contains(doc.id),
      );

      // Auto-mark as complete if all accounts assigned
      if (group.hasAllAccountsAssigned && !group.isComplete) {
        _completedDocumentIds.add(doc.id);
        group.isComplete = true;
      }

      return group;
    }).toList();
  }

  /// Get current document group
  DocumentTransactionGroup? get currentDocumentGroup {
    if (_uploadedDocuments.isEmpty ||
        _currentDocumentIndex >= _uploadedDocuments.length) {
      return null;
    }
    final groups = documentGroups;
    return groups.isNotEmpty && _currentDocumentIndex < groups.length
        ? groups[_currentDocumentIndex]
        : null;
  }

  /// Get transactions for current document
  List<ParsedTransaction> get currentDocumentTransactions {
    return currentDocumentGroup?.transactions ?? [];
  }

  /// Check if current document is complete
  bool get isCurrentDocumentComplete {
    return currentDocumentGroup?.hasAllAccountsAssigned ?? false;
  }

  /// Check if all documents are complete
  bool get areAllDocumentsComplete {
    return documentGroups.every((group) => group.hasAllAccountsAssigned);
  }

  /// Check if can proceed to next document
  bool get canProceedToNext {
    return isCurrentDocumentComplete &&
        _currentDocumentIndex < _uploadedDocuments.length - 1;
  }

  /// Check if can go to previous document
  bool get canGoToPrevious {
    return _currentDocumentIndex > 0;
  }

  int? get currentParticipantId =>
      _appContext.currentParticipant?.participantId;
  models.Template? get currentTemplate => _appContext.currentTemplate;
  bool get hasActiveTemplate => _appContext.currentTemplate != null;

  Future<void> _initialize() async {
    await loadParticipants();
    await loadTemplateHistory();
  }

  /// Toggle vendor auto-update feature
  void toggleAutoUpdateVendorAssociations() {
    _autoUpdateVendorAssociations = !_autoUpdateVendorAssociations;
    _logger.info(
        'Vendor auto-update ${_autoUpdateVendorAssociations ? "enabled" : "disabled"}');
    notifyListeners();
  }

  /// Navigate to next document
  void goToNextDocument() {
    if (!canProceedToNext) {
      _errorMessage =
          'Please complete all transactions for this document before proceeding.';
      notifyListeners();
      return;
    }

    // Mark current document as complete
    if (currentDocumentGroup != null) {
      _completedDocumentIds.add(currentDocumentGroup!.document.id);
    }

    _currentDocumentIndex++;
    _errorMessage = null;
    notifyListeners();
  }

  /// Navigate to previous document
  void goToPreviousDocument() {
    if (canGoToPrevious) {
      _currentDocumentIndex--;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Jump to specific document
  void goToDocument(int index) {
    if (index >= 0 && index < _uploadedDocuments.length) {
      _currentDocumentIndex = index;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Mark current document as complete (called when user manually confirms)
  void markCurrentDocumentComplete() {
    if (currentDocumentGroup != null && isCurrentDocumentComplete) {
      _completedDocumentIds.add(currentDocumentGroup!.document.id);
      notifyListeners();
    }
  }

  /// Complete entire audit - save all transactions to database
  Future<bool> completeAudit() async {
    if (!areAllDocumentsComplete) {
      _errorMessage =
          'Please complete all documents before finishing the audit.';
      notifyListeners();
      return false;
    }

    if (currentParticipantId == null || currentTemplate == null) {
      _errorMessage = 'Please select a participant and template.';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get or create sync log for this batch
      final syncId =
          await _budgetService.transactionService.getOrCreateSyncLog();
      int savedCount = 0;

      // Process each document group
      for (final group in documentGroups) {
        for (final transaction in group.transactions) {
          // Skip transactions without accounts
          if (transaction.suggestedAccount == null) continue;

          // Get or create vendor
          int vendorId = transaction.vendorId ??
              await _getOrCreateVendor(transaction.vendorName);

          // Parse account ID
          final accountId = int.tryParse(transaction.suggestedAccount!.id);
          if (accountId == null) {
            _logger.warning(
                'Invalid account ID: ${transaction.suggestedAccount!.id}');
            continue;
          }

          // Save transaction to database
          await _budgetService.transactionService.createTransaction(
            syncId: syncId,
            accountId: accountId,
            vendorId: vendorId,
            amount: transaction.amount,
            date: transaction.date,
            participantId: group.document.ownerParticipantId,
            editorParticipantId: currentParticipantId!,
          );

          // Record vendor match history if user wants to remember
          if (transaction.useMemory) {
            await _budgetService.transactionService.recordVendorMatch(
              vendorId: vendorId,
              accountId: accountId,
              participantId: currentParticipantId!,
            );
          }

          savedCount++;
        }
      }

      _logger.info(
          'Audit completed successfully. Saved $savedCount transactions.');

      _isLoading = false;
      _auditCompletedSuccessfully = true;
      notifyListeners();
      return true;
    } catch (e, st) {
      _logger.severe('Error completing audit', e, st);
      _errorMessage = 'Failed to save transactions: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Helper: Get or create vendor
  Future<int> _getOrCreateVendor(String vendorName) async {
    final vendors = await _budgetService.transactionService.getAllVendors();
    final existing = vendors.firstWhere(
      (v) => v.vendorName.toLowerCase() == vendorName.toLowerCase(),
      orElse: () => models.Vendor(vendorId: -1, vendorName: ''),
    );

    if (existing.vendorId != -1) {
      return existing.vendorId;
    }

    final newVendorId =
        await _budgetService.transactionService.createVendor(vendorName);
    return newVendorId ?? -1;
  }

  /// Gets recommended accounts for a vendor based on history
  Future<List<client_models.AccountData>> getVendorRecommendations(
      int vendorId) async {
    try {
      final history = await _budgetService.transactionService
          .getVendorMatchHistory(vendorId);
      if (history.isEmpty) return [];

      final accountIds = <int>[];
      for (final entry in history) {
        if (!accountIds.contains(entry.accountId)) {
          accountIds.add(entry.accountId);
        }
      }

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

  /// Deletes a vendor recommendation
  Future<void> deleteVendorRecommendation(int vendorId, int accountId) async {
    if (currentParticipantId == null) return;

    try {
      await _budgetService.transactionService.deleteVendorMatchHistory(
        vendorId: vendorId,
        accountId: accountId,
        participantId: currentParticipantId!,
      );
      await matchTransactions();
    } catch (e, st) {
      _logger.severe('Error deleting vendor recommendation', e, st);
    }
  }

  Future<void> loadParticipants() async {
    try {
      _participants = await _participantService.getAllParticipants();
      notifyListeners();
    } catch (e, st) {
      _logger.severe('Error loading participants', e, st);
    }
  }

  Future<void> loadTemplateHistory() async {
    try {
      _templateHistory = await _budgetService.templateService.getAllTemplates();
      notifyListeners();
    } catch (e, st) {
      _logger.severe('Error loading template history', e, st);
    }
  }

  Future<double> getTemplateTotalBudget(int templateId) async {
    return await _budgetService.accountService
        .getTemplateTotalBudget(templateId);
  }

  Future<void> refreshHistory() async {
    await loadParticipants();
    await loadTemplateHistory();
  }

  Future<ValidationResult> addDocument({
    required String fileName,
    required String filePath,
    String? password,
    required int ownerParticipantId,
    required FinancialInstitution institution,
  }) async {
    try {
      _errorMessage = null;

      if (!_documentService.isValidPdf(filePath)) {
        const error = 'Invalid PDF file. Please select a valid PDF document.';
        _errorMessage = error;
        notifyListeners();
        return const ValidationResult.failure(
            error: error, type: ValidationErrorType.invalidFormat);
      }

      final document = _documentService.createUploadedDocument(
        fileName: fileName,
        filePath: filePath,
        password: password,
        ownerParticipantId: ownerParticipantId,
        institution: institution,
      );

      _isLoading = true;
      notifyListeners();

      final validationResult =
          await _documentService.validateDocument(document);
      _isLoading = false;

      if (!validationResult.canParse) {
        // Only set generic error message if it's not a specific handled type
        // This allows the UI to show custom popups for specific types
        if (validationResult.type == ValidationErrorType.unknown ||
            validationResult.type == ValidationErrorType.none) {
          _errorMessage = validationResult.errorMessage ??
              'Document could not be understood. Please check:\n${validationResult.missingCheckpoints.join('\n')}';
        }
        notifyListeners();
        return validationResult;
      }

      _uploadedDocuments.add(document);
      _logger.info('Document added: $fileName');
      notifyListeners();
      return validationResult;
    } catch (e, st) {
      _logger.severe('Error adding document', e, st);
      final error = 'Failed to add document: $e';
      _errorMessage = error;
      _isLoading = false;
      notifyListeners();
      return ValidationResult.failure(error: error);
    }
  }

  void removeDocument(String documentId) {
    final document = _uploadedDocuments.firstWhere(
      (doc) => doc.id == documentId,
      orElse: () => throw Exception('Document not found'),
    );

    _uploadedDocuments.removeWhere((doc) => doc.id == documentId);
    _transactionsByDocument.remove(documentId);
    _completedDocumentIds.remove(documentId);
    // _documentService.cleanupDocument(document); // Commented to prevent deletion of user files

    // Adjust current index if needed
    if (_currentDocumentIndex >= _uploadedDocuments.length &&
        _currentDocumentIndex > 0) {
      _currentDocumentIndex--;
    }

    _logger.info('Document removed: ${document.fileName}');
    notifyListeners();
  }

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
      notifyListeners();

      // CRITICAL: Only parse NEW documents - preserve existing work
      final existingDocIds = _transactionsByDocument.keys.toSet();
      final newDocuments = _uploadedDocuments
          .where((doc) => !existingDocIds.contains(doc.id))
          .toList();

      if (newDocuments.isEmpty && existingDocIds.isNotEmpty) {
        _logger.info('No new documents to parse. Existing work preserved.');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Parse only new documents
      for (final document in newDocuments) {
        final parseResult = await _documentService.parseDocument(document);

        if (parseResult.success) {
          _transactionsByDocument[document.id] = parseResult.transactions;
          _logger.info(
              'Parsed new document: ${document.fileName} (${parseResult.transactions.length} transactions)');
        } else {
          _logger.warning(
              'Failed to parse ${document.fileName}: ${parseResult.errorMessage}');
          _transactionsByDocument[document.id] = [];
        }
      }

      _hasRunAudit = true;
      _isLoading = false;

      final totalTransactions = _transactionsByDocument.values
          .fold(0, (sum, list) => sum + list.length);
      _logger.info(
          'Audit completed. Total: $totalTransactions transactions across ${_uploadedDocuments.length} documents.');

      // Run matching for newly parsed documents
      if (newDocuments.isNotEmpty) {
        // Match transactions for new documents only
        for (final doc in newDocuments) {
          final originalIndex = _currentDocumentIndex;
          _currentDocumentIndex =
              _uploadedDocuments.indexWhere((d) => d.id == doc.id);
          if (_currentDocumentIndex != -1) {
            await matchTransactions();
          }
          _currentDocumentIndex = originalIndex;
        }
      }

      notifyListeners();
    } catch (e, st) {
      _logger.severe('Error running audit', e, st);
      _errorMessage = 'Failed to run audit: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> matchTransactions() async {
    if (_appContext.currentTemplate == null || currentDocumentGroup == null)
      return;

    _isLoading = true;
    notifyListeners();

    try {
      final vendors = await _budgetService.transactionService.getAllVendors();
      final vendorNames = vendors.map((v) => v.vendorName).toList();
      final accounts = await _budgetService.accountService
          .getAllAccountsForTemplate(_appContext.currentTemplate!.templateId);
      final accountMap = {for (var a in accounts) a.accountId: a};

      final documentId = currentDocumentGroup!.document.id;
      final transactions = _transactionsByDocument[documentId] ?? [];
      final updatedTransactions = <ParsedTransaction>[];

      for (final transaction in transactions) {
        var matchStatus = MatchStatus.critical;
        bool markAsAutoUpdated = false;
        List<String> potentialMatches = [];
        client_models.AccountData? suggestedAccount;
        String finalVendorName = transaction.vendorName;
        int? vendorId;

        // Exact match
        final exactMatch = vendors
            .where((v) =>
                v.vendorName.toLowerCase() ==
                transaction.vendorName.toLowerCase())
            .firstOrNull;

        if (exactMatch != null) {
          vendorId = exactMatch.vendorId;
          finalVendorName = exactMatch.vendorName;
          markAsAutoUpdated = true;
          // debugPrint('Exact match found: ${exactMatch.vendorName}');

          final history = await _budgetService.transactionService
              .getVendorMatchHistory(exactMatch.vendorId);

          if (history.isNotEmpty) {
            final bestMatch = history.first;
            final distinctAccounts = history.map((h) => h.accountId).toSet();

            matchStatus = distinctAccounts.length > 1
                ? MatchStatus.ambiguous
                : MatchStatus.confident;

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
            matchStatus = MatchStatus.critical; //*
          }
        } else {
          // Fuzzy match
          potentialMatches =
              FuzzySearch.findSimilar(transaction.vendorName, vendorNames);
          if (potentialMatches.isNotEmpty) {
            matchStatus = MatchStatus.potential;
            markAsAutoUpdated = true;

            final bestFuzzyMatch = vendors
                .where((v) => v.vendorName == potentialMatches.first)
                .firstOrNull;

            if (bestFuzzyMatch != null) {
              matchStatus = MatchStatus.potential;

              final bestFuzzyMatch = vendors
                  .where((v) => v.vendorName == potentialMatches.first)
                  .firstOrNull;

              if (bestFuzzyMatch != null) {
                vendorId = bestFuzzyMatch.vendorId;

                final history = await _budgetService.transactionService
                    .getVendorMatchHistory(bestFuzzyMatch.vendorId);

                if (history.isNotEmpty) {
                  final bestMatch = history.first;
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

                    markAsAutoUpdated = true;
                  }
                }
              }
            }
          }
        }

        final originalStatus = transaction.originalStatus ?? matchStatus;
        debugPrint('Match status: $matchStatus');
        updatedTransactions.add(transaction.copyWith(
          vendorName: finalVendorName,
          matchStatus: matchStatus,
          potentialMatches: potentialMatches,
          suggestedAccount: suggestedAccount,
          account: suggestedAccount?.name,
          vendorId: vendorId,
          originalStatus: originalStatus,
          userModified: transaction.userModified,
          autoUpdated: markAsAutoUpdated,
        ));
      }

      _transactionsByDocument[documentId] = updatedTransactions;
    } catch (e, st) {
      _logger.severe('Error matching transactions', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void splitTransaction(
      String originalTransactionId, double splitAmount, String newAccountName) {
    if (currentDocumentGroup == null) return;

    final documentId = currentDocumentGroup!.document.id;
    final transactions = _transactionsByDocument[documentId] ?? [];
    final index = transactions.indexWhere((t) => t.id == originalTransactionId);

    if (index == -1) return;

    final original = transactions[index];
    final originalAmount = original.amount.abs();

    if (splitAmount <= 0 || splitAmount >= originalAmount) return;

    final remainingAmount = originalAmount - splitAmount;
    final isNegative = original.amount < 0;

    final updatedOriginal = original.copyWith(
      amount: isNegative ? -remainingAmount : remainingAmount,
      userModified: true,
    );

    final splitId =
        '${original.id}_split_${DateTime.now().millisecondsSinceEpoch}';
    final newTransaction = original.copyWith(
      id: splitId,
      amount: isNegative ? -splitAmount : splitAmount,
      account: newAccountName,
      matchStatus: MatchStatus.critical,
      userModified: true,
      autoUpdated: false,
      originalStatus: original.originalStatus ?? original.matchStatus,
    );

    transactions[index] = updatedOriginal;
    transactions.insert(index + 1, newTransaction);
    _transactionsByDocument[documentId] = transactions;

    notifyListeners();
  }

  /// Updates a transaction and prompts for vendor-wide update if enabled
  void updateTransaction(ParsedTransaction updatedTransaction,
      {bool propagateToOthers = false}) {
    if (currentDocumentGroup == null) return;

    final documentId = currentDocumentGroup!.document.id;
    final transactions = _transactionsByDocument[documentId] ?? [];
    final index = transactions.indexWhere((t) => t.id == updatedTransaction.id);

    if (index == -1) return;

    transactions[index] = updatedTransaction;

    // Vendor auto-update logic: Only if enabled AND user wants to propagate
    // Relaxed condition: Allow if vendorName is present, even if vendorId is null
    if (_autoUpdateVendorAssociations &&
        updatedTransaction.userModified &&
        updatedTransaction.suggestedAccount != null) {
      _logger.info('Propagating vendor-account association: '
          'vendorId=${updatedTransaction.vendorId}, '
          'vendorName=${updatedTransaction.vendorName}, '
          'account=${updatedTransaction.suggestedAccount!.name}');

      // Update ALL transactions across ALL documents with same vendor
      for (final docId in _transactionsByDocument.keys) {
        final docTransactions = _transactionsByDocument[docId] ?? [];

        for (int i = 0; i < docTransactions.length; i++) {
          final txn = docTransactions[i];

          // Skip self
          if (txn.id == updatedTransaction.id) continue;

          // STRICT SAFETY:
          // 1. Must NOT be user modified
          // 2. Must NOT have an existing suggested account (only fill empty ones)
          if (txn.userModified || txn.suggestedAccount != null) continue;

          // MATCHING LOGIC:
          // 1. Try match by vendorId if both exist
          // 2. Fallback to vendorName match
          bool isMatch = false;
          if (updatedTransaction.vendorId != null && txn.vendorId != null) {
            isMatch = txn.vendorId == updatedTransaction.vendorId;
          } else {
            isMatch = txn.vendorName.toLowerCase().trim() ==
                updatedTransaction.vendorName.toLowerCase().trim();
          }

          if (isMatch) {
            docTransactions[i] = txn.copyWith(
              account: updatedTransaction.suggestedAccount!.name,
              suggestedAccount: updatedTransaction.suggestedAccount,
              matchStatus: MatchStatus.confident,
              autoUpdated: true,
              userModified: false, // Remains false as it's auto-updated
            );

            _logger.fine('Auto-updated transaction ${txn.id} in doc $docId');
          }
        }

        _transactionsByDocument[docId] = docTransactions;
      }
    } else {
      _logger.info('Not propagating vendor-account association: '
          'vendor=${updatedTransaction.vendorId}, \n'
          'account=${updatedTransaction.suggestedAccount!.name} \n'
          'PARAMS: \n'
          'autoUpdateVendorAssociations: $_autoUpdateVendorAssociations\n'
          'userModified: ${updatedTransaction.userModified}\n'
          'vendorId: ${updatedTransaction.vendorId}\n'
          'suggestedAccount: ${updatedTransaction.suggestedAccount?.name}\n');
    }

    _transactionsByDocument[documentId] = transactions;
    notifyListeners();
  }

  void toggleUseMemory(String transactionId) {
    if (currentDocumentGroup == null) return;

    final documentId = currentDocumentGroup!.document.id;
    final transactions = _transactionsByDocument[documentId] ?? [];
    final index = transactions.indexWhere((t) => t.id == transactionId);

    if (index != -1) {
      final transaction = transactions[index];
      transactions[index] = transaction.copyWith(
        useMemory: !transaction.useMemory,
        userModified: true,
      );
      _transactionsByDocument[documentId] = transactions;
      notifyListeners();
    }
  }

  Future<void> refreshTransactions() async {
    await runAudit();
  }

  void clearTransactions() {
    _transactionsByDocument.clear();
    _completedDocumentIds.clear();
    _currentDocumentIndex = 0;
    _hasRunAudit = false;
    notifyListeners();
  }

  void reset() {
    // for (final doc in _uploadedDocuments) {
    //   _documentService.cleanupDocument(doc); // Commented to prevent deletion of user files
    // }
    _uploadedDocuments.clear();
    _transactionsByDocument.clear();
    _completedDocumentIds.clear();
    _currentDocumentIndex = 0;
    _hasRunAudit = false;
    _auditCompletedSuccessfully = false;
    _errorMessage = null;
    notifyListeners();
  }

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
