import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import '../models/models.dart' as models;
import '../models/client_models.dart' as client_models;
import '../data/database.dart';
import 'package:drift/drift.dart' as drift;
// import 'transaction_service.dart';

class BudgetService {
  final TemplateService _templateService;
  final AccountService _accountService;
  final CategoryService _categoryService;
  final TransactionService _transactionService;

  BudgetService(AppDatabase db)
      : _templateService = TemplateService(db),
        _accountService = AccountService(db),
        _categoryService = CategoryService(db),
        _transactionService = TransactionService(db);

  TemplateService get templateService => _templateService;
  AccountService get accountService => _accountService;
  CategoryService get categoryService => _categoryService;
  TransactionService get transactionService => _transactionService;
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
                period: t.period,
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
        period: result.period,
      );
    } catch (e, st) {
      _logger.severe("Error fetching template $templateId", e, st);
      return null;
    }
  }

  Future<int?> createTemplate(client_models.Template newTemplate) async {
    const int? timesUsed = 0;
    try {
      final entry = TemplatesCompanion.insert(
        syncId: drift.Value(newTemplate.syncId),
        spreadSheetId: drift.Value(newTemplate.spreadSheetId),
        templateName: newTemplate.templateName,
        creatorParticipantId: newTemplate.creatorParticipantId,
        dateCreated: newTemplate.dateCreated ?? DateTime.now(),
        timesUsed: const drift.Value(timesUsed),
        period: newTemplate.period,
      );

      final id = await _appDatabase.into(_appDatabase.templates).insert(entry);
      _logger.info("Template created with ID: $id");
      return id;
    } catch (e, st) {
      _logger.severe("Error creating template", e, st);
      return null;
    }
  }

  Future<bool> updateTemplate(models.Template template) async {
    try {
      final updated = await (_appDatabase.update(_appDatabase.templates)
            ..where((t) => t.templateId.equals(template.templateId)))
          .write(TemplatesCompanion(
        templateName: drift.Value(template.templateName),
        period: drift.Value(template.period),
        // Add other fields if necessary, but typically we only update name/period here
      ));

      _logger.info("Updated template ${template.templateId} ($updated rows)");
      return updated > 0;
    } catch (e, st) {
      _logger.severe("Error updating template ${template.templateId}", e, st);
      return false;
    }
  }

  Future<bool> deleteTemplate(int templateId) async {
    return _appDatabase.transaction(() async {
      try {
        // 0. Fetch Account IDs to clean up their children
        final accounts = await (_appDatabase.select(_appDatabase.accounts)
              ..where((tbl) => tbl.templateId.equals(templateId)))
            .get();
        final accountIds = accounts.map((a) => a.accountId).toList();

        if (accountIds.isNotEmpty) {
          // 0a. Delete Transactions linked to these accounts
          await (_appDatabase.delete(_appDatabase.transactions)
                ..where((tbl) => tbl.accountId.isIn(accountIds)))
              .go();

          // 0b. Delete VendorMatchHistories linked to these accounts
          await (_appDatabase.delete(_appDatabase.vendorMatchHistories)
                ..where((tbl) => tbl.accountId.isIn(accountIds)))
              .go();
        }

        // 1. Delete Accounts
        await (_appDatabase.delete(_appDatabase.accounts)
              ..where((tbl) => tbl.templateId.equals(templateId)))
            .go();

        // 2. Delete Categories
        await (_appDatabase.delete(_appDatabase.categories)
              ..where((tbl) => tbl.templateId.equals(templateId)))
            .go();

        // 3. Delete Template Participants
        await (_appDatabase.delete(_appDatabase.templateParticipants)
              ..where((tbl) => tbl.templateId.equals(templateId)))
            .go();

        // 4. Delete Chart Snapshots
        await (_appDatabase.delete(_appDatabase.chartSnapshots)
              ..where((tbl) => tbl.associatedTemplate.equals(templateId)))
            .go();

        // 5. Finally, delete the Template
        final deleted = await (_appDatabase.delete(_appDatabase.templates)
              ..where((tbl) => tbl.templateId.equals(templateId)))
            .go();

        _logger.info("Deleted template $templateId and all dependencies");
        return deleted > 0;
      } catch (e, st) {
        _logger.severe("Error deleting template $templateId", e, st);
        // Rethrow to rollback transaction
        throw e;
      }
    });
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
                responsibleParticipantId:
                    a.responsibleParticipantId, // Now nullable
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
                responsibleParticipantId:
                    a.responsibleParticipantId, // Now nullable
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
                responsibleParticipantId:
                    a.responsibleParticipantId, // Now nullable
                dateCreated: a.dateCreated,
              ))
          .toList();
    } catch (e, st) {
      _logger.severe(
          "Error fetching all accounts for template $templateId", e, st);
      return [];
    }
  }

  /// Get total budget amount for a template
  Future<double> getTemplateTotalBudget(int templateId) async {
    try {
      final query = _appDatabase.select(_appDatabase.accounts)
        ..where((tbl) => tbl.templateId.equals(templateId));
      final accounts = await query.get();

      double total = 0.0;
      for (final account in accounts) {
        total += account.budgetAmount;
      }
      return total;
    } catch (e, st) {
      _logger.severe(
          "Error calculating total budget for template $templateId", e, st);
      return 0.0;
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
      _logger.severe(
          "Error modifying account ${modifiedAccount.accountId}", e, st);
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

  Future<int?> createAccount(client_models.Account newAccount) async {
    try {
      final entry = AccountsCompanion.insert(
        categoryId: newAccount.categoryId,
        templateId: newAccount.templateId,
        accountName: newAccount.accountName,
        colorHex: newAccount.colorHex,
        budgetAmount: newAccount.budgetAmount,
        expenditureTotal: drift.Value(newAccount.expenditureTotal ?? 0.0),
        responsibleParticipantId:
            drift.Value(newAccount.responsibleParticipantId), // Now nullable
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
      _logger.severe(
          "Error fetching categories for template $templateId", e, st);
      return [];
    }
  }

  Future<int?> createCategory(client_models.Category newCategory) async {
    print(
        "Attempting to create category. Details:\n Name: ${newCategory.categoryName} \n Template ID: ${newCategory.templateId} \n Color: ${newCategory.colorHex}");
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

  Future<bool> updateCategory(models.Category category) async {
    try {
      final updated = await (_appDatabase.update(_appDatabase.categories)
            ..where((t) => t.categoryId.equals(category.categoryId)))
          .write(CategoriesCompanion(
        categoryName: drift.Value(category.categoryName),
        colorHex: drift.Value(category.colorHex),
        templateId: drift.Value(category.templateId),
      ));

      _logger.info("Updated category ${category.categoryId} ($updated rows)");
      return updated > 0;
    } catch (e, st) {
      _logger.severe("Error updating category ${category.categoryId}", e, st);
      return false;
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

class TransactionService {
  final AppDatabase _appDatabase;
  final Logger _logger = Logger("TransactionService");

  TransactionService(this._appDatabase);

  /// Fetch all known vendors
  Future<List<models.Vendor>> getAllVendors() async {
    try {
      final vendors = await _appDatabase.select(_appDatabase.vendors).get();
      return vendors
          .map((v) => models.Vendor(
                vendorId: v.vendorId,
                vendorName: v.vendorName,
              ))
          .toList();
    } catch (e, st) {
      _logger.severe("Error fetching vendors", e, st);
      return [];
    }
  }

  /// Fetch match history for a specific vendor
  Future<List<VendorMatchHistory>> getVendorMatchHistory(int vendorId) async {
    try {
      final query = _appDatabase.select(_appDatabase.vendorMatchHistories)
        ..where((tbl) => tbl.vendorId.equals(vendorId))
        ..orderBy([
          (t) => drift.OrderingTerm(
              expression: t.lastUsed, mode: drift.OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e, st) {
      _logger.severe(
          "Error fetching match history for vendor $vendorId", e, st);
      return [];
    }
  }

  /// Fetch all transactions for a list of account IDs
  Future<List<models.Transaction>> getTransactionsForAccounts(
      List<int> accountIds) async {
    try {
      if (accountIds.isEmpty) return [];

      final query = _appDatabase.select(_appDatabase.transactions)
        ..where((tbl) => tbl.accountId.isIn(accountIds))
        ..orderBy([
          (t) => drift.OrderingTerm(
              expression: t.date, mode: drift.OrderingMode.desc)
        ]);

      final results = await query.get();

      return results
          .map((t) => models.Transaction(
                transactionId: t.transactionId,
                syncId: t.syncId,
                accountId: t.accountId,
                isIgnored: t.isIgnored,
                date: t.date,
                vendorId: t.vendorId,
                amount: t.amount,
                participantId: t.participantId,
                editorParticipantId: t.editorParticipantId,
                reason: t.reason,
              ))
          .toList();
    } catch (e, st) {
      _logger.severe('Error fetching transactions for accounts', e, st);
      return [];
    }
  }

  /// Fetch all transactions for a specific template
  Future<List<models.Transaction>> getTransactionsForTemplate(
      int templateId) async {
    try {
      // First, get all accounts for this template
      final accountsQuery = _appDatabase.select(_appDatabase.accounts)
        ..where((tbl) => tbl.templateId.equals(templateId));
      final accounts = await accountsQuery.get();
      final accountIds = accounts.map((a) => a.accountId).toList();

      // Then get all transactions for these accounts
      return await getTransactionsForAccounts(accountIds);
    } catch (e, st) {
      _logger.severe(
          'Error fetching transactions for template $templateId', e, st);
      return [];
    }
  }

  /// Deletes a vendor match history entry
  Future<bool> deleteVendorMatchHistory({
    required int vendorId,
    required int accountId,
    required int participantId,
  }) async {
    try {
      final deleted =
          await (_appDatabase.delete(_appDatabase.vendorMatchHistories)
                ..where((t) =>
                    t.vendorId.equals(vendorId) &
                    t.accountId.equals(accountId) &
                    t.participantId.equals(participantId)))
              .go();

      return deleted > 0;
    } catch (e) {
      _logger.severe('Error deleting vendor match history', e);
      return false;
    }
  }

  /// Record a vendor match (create or update stats)
  Future<void> recordVendorMatch({
    required int vendorId,
    required int accountId,
    required int participantId,
  }) async {
    try {
      // Check if exists
      final existing =
          await (_appDatabase.select(_appDatabase.vendorMatchHistories)
                ..where((tbl) =>
                    tbl.vendorId.equals(vendorId) &
                    tbl.accountId.equals(accountId) &
                    tbl.participantId.equals(participantId)))
              .getSingleOrNull();

      if (existing != null) {
        // Update
        await (_appDatabase.update(_appDatabase.vendorMatchHistories)
              ..where(
                  (tbl) => tbl.vendorMatchId.equals(existing.vendorMatchId)))
            .write(VendorMatchHistoriesCompanion(
          useCount: drift.Value(existing.useCount + 1),
          lastUsed: drift.Value(DateTime.now()),
        ));
      } else {
        // Insert
        await _appDatabase.into(_appDatabase.vendorMatchHistories).insert(
              VendorMatchHistoriesCompanion.insert(
                vendorId: vendorId,
                accountId: accountId,
                participantId: participantId,
                lastUsed: DateTime.now(),
                useCount: const drift.Value(1),
              ),
            );
      }
    } catch (e, st) {
      _logger.severe("Error recording vendor match", e, st);
    }
  }

  /// Create a new transaction in the database
  Future<int?> createTransaction({
    required int syncId,
    required int accountId,
    required DateTime date,
    required int vendorId,
    required double amount,
    required int participantId,
    required int editorParticipantId,
    String? reason,
    bool isIgnored = false,
  }) async {
    try {
      final transactionId =
          await _appDatabase.into(_appDatabase.transactions).insert(
                TransactionsCompanion.insert(
                  syncId: syncId,
                  accountId: accountId,
                  date: date,
                  vendorId: vendorId,
                  amount: amount,
                  participantId: participantId,
                  editorParticipantId: editorParticipantId,
                  reason: drift.Value(reason),
                  isIgnored: drift.Value(isIgnored),
                ),
              );

      _logger.info(
          'Transaction created: ID=$transactionId, vendor=$vendorId, amount=$amount');
      return transactionId;
    } catch (e, st) {
      _logger.severe('Error creating transaction', e, st);
      return null;
    }
  }

  /// Get or create a sync log entry for batch operations
  Future<int> getOrCreateSyncLog() async {
    //throw UnimplementedError("Synclog date not implemented  ");
    try {
      final syncId = await _appDatabase.into(_appDatabase.syncLog).insert(
            // TODO: add date to synclog in db
            SyncLogCompanion.insert(
              dateSynced: DateTime.now(),
              syncDirection: models.SyncDirection.upload.value,
              synced: false,
              success: false,
              sheetUrl: "",

              // Add other required fields based on your SyncLog table structure
            ),
          );
      return syncId;
    } catch (e, st) {
      _logger.severe('Error creating sync log', e, st);
      rethrow;
    }
  }

  /// Create a new vendor
  Future<int?> createVendor(String name) async {
    try {
      final id = await _appDatabase.into(_appDatabase.vendors).insert(
            VendorsCompanion.insert(vendorName: name),
          );
      return id;
    } catch (e, st) {
      _logger.severe("Error creating vendor $name", e, st);
      return null;
    }
  }
}
