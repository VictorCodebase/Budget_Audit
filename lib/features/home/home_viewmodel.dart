// lib/features/home/home_viewmodel.dart

import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/core/models/client_models.dart' as client_models;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../core/context.dart';
import '../../core/models/client_models.dart';
import '../../core/models/models.dart' as models;
import '../../core/services/document_service.dart';
import '../../core/services/participant_service.dart';
import '../../core/services/budget_service.dart';

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

  Future<void> _initialize() async {
    await loadParticipants();
    await loadTemplateHistory();
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
      notifyListeners();
    } catch (e, st) {
      _logger.severe('Error running audit', e, st);
      _errorMessage = 'Failed to run audit: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates a parsed transaction
  void updateTransaction(ParsedTransaction updatedTransaction) {
    final index = _extractedTransactions.indexWhere(
      (t) => t.id == updatedTransaction.id,
    );

    if (index != -1) {
      _extractedTransactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  /// Toggles the "Use Memory" checkbox for a transaction
  void toggleUseMemory(String transactionId) {
    final index =
        _extractedTransactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = _extractedTransactions[index];
      _extractedTransactions[index] = transaction.copyWith(
        useMemory: !transaction.useMemory,
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
  Future<List<client_models.CategoryData>> getTemplateDetails(int templateId) async {
    try {
      // 1. Get all categories for this template
      final categories = await _budgetService.categoryService
          .getCategoriesForTemplate(templateId);

      // 2. Get all accounts for this template
      final accounts = await _budgetService.accountService
          .getAllAccountsForTemplate(templateId);

      // 3. Map accounts to their categories
      return categories.map((category) {
        final categoryAccounts = accounts
            .where((a) => a.categoryId == category.categoryId)
            .map((a) => client_models.AccountData(
                  id: a.accountId.toString(),
                  name: a.accountName,
                  budgetAmount: a.budgetAmount,
                  color: a.color,
                  // We don't need participants for read-only preview usually,
                  // but if needed we'd fetch them. For now leaving empty or fetching if critical.
                  // The Account model has responsibleParticipantId, we could map it if we had the list.
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
    // Cleanup any temporary files
    for (final doc in _uploadedDocuments) {
      _documentService.cleanupDocument(doc);
    }
    super.dispose();
  }
}
