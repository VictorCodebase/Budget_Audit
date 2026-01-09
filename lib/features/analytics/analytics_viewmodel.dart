// lib/features/analytics/analytics_viewmodel.dart

import 'package:flutter/foundation.dart' hide Category;
import 'package:logging/logging.dart';
import '../../core/models/models.dart';
import '../../core/services/budget_service.dart';
import '../../core/context.dart';

/// Represents time unit options for analytics graphs
enum TimeUnit {
  days('Days'),
  weeks('Weeks'),
  months('Months'),
  quarters('Quarters');

  final String label;
  const TimeUnit(this.label);

  int get daysCount {
    switch (this) {
      case TimeUnit.days:
        return 1;
      case TimeUnit.weeks:
        return 7;
      case TimeUnit.months:
        return 30;
      case TimeUnit.quarters:
        return 90;
    }
  }
}

/// Main tab in analytics
enum AnalyticsTab {
  budgetAnalytics,
  expenditureAnalysis,
}

/// Sub-tab in expenditure analysis
enum ExpenditureSubTab {
  spendingDeepDive,
  detailedExpenditure,
}

/// Participant filter option
enum ParticipantFilter {
  all,
  individual;

  String getLabel(Participant? participant) {
    if (this == ParticipantFilter.all) return 'All (Average)';
    return participant?.firstName ?? 'Individual';
  }
}

/// Data point for time-series charts
class TimeSeriesDataPoint {
  final DateTime date;
  final double value;
  final String label;
  final Map<int, double>? participantValues; // For stacked charts

  TimeSeriesDataPoint({
    required this.date,
    required this.value,
    required this.label,
    this.participantValues,
  });
}

/// Category spending data for pie/bar charts
class CategorySpendingData {
  final Category category;
  final double budgeted;
  final double spent;
  final double percentage;
  final List<AccountSpendingData> accounts;

  CategorySpendingData({
    required this.category,
    required this.budgeted,
    required this.spent,
    required this.percentage,
    required this.accounts,
  });

  double get percentageOfBudget => budgeted > 0 ? (spent / budgeted) * 100 : 0;
}

/// Account spending data
class AccountSpendingData {
  final Account account;
  final double budgeted;
  final double spent;
  final double percentage;

  AccountSpendingData({
    required this.account,
    required this.budgeted,
    required this.spent,
    required this.percentage,
  });

  double get percentageOfBudget => budgeted > 0 ? (spent / budgeted) * 100 : 0;
}

/// Vendor spending data
class VendorSpendingData {
  final Vendor vendor;
  final double totalSpent;

  VendorSpendingData({
    required this.vendor,
    required this.totalSpent,
  });
}

class AnalyticsViewModel extends ChangeNotifier {
  final BudgetService _budgetService;
  final AppContext _appContext;
  final Logger _logger = Logger('AnalyticsViewModel');

  // State management
  bool _isLoading = false;
  String? _errorMessage;

  // Tab state
  AnalyticsTab _currentTab = AnalyticsTab.budgetAnalytics;
  ExpenditureSubTab _expenditureSubTab = ExpenditureSubTab.spendingDeepDive;

  // Template selection
  Template? _selectedTemplate;
  List<Template> _availableTemplates = [];

  // Participants
  List<Participant> _templateParticipants = [];
  ParticipantFilter _participantFilter = ParticipantFilter.all;
  Participant? _selectedParticipant;

  // Time configuration
  TimeUnit _timeUnit = TimeUnit.days;
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPeriodOffset = 0; // For browsing back/forward

  // Data caches
  List<Transaction> _allTransactions = [];
  List<Category> _allCategories = [];
  List<Account> _allAccounts = [];
  List<Vendor> _allVendors = [];

  // Computed data
  List<CategorySpendingData> _categorySpendingData = [];
  List<AccountSpendingData> _accountSpendingData = [];
  List<VendorSpendingData> _vendorSpendingData = [];
  CategorySpendingData? _selectedCategoryForBarChart;

  // Chart data
  List<TimeSeriesDataPoint> _expenditureVsBudgetData = [];
  List<TimeSeriesDataPoint> _expenditureRelativeToBudgetData = [];

