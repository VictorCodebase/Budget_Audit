import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import '../models/models.dart' as models;
import '../models/client_models.dart' as clientModels;
import '../data/database.dart';
import 'package:drift/drift.dart' as drift;

class BudgetService {
  final TemplateService _templateService;
  final AccountService _accountService;
  final CategoryService _categoryService;

  BudgetService(AppDatabase db)
      : _templateService = TemplateService(db),
        _accountService = AccountService(db),
        _categoryService = CategoryService(db);

  TemplateService get templateService => _templateService;
  AccountService get accountService => _accountService;
  CategoryService get categoryService => _categoryService;
}


class TemplateService {
  final AppDatabase _appDatabase;
  final Logger _logger = Logger("TemplateService");

  TemplateService(this._appDatabase);

  Future<List<models.Template>> getAllTemplates() async {
    try {
      final templates = await _appDatabase.select(_appDatabase.templates).get();
      return templates
          .map((t) => models.Template(
        templateId: t.templateId,
        syncId: t.syncId,
        spreadSheetId: t.spreadSheetId,
        templateName: t.templateName,
        creatorParticipantId: t.creatorParticipantId,
        dateCreated: t.dateCreated,
        timesUsed: t.timesUsed,
      ))
          .toList();
    } catch (e, st) {
      _logger.severe("Error fetching all templates", e, st);
      return [];
    }
  }

  /// Fetch a single template by ID
  Future<models.Template?> getTemplate(int templateId) async {
    try {
      final query = _appDatabase.select(_appDatabase.templates)
        ..where((tbl) => tbl.templateId.equals(templateId));
      final result = await query.getSingleOrNull();

      if (result == null) return null;

      return models.Template(
        templateId: result.templateId,
        syncId: result.syncId,
        spreadSheetId: result.spreadSheetId,
        templateName: result.templateName,
        creatorParticipantId: result.creatorParticipantId,
        dateCreated: result.dateCreated,
        timesUsed: result.timesUsed,
      );
    } catch (e, st) {
      _logger.severe("Error fetching template $templateId", e, st);
      return null;
    }
  }

  Future<int?> createTemplate(clientModels.Template newTemplate) async {
    const int? timesUsed = 0;
    try {
      final entry = TemplatesCompanion.insert(
        syncId: drift.Value(newTemplate.syncId),
        spreadSheetId: drift.Value(newTemplate.spreadSheetId),
        templateName: newTemplate.templateName,
        creatorParticipantId: newTemplate.creatorParticipantId,
        dateCreated: newTemplate.dateCreated ?? DateTime.now(),
        timesUsed: const drift.Value(timesUsed),
      );

      final id = await _appDatabase.into(_appDatabase.templates).insert(entry);
      _logger.info("Template created with ID: $id");
      return id;
    } catch (e, st) {
      _logger.severe("Error creating template", e, st);
      return null;
    }
  }

  Future<bool> deleteTemplate(int templateId) async {
    try {
      // Cascade delete accounts linked to this template
      await (_appDatabase.delete(_appDatabase.accounts)
        ..where((tbl) => tbl.templateId.equals(templateId)))
          .go();

      final deleted = await (_appDatabase.delete(_appDatabase.templates)
        ..where((tbl) => tbl.templateId.equals(templateId)))
          .go();

      _logger.info("Deleted template $templateId ($deleted rows)");
      return deleted > 0;
    } catch (e, st) {
      _logger.severe("Error deleting template $templateId", e, st);
      return false;
    }
  }
}

class AccountService {
  final AppDatabase _appDatabase;
  final Logger _logger = Logger("AccountService");

  AccountService(this._appDatabase);

