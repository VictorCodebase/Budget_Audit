import 'package:flutter/material.dart';

/// Represents a budget template preset
class BudgetPreset {
  final String name;
  final String description;
  final String targetAudience;
  final String period; // "Monthly", "Quarterly", etc.
  final double totalBudget;
  final List<PresetCategory> categories;

  const BudgetPreset({
    required this.name,
    required this.description,
    required this.targetAudience,
    required this.period,
    required this.totalBudget,
    required this.categories,
  });

  /// Calculate total budget (sum of all account budgets)
  double get calculatedTotal {
    return categories.fold(
      0.0,
      (sum, category) => sum + category.totalBudget,
    );
  }

  /// Get number of accounts across all categories
  int get totalAccounts {
    return categories.fold(
      0,
      (sum, category) => sum + category.accounts.length,
    );
  }

  /// Get number of categories
  int get totalCategories => categories.length;

  /// Scale the preset budgets by a multiplier
  /// Used when the user selects a different period
  BudgetPreset scaleByMultiplier(double multiplier) {
    return BudgetPreset(
      name: name,
      description: description,
      targetAudience: targetAudience,
      period: period,
      totalBudget: totalBudget * multiplier,
      categories:
          categories.map((cat) => cat.scaleByMultiplier(multiplier)).toList(),
    );
  }
}

/// Represents a category in a preset
class PresetCategory {
  final String name;
  final String colorName; // Name from ColorPalette
  final List<PresetAccount> accounts;

  const PresetCategory({
    required this.name,
    required this.colorName,
    required this.accounts,
  });

  /// Calculate total budget for this category
  double get totalBudget {
    return accounts.fold(
      0.0,
      (sum, account) => sum + account.budget,
    );
  }

  /// Scale category accounts by a multiplier
  PresetCategory scaleByMultiplier(double multiplier) {
    return PresetCategory(
      name: name,
      colorName: colorName,
      accounts:
          accounts.map((acc) => acc.scaleByMultiplier(multiplier)).toList(),
    );
  }
}

/// Represents an account in a preset
class PresetAccount {
  final String name;
  final double budget;

  const PresetAccount({
    required this.name,
    required this.budget,
  });

  /// Scale account budget by a multiplier
  PresetAccount scaleByMultiplier(double multiplier) {
    return PresetAccount(
      name: name,
      budget: budget * multiplier,
    );
  }
}