  AnalyticsViewModel({
    required BudgetService budgetService,
    required AppContext appContext,
  })  : _budgetService = budgetService,
        _appContext = appContext;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AnalyticsTab get currentTab => _currentTab;
  ExpenditureSubTab get expenditureSubTab => _expenditureSubTab;
  Template? get selectedTemplate => _selectedTemplate;
  List<Template> get availableTemplates => _availableTemplates;
  List<Participant> get templateParticipants => _templateParticipants;
  ParticipantFilter get participantFilter => _participantFilter;
  Participant? get selectedParticipant => _selectedParticipant;
  TimeUnit get timeUnit => _timeUnit;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  List<CategorySpendingData> get categorySpendingData => _categorySpendingData;
  List<AccountSpendingData> get accountSpendingData => _accountSpendingData;
  List<VendorSpendingData> get vendorSpendingData => _vendorSpendingData;
  CategorySpendingData? get selectedCategoryForBarChart =>
      _selectedCategoryForBarChart;
  List<TimeSeriesDataPoint> get expenditureVsBudgetData =>
      _expenditureVsBudgetData;
  List<TimeSeriesDataPoint> get expenditureRelativeToBudgetData =>
      _expenditureRelativeToBudgetData;

  double get totalBudgeted {
    return _allAccounts.fold(0.0, (sum, account) => sum + account.budgetAmount);
  }

  double get totalSpent {
    return _calculateTotalSpent(_allTransactions);
  }

  List<TimeUnit> get availableTimeUnits {
    if (_selectedTemplate == null) return TimeUnit.values;

    final periodDays = _getPeriodDays(_selectedTemplate!.period);
    return TimeUnit.values
        .where((unit) => unit.daysCount < periodDays)
        .toList();
  }

