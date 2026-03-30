import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_audit/core/models/preset_models.dart';
import 'package:budget_audit/features/budgeting/budgeting_viewmodel.dart';
import 'package:budget_audit/core/models/models.dart' as models;
import 'package:budget_audit/core/models/client_models.dart' as clientModels;
import 'package:budget_audit/core/services/budget_service.dart';
import 'package:budget_audit/core/services/participant_service.dart';
import 'package:budget_audit/core/services/preset_service.dart';
import 'package:budget_audit/core/context.dart';
import 'package:budget_audit/core/data/database.dart'; // Needed for AppDatabase type

// Fake classes
class FakeAppContext extends ChangeNotifier implements AppContext {
  models.Template? _currentTemplate;
  models.Participant? _currentParticipant;

  @override
  models.Template? get currentTemplate => _currentTemplate;

  @override
  models.Participant? get currentParticipant => _currentParticipant;

  @override
  Future<void> setCurrentTemplate(models.Template? template) async {
    _currentTemplate = template;
    notifyListeners();
  }

  // Implement other methods as needed or throw UnimplementedError
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeParticipantService implements ParticipantService {
  final List<models.Participant> _participants = [];

  @override
  Future<List<models.Participant>> getAllParticipants() async {
    return _participants;
  }

  void setParticipants(List<models.Participant> participants) {
    _participants.clear();
    _participants.addAll(participants);
  }

  @override
  Future<models.Participant?> getParticipant(int id) async {
    return _participants.firstWhere((p) => p.participantId == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTemplateService implements TemplateService {
  final List<models.Template> _templates = [];

  @override
  Future<List<models.Template>> getAllTemplates() async {
    return _templates;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCategoryService implements CategoryService {
  final List<models.Category> _categories = [];

  @override
  Future<List<models.Category>> getCategoriesForTemplate(int templateId) async {
    return _categories.where((c) => c.templateId == templateId).toList();
  }

  void setCategories(List<models.Category> categories) {
    _categories.clear();
    _categories.addAll(categories);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAccountService implements AccountService {
  final List<models.Account> _accounts = [];

  @override
  Future<List<models.Account>> getAccountsForCategory(
      int templateId, int categoryId) async {
    return _accounts
        .where((a) => a.templateId == templateId && a.categoryId == categoryId)
        .toList();
  }

  void setAccounts(List<models.Account> accounts) {
    _accounts.clear();
    _accounts.addAll(accounts);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBudgetService implements BudgetService {
  final FakeTemplateService _templateService = FakeTemplateService();
  final FakeCategoryService _categoryService = FakeCategoryService();
  final FakeAccountService _accountService = FakeAccountService();

  @override
  TemplateService get templateService => _templateService;

  @override
  CategoryService get categoryService => _categoryService;

  @override
  AccountService get accountService => _accountService;

  // Helpers to access fakes
  FakeTemplateService get fakeTemplateService => _templateService;
  FakeCategoryService get fakeCategoryService => _categoryService;
  FakeAccountService get fakeAccountService => _accountService;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePresetService implements PresetService {
  @override
  Future<List<BudgetPreset>> loadAllPresets() async {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late BudgetingViewModel viewModel;
  late FakeBudgetService budgetService;
  late FakeParticipantService participantService;
  late FakeAppContext appContext;
  late FakePresetService presetService;

  setUp(() {
    budgetService = FakeBudgetService();
    participantService = FakeParticipantService();
    appContext = FakeAppContext();
    presetService = FakePresetService();
    viewModel = BudgetingViewModel(
        budgetService, participantService, presetService, appContext);
  });

  group('BudgetingViewModel Filter & Sort Tests', () {
    final p1 = models.Participant(
      participantId: 1,
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      role: models.Role.manager,
    );

    final t1 = models.Template(
      templateId: 1,
      templateName: 'Test Template',
      creatorParticipantId: 1,
      dateCreated: DateTime.now(),
      period: 'Monthly',
    );

    final c1 = models.Category(
      categoryId: 1,
      templateId: 1,
      categoryName: 'Category A',
      colorHex: '#FF0000',
    );

    final c2 = models.Category(
      categoryId: 2,
      templateId: 1,
      categoryName: 'Category B',
      colorHex: '#00FF00',
    );

    final a1 = models.Account(
      accountId: 1,
      categoryId: 1,
      templateId: 1,
      accountName: 'Account 1',
      budgetAmount: 100.0,
      expenditureTotal: 0.0,
      responsibleParticipantId: 1,
      colorHex: '#FF0000',
      dateCreated: DateTime.now(),
    );

    final a2 = models.Account(
      accountId: 2,
      categoryId: 2,
      templateId: 1,
      accountName: 'Account 2',
      budgetAmount: 200.0,
      expenditureTotal: 0.0,
      responsibleParticipantId: 1,
      colorHex: '#00FF00',
      dateCreated: DateTime.now(),
    );

    test('Initial state', () {
      expect(viewModel.currentFilter, FilterType.name);
      expect(viewModel.sortOrder, SortOrder.asc);
      expect(viewModel.filterParticipant, null);
      expect(viewModel.filterColor, null);
    });

    test('Load data and sort by Total Budget', () async {
      // Setup data
      participantService.setParticipants([p1]);
      budgetService.fakeCategoryService.setCategories([c1, c2]);
      budgetService.fakeAccountService.setAccounts([a1, a2]);

      await appContext.setCurrentTemplate(t1);
      await viewModel.initialize();

      expect(viewModel.categories.length, 2);

      // Default sort is Name ASC
      expect(viewModel.categories[0].name, 'Category A');
      expect(viewModel.categories[1].name, 'Category B');

      // Sort by Total Budget ASC (Low to High)
      viewModel.setFilter(FilterType.totalBudget, order: SortOrder.asc);
      expect(viewModel.currentFilter, FilterType.totalBudget);
      expect(viewModel.sortOrder, SortOrder.asc);

      // c1 total = 100, c2 total = 200
      expect(viewModel.categories[0].totalBudget, 100.0);
      expect(viewModel.categories[1].totalBudget, 200.0);

      // Sort by Total Budget DESC (High to Low)
      viewModel.setFilter(FilterType.totalBudget);
      expect(viewModel.sortOrder, SortOrder.desc);

      expect(viewModel.categories[0].totalBudget, 200.0);
      expect(viewModel.categories[1].totalBudget, 100.0);
    });

    test('Filter by Color', () async {
      // Setup data
      participantService.setParticipants([p1]);
      budgetService.fakeCategoryService.setCategories([c1, c2]);
      budgetService.fakeAccountService.setAccounts([a1, a2]);

      await appContext.setCurrentTemplate(t1);
      await viewModel.initialize();

      // Filter by Red (c1)
      viewModel.setFilterColor(const Color(0xFFFF0000));
      expect(viewModel.filterColor, const Color(0xFFFF0000));

      expect(viewModel.categories.length, 1);
      expect(viewModel.categories[0].name, 'Category A');

      // Clear filter
      viewModel.setFilterColor(null);
      expect(viewModel.categories.length, 2);
    });

    test('Filter by Participant', () async {
      // Setup data
      participantService.setParticipants([p1]);
      budgetService.fakeCategoryService.setCategories([c1, c2]);
      // Both accounts responsible by p1
      budgetService.fakeAccountService.setAccounts([a1, a2]);

      await appContext.setCurrentTemplate(t1);
      await viewModel.initialize();

      viewModel.setFilterParticipant(p1);
      expect(viewModel.filterParticipant, p1);

      // Both categories have accounts with p1
      expect(viewModel.categories.length, 2);

      // Create a participant p2 and account a3 for c2
      final p2 = models.Participant(
        participantId: 2,
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        role: models.Role.participant,
      );

      // We need to update the mock to return p2 when requested
      // But our fake implementation of getParticipant uses the list
      participantService.setParticipants([p1, p2]);

      // Let's say c2 has account a3 responsible by p2
      final a3 = models.Account(
        accountId: 3,
        categoryId: 2,
        templateId: 1,
        accountName: 'Account 3',
        budgetAmount: 50.0,
        expenditureTotal: 0.0,
        responsibleParticipantId: 2,
        colorHex: '#00FF00',
        dateCreated: DateTime.now(),
      );

      // Update accounts: c1 has a1(p1), c2 has a3(p2)
      budgetService.fakeAccountService.setAccounts([a1, a3]);

      // Reload
      await viewModel.initialize();

      // Filter by p1
      viewModel.setFilterParticipant(p1);
      expect(viewModel.categories.length, 1);
      expect(viewModel.categories[0].name, 'Category A'); // Only c1 has p1

      // Filter by p2
      viewModel.setFilterParticipant(p2);
      expect(viewModel.categories.length, 1);
      expect(viewModel.categories[0].name, 'Category B'); // Only c2 has p2

      // Clear filter
      viewModel.setFilterParticipant(null);
      expect(viewModel.categories.length, 2);
    });
  });
}