  Future<List<models.Account>> getTemplateAccounts(
      int templateId, int participantId) async {
    try {
      final query = _appDatabase.select(_appDatabase.accounts)
        ..where((tbl) =>
        tbl.templateId.equals(templateId) &
        tbl.responsibleParticipantId.equals(participantId));
      final results = await query.get();

      return results
          .map((a) => models.Account(
        accountId: a.accountId,
        categoryId: a.categoryId,
        templateId: a.templateId,
        accountName: a.accountName,
        colorHex: a.colorHex,
        budgetAmount: a.budgetAmount,
        expenditureTotal: a.expenditureTotal ?? 0.0,
        responsibleParticipantId: a.responsibleParticipantId,
        dateCreated: a.dateCreated,
      ))
          .toList();
    } catch (e, st) {
      _logger.severe("Error fetching accounts for template $templateId", e, st);
      return [];
    }
  }

  /// Get all accounts for a specific category in a template
  Future<List<models.Account>> getAccountsForCategory(
      int templateId, int categoryId) async {
    try {
      final query = _appDatabase.select(_appDatabase.accounts)
        ..where((tbl) =>
        tbl.templateId.equals(templateId) &
        tbl.categoryId.equals(categoryId));
      final results = await query.get();

      return results
          .map((a) => models.Account(
        accountId: a.accountId,
        categoryId: a.categoryId,
        templateId: a.templateId,
        accountName: a.accountName,
        colorHex: a.colorHex,
        budgetAmount: a.budgetAmount,
        expenditureTotal: a.expenditureTotal ?? 0.0,
        responsibleParticipantId: a.responsibleParticipantId,
        dateCreated: a.dateCreated,
      ))
          .toList();
    } catch (e, st) {
      _logger.severe("Error fetching accounts for category $categoryId", e, st);
      return [];
    }
  }

  /// Get all accounts for a template (all categories)
  Future<List<models.Account>> getAllAccountsForTemplate(int templateId) async {
    try {
      final query = _appDatabase.select(_appDatabase.accounts)
        ..where((tbl) => tbl.templateId.equals(templateId));
      final results = await query.get();

      return results
          .map((a) => models.Account(
        accountId: a.accountId,
        categoryId: a.categoryId,
        accountName: a.accountName,
        templateId: a.templateId,
        colorHex: a.colorHex,
        budgetAmount: a.budgetAmount,
        expenditureTotal: a.expenditureTotal ?? 0.0,
        responsibleParticipantId: a.responsibleParticipantId,
        dateCreated: a.dateCreated,
      ))
          .toList();
    } catch (e, st) {
      _logger.severe("Error fetching all accounts for template $templateId", e, st);
      return [];
    }
  }

  Future<bool> modifyAccount(models.Account modifiedAccount) async {
    try {
      final update = AccountsCompanion(
        categoryId: drift.Value(modifiedAccount.categoryId),
        colorHex: drift.Value(modifiedAccount.colorHex),
        budgetAmount: drift.Value(modifiedAccount.budgetAmount),
        expenditureTotal: drift.Value(modifiedAccount.expenditureTotal),
        responsibleParticipantId:
        drift.Value(modifiedAccount.responsibleParticipantId),
      );

      final rows = await (_appDatabase.update(_appDatabase.accounts)
        ..where((tbl) => tbl.accountId.equals(modifiedAccount.accountId)))
          .write(update);

      return rows > 0;
    } catch (e, st) {
      _logger.severe("Error modifying account ${modifiedAccount.accountId}", e, st);
      return false;
    }
  }

  Future<bool> deleteAccount(int id) async {
    try {
      final deleted = await (_appDatabase.delete(_appDatabase.accounts)
        ..where((tbl) => tbl.accountId.equals(id)))
          .go();
      return deleted > 0;
    } catch (e, st) {
      _logger.severe("Error deleting account $id", e, st);
      return false;
    }
  }

  Future<int?> createAccount(clientModels.Account newAccount) async {
    try {
      final entry = AccountsCompanion.insert(
        categoryId: newAccount.categoryId,
        templateId: newAccount.templateId,
        accountName: newAccount.accountName,
        colorHex: newAccount.colorHex,
        budgetAmount: newAccount.budgetAmount,
        expenditureTotal: drift.Value(newAccount.expenditureTotal ?? 0.0),
        responsibleParticipantId: newAccount.responsibleParticipantId,
        dateCreated: newAccount.dateCreated ?? DateTime.now(),
      );

      final id = await _appDatabase.into(_appDatabase.accounts).insert(entry);
      _logger.info("Account created with ID: $id");
      return id;
    } catch (e, st) {
      _logger.severe("Error creating account", e, st);
      return null;
    }
  }
}