  /// Initialize analytics with current or specified template
  Future<void> initialize([Template? template]) async {
    _setLoading(true);
    _clearError();

    try {
      // Load all available templates
      _availableTemplates =
          await _budgetService.templateService.getAllTemplates();

      // Select template (use provided, current from context, or first available)
      _selectedTemplate = template ??
          _appContext.currentTemplate ??
          (_availableTemplates.isNotEmpty ? _availableTemplates.first : null);

      if (_selectedTemplate == null) {
        _setError('No templates available. Please create a budget first.');
        return;
      }

      await _loadTemplateData();
      await _computeAnalytics();
    } catch (e, st) {
      _logger.severe('Error initializing analytics', e, st);
      _setError('Failed to load analytics: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Switch to a different template
  Future<void> selectTemplate(Template template) async {
    if (_selectedTemplate?.templateId == template.templateId) return;

    _selectedTemplate = template;
    _currentPeriodOffset = 0; // Reset browsing

    await _loadTemplateData();
    await _computeAnalytics();
  }

  /// Load all data for the selected template
  Future<void> _loadTemplateData() async {
    if (_selectedTemplate == null) return;

    final templateId = _selectedTemplate!.templateId;

    // Load categories
    _allCategories = await _budgetService.categoryService
        .getCategoriesForTemplate(templateId);

    // Load all accounts
    _allAccounts = await _budgetService.accountService
        .getAllAccountsForTemplate(templateId);

    // Load all transactions for this template
    _allTransactions = await _loadTransactionsForTemplate(templateId);

    // Load vendors
    _allVendors = await _budgetService.transactionService.getAllVendors();

    // Set date range based on transactions
    _setDateRangeFromTransactions();

    // Ensure time unit is valid for this template's period
    if (!availableTimeUnits.contains(_timeUnit)) {
      _timeUnit = availableTimeUnits.first;
    }

    notifyListeners();
  }

  /// Load all transactions associated with a template
  Future<List<Transaction>> _loadTransactionsForTemplate(int templateId) async {
    return await _budgetService.transactionService
        .getTransactionsForTemplate(templateId);
  }

  /// Get number of days for a period string
  // int _getPeriodDays(String period) {
  //   final normalized = period.toLowerCase().trim();
  //   if (normalized.contains('annual') || normalized.contains('year')) {
  //     return 365;
  //   } else if (normalized.contains('quarter')) {
  //     return 90;
  //   } else if (normalized.contains('month')) {
  //     return 30;
  //   } else if (normalized.contains('week')) {
  //     return 7;
  //   }
  //   return 30; // Default to monthly
  // }

  /// Set date range based on transactions
  void _setDateRangeFromTransactions() {
    if (_allTransactions.isEmpty) {
      // Default to template creation date + period
      _startDate = _selectedTemplate?.dateCreated;
      _endDate = _startDate?.add(Duration(
          days: _getPeriodDays(_selectedTemplate?.period ?? 'monthly')));
      return;
    }

    // Find latest transaction
    _endDate = _allTransactions
        .map((t) => t.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    // Calculate start date based on period
    final periodDays = _getPeriodDays(_selectedTemplate!.period);
    _startDate = _endDate!.subtract(Duration(days: periodDays));
  }

  /// Get number of days for a period string
  int _getPeriodDays(String period) {
    final normalized = period.toLowerCase().trim();
    if (normalized.contains('annual') || normalized.contains('year')) {
      return 365;
    } else if (normalized.contains('quarter')) {
      return 90;
    } else if (normalized.contains('month')) {
      return 30;
    } else if (normalized.contains('week')) {
      return 7;
    }
    return 30; // Default to monthly
  }

  /// Compute all analytics data
  Future<void> _computeAnalytics() async {
    _computeCategorySpending();
    _computeAccountSpending();
    _computeVendorSpending();
    _computeExpenditureVsBudgetChart();
    _computeExpenditureRelativeToBudgetChart();
    notifyListeners();
  }

  /// Compute category spending data for pie chart
  /// Compute category spending data for pie chart
  void _computeCategorySpending() {
    final Map<int, double> categorySpending = {};
    final Map<int, double> categoryBudget = {};
    final Map<int, List<AccountSpendingData>> categoryAccounts = {};

    // Calculate spending per category
    for (final account in _allAccounts) {
      final categoryId = account.categoryId;

      // Get transactions for this account
      final accountTransactions = _allTransactions
          .where((t) => t.accountId == account.accountId && !t.isIgnored)
          .toList();

      final spent = _calculateTotalSpent(accountTransactions);

      categorySpending[categoryId] =
          (categorySpending[categoryId] ?? 0) + spent;
      categoryBudget[categoryId] =
          (categoryBudget[categoryId] ?? 0) + account.budgetAmount;

      // Store account data with color from account model
      categoryAccounts[categoryId] ??= [];
      categoryAccounts[categoryId]!.add(AccountSpendingData(
        account: account, // Account object has .color getter
        budgeted: account.budgetAmount,
        spent: spent,
        percentage:
            account.budgetAmount > 0 ? (spent / account.budgetAmount) * 100 : 0,
      ));
    }

    // Create category spending data with color from category model
    _categorySpendingData = _allCategories.map((category) {
      final spent = categorySpending[category.categoryId] ?? 0;
      final budgeted = categoryBudget[category.categoryId] ?? 0;
      final accounts = categoryAccounts[category.categoryId] ?? [];

      return CategorySpendingData(
        category: category, // Category object has .color getter
        budgeted: budgeted,
        spent: spent,
        percentage: totalBudgeted > 0 ? (budgeted / totalBudgeted) * 100 : 0,
        accounts: accounts,
      );
    }).toList();

    // Sort by budgeted amount (descending) for default selection
    _categorySpendingData.sort((a, b) => b.budgeted.compareTo(a.budgeted));

    // Set default selected category (largest)
    if (_categorySpendingData.isNotEmpty) {
      _selectedCategoryForBarChart = _categorySpendingData.first;
    }
  }

  /// Compute account spending sorted by percentage of budget used
  void _computeAccountSpending() {
    _accountSpendingData = _allAccounts.map((account) {
      final accountTransactions = _allTransactions
          .where((t) => t.accountId == account.accountId && !t.isIgnored)
          .toList();

      final spent = _calculateTotalSpent(accountTransactions);

      return AccountSpendingData(
        account: account,
        budgeted: account.budgetAmount,
        spent: spent,
        percentage:
            account.budgetAmount > 0 ? (spent / account.budgetAmount) * 100 : 0,
      );
    }).toList();

    // Sort by percentage of budget used (descending)
    _accountSpendingData
        .sort((a, b) => b.percentageOfBudget.compareTo(a.percentageOfBudget));
  }

  /// Compute vendor spending sorted by total amount
  void _computeVendorSpending() {
    final Map<int, double> vendorSpending = {};

    for (final transaction in _allTransactions) {
      if (!transaction.isIgnored) {
        // ✅ Convert negative amounts to positive for expenditure tracking
        final expenditureAmount = transaction.amount < 0
            ? transaction.amount.abs()
            : transaction.amount;

        vendorSpending[transaction.vendorId] =
            (vendorSpending[transaction.vendorId] ?? 0) + expenditureAmount;
      }
    }

    _vendorSpendingData = _allVendors
        .where((vendor) => vendorSpending.containsKey(vendor.vendorId))
        .map((vendor) => VendorSpendingData(
              vendor: vendor,
              totalSpent: vendorSpending[vendor.vendorId]!,
            ))
        .toList();

    // Sort by amount spent (descending)
    _vendorSpendingData.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
  }

  /// Compute expenditure vs budget variation over time
  void _computeExpenditureVsBudgetChart() {
    if (_startDate == null || _endDate == null) {
      _expenditureVsBudgetData = [];
      return;
    }

    final dataPoints = <TimeSeriesDataPoint>[];
    final periodStart = _startDate!.add(Duration(
        days:
            _currentPeriodOffset * _getPeriodDays(_selectedTemplate!.period)));
    final periodEnd = _endDate!.add(Duration(
        days:
            _currentPeriodOffset * _getPeriodDays(_selectedTemplate!.period)));

    // Generate time intervals based on selected time unit
    final intervals = _generateTimeIntervals(periodStart, periodEnd, _timeUnit);

    for (final interval in intervals) {
      if (_participantFilter == ParticipantFilter.all) {
        // Calculate average across all participants
        final participantValues = <int, double>{};

        for (final participant in _templateParticipants) {
          final participantTransactions = _allTransactions
              .where((t) =>
                  t.participantId == participant.participantId &&
                  !t.isIgnored &&
                  t.date.isAfter(interval['start']) &&
                  t.date.isBefore(interval['end']))
              .toList();

          final spent = _calculateTotalSpent(participantTransactions);
          final double percentage =
              totalBudgeted > 0 ? (spent / totalBudgeted) * 100 : 0;
          participantValues[participant.participantId] = percentage;
        }

        // Average the percentages
        final avgPercentage = participantValues.values.isEmpty
            ? 0.0
            : participantValues.values.reduce((a, b) => a + b) /
                participantValues.length;

        dataPoints.add(TimeSeriesDataPoint(
          date: interval['start'],
          value: avgPercentage,
          label: interval['label'],
        ));
      } else if (_selectedParticipant != null) {
        // Individual participant
        final participantTransactions = _allTransactions
            .where((t) =>
                t.participantId == _selectedParticipant!.participantId &&
                !t.isIgnored &&
                t.date.isAfter(interval['start']) &&
                t.date.isBefore(interval['end']))
            .toList();

        final spent = _calculateTotalSpent(participantTransactions);
        final double percentage =
            totalBudgeted > 0 ? (spent / totalBudgeted) * 100 : 0;

        dataPoints.add(TimeSeriesDataPoint(
          date: interval['start'],
          value: percentage,
          label: interval['label'],
        ));
      }
    }

    _expenditureVsBudgetData = dataPoints;
  }

  /// Compute expenditure relative to budget (stacked or individual)
  void _computeExpenditureRelativeToBudgetChart() {
    if (_startDate == null || _endDate == null) {
      _expenditureRelativeToBudgetData = [];
      return;
    }

    final dataPoints = <TimeSeriesDataPoint>[];
    final periodStart = _startDate!.add(Duration(
        days:
            _currentPeriodOffset * _getPeriodDays(_selectedTemplate!.period)));
    final periodEnd = _endDate!.add(Duration(
        days:
            _currentPeriodOffset * _getPeriodDays(_selectedTemplate!.period)));

    final intervals = _generateTimeIntervals(periodStart, periodEnd, _timeUnit);

    for (final interval in intervals) {
      if (_participantFilter == ParticipantFilter.all) {
        // Show stacked data (no averaging)
        final participantValues = <int, double>{};

        for (final participant in _templateParticipants) {
          final participantTransactions = _allTransactions
              .where((t) =>
                  t.participantId == participant.participantId &&
                  !t.isIgnored &&
                  t.date.isAfter(interval['start']) &&
                  t.date.isBefore(interval['end']))
              .toList();

          final spent = _calculateTotalSpent(participantTransactions);
          final double percentage =
              totalBudgeted > 0 ? (spent / totalBudgeted) * 100 : 0;
          participantValues[participant.participantId] = percentage;
        }

        // Total for the label
        final totalPercentage =
            participantValues.values.fold(0.0, (a, b) => a + b);

        dataPoints.add(TimeSeriesDataPoint(
          date: interval['start'],
          value: totalPercentage,
          label: interval['label'],
          participantValues: participantValues,
        ));
      } else if (_selectedParticipant != null) {
        // Individual participant
        final participantTransactions = _allTransactions
            .where((t) =>
                t.participantId == _selectedParticipant!.participantId &&
                !t.isIgnored &&
                t.date.isAfter(interval['start']) &&
                t.date.isBefore(interval['end']))
            .toList();

        final spent = _calculateTotalSpent(participantTransactions);
        final double percentage =
            totalBudgeted > 0 ? (spent / totalBudgeted) * 100 : 0;

        dataPoints.add(TimeSeriesDataPoint(
          date: interval['start'],
          value: percentage,
          label: interval['label'],
        ));
      }
    }

    _expenditureRelativeToBudgetData = dataPoints;
  }

  /// Generate time intervals for charting
  List<Map<String, dynamic>> _generateTimeIntervals(
      DateTime start, DateTime end, TimeUnit unit) {
    final intervals = <Map<String, dynamic>>[];
    var current = start;

    while (current.isBefore(end)) {
      final intervalEnd = current.add(Duration(days: unit.daysCount));
      intervals.add({
        'start': current,
        'end': intervalEnd.isAfter(end) ? end : intervalEnd,
        'label': _formatDateLabel(current, unit),
      });
      current = intervalEnd;
    }

    return intervals;
  }

  /// Format date label based on time unit
  String _formatDateLabel(DateTime date, TimeUnit unit) {
    switch (unit) {
      case TimeUnit.days:
        return '${date.day}/${date.month}';
      case TimeUnit.weeks:
        return 'W${_getWeekNumber(date)}';
      case TimeUnit.months:
        return '${_getMonthName(date.month)} ${date.year}';
      case TimeUnit.quarters:
        return 'Q${_getQuarter(date.month)} ${date.year}';
    }
  }

  int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear / 7).ceil();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  int _getQuarter(int month) {
    return ((month - 1) / 3).floor() + 1;
  }

  /// Calculate total spent from transactions
  /// ✅ Handles negative amounts by converting to positive (expenditures)
  /// Ignores positive amounts (income)
  double _calculateTotalSpent(List<Transaction> transactions) {
    return transactions
        .where((t) =>
            !t.isIgnored &&
            t.amount < 0) // ✅ Only process negative amounts (expenditures)
        .fold(0.0, (sum, t) => sum + t.amount.abs()); // ✅ Convert to positive
  }

  // UI Actions

  void setTab(AnalyticsTab tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
    }
  }

  void setExpenditureSubTab(ExpenditureSubTab subTab) {
    if (_expenditureSubTab != subTab) {
      _expenditureSubTab = subTab;
      notifyListeners();
    }
  }

  void setParticipantFilter(ParticipantFilter filter,
      [Participant? participant]) {
    _participantFilter = filter;
    _selectedParticipant = participant;
    _computeExpenditureVsBudgetChart();
    _computeExpenditureRelativeToBudgetChart();
    notifyListeners();
  }

  void setTimeUnit(TimeUnit unit) {
    if (!availableTimeUnits.contains(unit)) return;

    _timeUnit = unit;
    _computeExpenditureVsBudgetChart();
    _computeExpenditureRelativeToBudgetChart();
    notifyListeners();
  }

  void navigatePeriod(int direction) {
    _currentPeriodOffset += direction;
    _computeExpenditureVsBudgetChart();
    _computeExpenditureRelativeToBudgetChart();
    notifyListeners();
  }

  void selectCategoryForBarChart(CategorySpendingData category) {
    _selectedCategoryForBarChart = category;
    notifyListeners();
  }

  Future<bool> requestDateRangeUpdate() async {
    // This should show a dialog in the view
    // For now, return true to indicate user accepted
    return true;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize(_selectedTemplate);
  }
}
