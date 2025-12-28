import 'package:budget_audit/core/context.dart';
import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/core/models/models.dart' as models;
import 'package:budget_audit/core/services/account_service.dart';
import 'package:budget_audit/core/services/budget_service.dart';
import 'package:budget_audit/core/services/category_service.dart';
import 'package:budget_audit/core/services/document_service.dart';
import 'package:budget_audit/core/services/participant_service.dart';
import 'package:budget_audit/core/services/template_service.dart';
import 'package:budget_audit/core/services/transaction_service.dart';
import 'package:budget_audit/features/home/home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

// Manual Mocks

class MockTransactionService extends TransactionService {
  MockTransactionService()
      : super(null as dynamic); // Hack to avoid passing database

  List<models.Vendor> vendors = [];
  Map<int, List<models.VendorMatchHistory>> history = {};

  @override
  Future<List<models.Vendor>> getAllVendors() async => vendors;

  @override
  Future<List<models.VendorMatchHistory>> getVendorMatchHistory(
          int vendorId) async =>
      history[vendorId] ?? [];
}

class MockAccountService extends AccountService {
  MockAccountService() : super(null as dynamic);

  List<models.Account> accounts = [];

  @override
  Future<List<models.Account>> getAllAccountsForTemplate(
          int templateId) async =>
      accounts;
}

class MockBudgetService extends BudgetService {
  final MockTransactionService mockTransactionService;
  final MockAccountService mockAccountService;

  MockBudgetService({
    required this.mockTransactionService,
    required this.mockAccountService,
  }) : super(null as dynamic);

  @override
  TransactionService get transactionService => mockTransactionService;

  @override
  AccountService get accountService => mockAccountService;

  // Stubs for other services
  @override
  CategoryService get categoryService => throw UnimplementedError();
  @override
  TemplateService get templateService => throw UnimplementedError();
}

class MockAppContext extends AppContext {
  MockAppContext() : super(database: null as dynamic, prefs: null as dynamic);

  models.Template? _currentTemplate;

  @override
  models.Template? get currentTemplate => _currentTemplate;

  void setTemplate(models.Template? template) {
    _currentTemplate = template;
  }
}

class MockDocumentService extends DocumentService {
  MockDocumentService() : super(null as dynamic);
}

class MockParticipantService extends ParticipantService {
  MockParticipantService() : super(null as dynamic);

  @override
  Future<List<models.Participant>> getAllParticipants() async => [];
}

void main() {
  late HomeViewModel viewModel;
  late MockBudgetService mockBudgetService;
  late MockTransactionService mockTransactionService;
  late MockAccountService mockAccountService;
  late MockAppContext mockAppContext;

  setUp(() {
    mockTransactionService = MockTransactionService();
    mockAccountService = MockAccountService();
    mockBudgetService = MockBudgetService(
      mockTransactionService: mockTransactionService,
      mockAccountService: mockAccountService,
    );
    mockAppContext = MockAppContext();

    viewModel = HomeViewModel(
      documentService: MockDocumentService(),
      participantService: MockParticipantService(),
      budgetService: mockBudgetService,
      appContext: mockAppContext,
    );
  });

  group('HomeViewModel Matching Logic', () {
    test('matchTransactions should identify exact matches with history',
        () async {
      // Setup
      final template = models.Template(
        templateId: 1,
        templateName: 'Test Template',
        creatorParticipantId: 1,
        dateCreated: DateTime.now(),
      );
      mockAppContext.setTemplate(template);

      final vendor = models.Vendor(vendorId: 1, vendorName: 'Tesco');
      mockTransactionService.vendors = [vendor];

      final account = models.Account(
        accountId: 10,
        categoryId: 1,
        templateId: 1,
        accountName: 'Groceries',
        colorHex: '#FF0000',
        budgetAmount: 100,
        expenditureTotal: 0,
        responsibleParticipantId: 1,
        dateCreated: DateTime.now(),
      );
      mockAccountService.accounts = [account];

      mockTransactionService.history = {
        1: [
          models.VendorMatchHistory(
            vendorMatchId: 1,
            vendorId: 1,
            accountId: 10,
            participantId: 1,
            useCount: 5,
            lastUsed: DateTime.now(),
          )
        ]
      };

      // Add a transaction
      viewModel.extractedTransactions.add(ParsedTransaction(
        id: '1',
        date: DateTime.now(),
        vendorName: 'Tesco',
        amount: 50.0,
      ));

      // Act
      await viewModel.matchTransactions();

      // Assert
      final matched = viewModel.extractedTransactions.first;
      expect(matched.matchStatus, MatchStatus.confident);
      expect(matched.suggestedAccount?.id, '10');
      expect(matched.vendorName, 'Tesco');
    });

    test('matchTransactions should identify fuzzy matches', () async {
      // Setup
      final template = models.Template(
        templateId: 1,
        templateName: 'Test Template',
        creatorParticipantId: 1,
        dateCreated: DateTime.now(),
      );
      mockAppContext.setTemplate(template);

      final vendor = models.Vendor(vendorId: 1, vendorName: 'Starbucks');
      mockTransactionService.vendors = [vendor];
      mockAccountService.accounts = []; // No accounts needed for this test

      // Add a transaction with typo
      viewModel.extractedTransactions.add(ParsedTransaction(
        id: '1',
        date: DateTime.now(),
        vendorName: 'Starbcks', // Typo
        amount: 5.0,
      ));

      // Act
      await viewModel.matchTransactions();

      // Assert
      final matched = viewModel.extractedTransactions.first;
      expect(matched.matchStatus, MatchStatus.potential);
      expect(matched.potentialMatches, contains('Starbucks'));
    });
  });

  group('HomeViewModel Split Logic', () {
    test('splitTransaction should split correctly', () {
      // Setup
      viewModel.extractedTransactions.add(ParsedTransaction(
        id: '1',
        date: DateTime.now(),
        vendorName: 'Walmart',
        amount: 100.0,
      ));

      // Act
      viewModel.splitTransaction('1', 40.0, 'Household');

      // Assert
      expect(viewModel.extractedTransactions.length, 2);

      final original = viewModel.extractedTransactions[0];
      final split = viewModel.extractedTransactions[1];

      expect(original.amount, 60.0); // 100 - 40
      expect(split.amount, 40.0);
      expect(split.account, 'Household');
      expect(split.matchStatus, MatchStatus.critical);
    });

    test('splitTransaction should handle negative amounts (refunds)', () {
      // Setup
      viewModel.extractedTransactions.add(ParsedTransaction(
        id: '1',
        date: DateTime.now(),
        vendorName: 'Walmart',
        amount: -100.0,
      ));

      // Act
      viewModel.splitTransaction(
          '1', 40.0, 'Household'); // Split 40 of the 100 refund

      // Assert
      expect(viewModel.extractedTransactions.length, 2);

      final original = viewModel.extractedTransactions[0];
      final split = viewModel.extractedTransactions[1];

      expect(original.amount, -60.0);
      expect(split.amount, -40.0);
    });
  });
}
