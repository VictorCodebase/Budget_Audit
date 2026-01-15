
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../../core/utils/color_palette.dart';
import '../../core/models/preset_models.dart';

class PresetService {
  /// Load all available presets
  Future<List<BudgetPreset>> loadAllPresets() async {
    final presets = <BudgetPreset>[];
    const presetPath = 'assets/budget_presets/';

    try {
      // Load family preset
      final familyPreset =
          await loadPresetFromAsset('${presetPath}family_budget.yaml');
      if (familyPreset != null) {
        presets.add(familyPreset);
      }

      // Load student preset
      final studentPreset =
          await loadPresetFromAsset('${presetPath}student_budget.yaml');
      if (studentPreset != null) {
        presets.add(studentPreset);
      }
    } catch (e) {
      debugPrint('Error loading presets: $e');
    }

    return presets;
  }

  /// Load a preset from an asset file
  Future<BudgetPreset?> loadPresetFromAsset(String assetPath) async {
    try {
      final yamlString = await rootBundle.loadString(assetPath);
      return parsePresetFromYaml(yamlString);
    } catch (e) {
      debugPrint('Error loading preset from $assetPath: $e');
      return null;
    }
  }

  /// Parse a YAML string into a BudgetPreset
  BudgetPreset? parsePresetFromYaml(String yamlString) {
    try {
      final yamlMap = loadYaml(yamlString) as YamlMap;

      // Parse basic fields
      final name = yamlMap['name'] as String;
      final description = yamlMap['description'] as String;
      final targetAudience = yamlMap['targetAudience'] as String;
      final period = yamlMap['period'] as String;
      final totalBudget = (yamlMap['totalBudget'] as num).toDouble();

      // Parse categories
      final categoriesYaml = yamlMap['categories'] as YamlList;
      final categories = <PresetCategory>[];

      for (var categoryYaml in categoriesYaml) {
        final categoryMap = categoryYaml as YamlMap;
        final categoryName = categoryMap['name'] as String;
        final colorName = categoryMap['color'] as String;

        // Validate color exists in palette
        if (!_isValidColorName(colorName)) {
          debugPrint(
              'Warning: Invalid color "$colorName" for category "$categoryName". Skipping category.');
          continue;
        }

        // Parse accounts
        final accountsYaml = categoryMap['accounts'] as YamlList;
        final accounts = <PresetAccount>[];

        for (var accountYaml in accountsYaml) {
          final accountMap = accountYaml as YamlMap;
          final accountName = accountMap['name'] as String;
          final budget = (accountMap['budget'] as num).toDouble();

          // Validate budget is positive
          if (budget < 0) {
            debugPrint(
                'Warning: Negative budget for account "$accountName". Setting to 0.');
          }

          accounts.add(PresetAccount(
            name: accountName,
            budget: budget < 0 ? 0 : budget,
          ));
        }

        // Only add category if it has at least one account
        if (accounts.isNotEmpty) {
          categories.add(PresetCategory(
            name: categoryName,
            colorName: colorName,
            accounts: accounts,
          ));
        }
      }

      // Validate preset has at least one category
      if (categories.isEmpty) {
        debugPrint('Error: Preset "$name" has no valid categories');
        return null;
      }

      // Validate category names are unique
      final categoryNames =
          categories.map((c) => c.name.trim().toUpperCase()).toList();
      if (categoryNames.length != categoryNames.toSet().length) {
        debugPrint('Error: Preset "$name" has duplicate category names');
        return null;
      }

      // Validate each category has unique account names
      for (var category in categories) {
        final accountNames =
            category.accounts.map((a) => a.name.trim().toUpperCase()).toList();
        if (accountNames.length != accountNames.toSet().length) {
          debugPrint(
              'Error: Category "${category.name}" has duplicate account names');
          return null;
        }
      }

      return BudgetPreset(
        name: name,
        description: description,
        targetAudience: targetAudience,
        period: period,
        totalBudget: totalBudget,
        categories: categories,
      );
    } catch (e) {
      debugPrint('Error parsing preset YAML: $e');
      return null;
    }
  }

  /// Check if a color name exists in the ColorPalette
  bool _isValidColorName(String colorName) {
    return ColorPalette.all.any((nc) => nc.name == colorName);
  }

  /// Get Color object from color name
  Color? getColorFromName(String colorName) {
    try {
      return ColorPalette.all.firstWhere((nc) => nc.name == colorName).color;
    } catch (e) {
      return null;
    }
  }

  /// Calculate the period multiplier based on current period vs preset period
  double calculatePeriodMultiplier(
      String presetPeriod, String selectedPeriod, int customMonths) {
    final presetMonths = _periodToMonths(presetPeriod, 1);
    final selectedMonths = _periodToMonths(selectedPeriod, customMonths);

    return selectedMonths / presetMonths;
  }

  /// Convert period string to number of months
  int _periodToMonths(String period, int customMonths) {
    switch (period) {
      case 'Monthly':
        return 1;
      case 'Quarterly':
        return 3;
      case 'Semi-Annually':
        return 6;
      case 'Annually':
        return 12;
      case 'Custom':
        return customMonths;
      default:
        return 1;
    }
  }
}