class CategoryService {
  final AppDatabase _appDatabase;
  final Logger _logger = Logger("CategoryService");

  CategoryService(this._appDatabase);

  Future<models.Category?> getCategoryAssociatedWithAccount(
      int accountId) async {
    try {
      final joinQuery = _appDatabase.select(_appDatabase.categories).join([
        drift.innerJoin(
          _appDatabase.accounts,
          _appDatabase.accounts.categoryId
              .equalsExp(_appDatabase.categories.categoryId),
        )
      ])
        ..where(_appDatabase.accounts.accountId.equals(accountId));

      final row = await joinQuery.getSingleOrNull();
      if (row == null) return null;
      final c = row.readTable(_appDatabase.categories);

      return models.Category(
        categoryId: c.categoryId,
        templateId: c.templateId,
        categoryName: c.categoryName,
        colorHex: c.colorHex,
      );
    } catch (e, st) {
      _logger.severe("Error fetching category for account $accountId", e, st);
      return null;
    }
  }

  Future<List<models.Category>> getAllCategories([int? categoryId]) async {
    try {
      final query = _appDatabase.select(_appDatabase.categories);
      if (categoryId != null) {
        query.where((tbl) => tbl.categoryId.equals(categoryId));
      }
      final results = await query.get();

      return results
          .map((c) => models.Category(
        categoryId: c.categoryId,
        templateId: c.templateId,
        categoryName: c.categoryName,
        colorHex: c.colorHex,
      ))
          .toList();
    } catch (e, st) {
      _logger.severe("Error fetching categories", e, st);
      return [];
    }
  }

  /// Get all categories for a specific template
  Future<List<models.Category>> getCategoriesForTemplate(int templateId) async {
    debugPrint("Fetching categories for template $templateId");
    try {
      final query = _appDatabase.select(_appDatabase.categories)
        ..where((tbl) => tbl.templateId.equals(templateId));
      final results = await query.get();
      debugPrint("Fetched categories: ${results.length}");
      debugPrint("Sampled category: ${results[0]}");
      return results
          .map((c) => models.Category(
        categoryId: c.categoryId,
        templateId: c.templateId,
        categoryName: c.categoryName,
        colorHex: c.colorHex,
      ))
          .toList();
    } catch (e, st) {
      _logger.severe("Error fetching categories for template $templateId", e, st);
      return [];
    }
  }

  Future<int?> createCategory(clientModels.Category newCategory) async {
    print("Attempting to create category. Details:\n Name: ${newCategory.categoryName} \n Template ID: ${newCategory.templateId} \n Color: ${newCategory.colorHex}");
    try {
      final entry = CategoriesCompanion.insert(
        categoryName: newCategory.categoryName,
        templateId: newCategory.templateId,
        colorHex: newCategory.colorHex,
      );
      final id = await _appDatabase.into(_appDatabase.categories).insert(entry);
      _logger.info("Category created with ID: $id");
      return id;
    } catch (e, st) {
      _logger.severe("Error creating category", e, st);
      return null;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      // First, delete all accounts in this category
      await (_appDatabase.delete(_appDatabase.accounts)
        ..where((tbl) => tbl.categoryId.equals(categoryId)))
          .go();

      // Then delete the category
      final deleted = await (_appDatabase.delete(_appDatabase.categories)
        ..where((tbl) => tbl.categoryId.equals(categoryId)))
          .go();

      _logger.info("Deleted category $categoryId and its accounts");
      return deleted > 0;
    } catch (e, st) {
      _logger.severe("Error deleting category $categoryId", e, st);
      return false;
    }
  }
}
