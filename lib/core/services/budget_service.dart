import 'dart:async';

import 'package:googleapis/admob/v1.dart';
import 'package:logging/logging.dart';

import '../models/models.dart' as models;
import '../models/client_models.dart' as clientModels;
import '../data/databases.dart';

class BudgetService{
  final TemplateService _templateService;
  final AccountService _accountService;
  final CategoryService _categoryService;

  BudgetService(AppDatabase db):
      _templateService = TemplateService(db),
      _accountService = AccountService(db),
      _categoryService = CategoryService(db);

}


class TemplateService {
  final AppDatabase _appDatabase;
  final Logger _logger = Logger("BudgetService");

  TemplateService(AppDatabase this._appDatabase);

  // See all templates. Allow flexibility for someone to check the templates and fetch related accounts
  Future<List<models.Template>> getAllTemplates() async {

    _logger.warning("getAllTemplates returned a generic response for development only!");
    return [
      models.Template(
        templateId: 1,
        syncId: 1232,
        spreadSheetId: '1234321sd2',
        templateName: "January Template",
        creatorParticipantId: 1,
        dateCreated: DateTime.now(),
        timesUsed: 2,
      ),
      models.Template(
        templateId: 2,
        syncId: 1232,
        spreadSheetId: '1234321sd2',
        templateName: "January Template",
        creatorParticipantId: 1,
        dateCreated: DateTime.now(),
        timesUsed: 2,
      )
    ];
  }

  // cascade delete a template and all associated accounts
  Future<bool> deleteTemplate(int templateId) async {

    _logger.warning("deleteTemplate returned a generic TRUE response for development only!");
    return true;
  }

  Future<int> createTemplate(clientModels.Template newTemplate) async {
    final int timesUsed = 0;
    final int templateId = 1; //TODO: actually fetch the id

    _logger.warning("createTemplate returned a generic response for development only!");
    return templateId;
  }


}

class AccountService {
  final AppDatabase _appDatabase;
  final Logger _logger = Logger("BudgetService");

  AccountService(AppDatabase this._appDatabase);

  // Get all accounts created for a template
  Future<List<models.Account>> getTemplateAccounts(int templateId, int participantId) async {

    _logger.warning("getTemplateAccounts returned a generic response for development only!");
    return[
      models.Account(
        accountId: 1,
        categoryId: 1,
        templateId: 1,
        colorHex: '#000000',
        budgetAmount: 200.00,
        expenditureTotal: 200.00,
        responsibleParticipantId: 2,
        dateCreated: DateTime.now(),
      ),
      models.Account(
        accountId: 2,
        categoryId: 2,
        templateId: 1,
        colorHex: '#000000',
        budgetAmount: 200.00,
        expenditureTotal: 200.00,
        responsibleParticipantId: 2,
        dateCreated: DateTime.now(),
      ),
      models.Account(
        accountId: 3,
        categoryId: 1,
        templateId: 1,
        colorHex: '#000000',
        budgetAmount: 200.00,
        expenditureTotal: 200.00,
        responsibleParticipantId: 2,
        dateCreated: DateTime.now(),
      )
    ];
  }

  Future<bool> modifyAccount(models.Account modifiedAccount) async {

    // TODO: Have a mechanism to ensure an account's template id is not changed by mistake
    _logger.warning("modifyAccount returned a generic TRUE response for development only!");
    return true;
  }

  Future<bool> deleteAccount(int id) async {

    _logger.warning("deleteAccount returned a generic TRUE response for development only!");
    return true;
  }

  Future<int> createAccount(clientModels.Account newAccount) async {

    _logger.warning("createAccount returned a generic TRUE response for development only!");
    final accountId = 0; //TODO: this is what is returned after the recod is created
    return accountId;
  }




}

class CategoryService {
  final AppDatabase _appDatabase;
  final Logger _logger = Logger("BudgetService");

  CategoryService(this._appDatabase);

  // get all categories whose information is required to arrange accounts. This method is meant to be iteratively called.
  Future<models.Category> getCategoryAssociatedWithAccount(int accountId) async {

    _logger.warning("getCategoryAssociatedWithAccount returned a generic response for development only!");
    return models.Category(categoryId: 1, categoryName: "Missions and Giving", colorHex: "#213300");
  }

  // read categories
  Future<List<models.Category>> getAllCategories(int? categoryId) async {
  //TODO: if categoryId, retrieve the rewuested category, if no id, return all
  _logger.warning("getAllCategories returned a generic response for development only!");
  return [
    models.Category(
      categoryId: 01,
      categoryName: "Giving and Ministry",
      colorHex: "#234355"
    ),
    models.Category(
        categoryId: 02,
        categoryName: "Family transport",
        colorHex: "#234155"
    ),
    models.Category(
        categoryId: 03,
        categoryName: "Trips",
        colorHex: "#233355"
    )
  ];
  }

  // create category
  Future<bool> createCategory(clientModels.Category newCategory) async {

    _logger.warning("createCategory returned a generic response for development only!");
    return true;
  }

  // delete categpry
  Future<bool> deleteCategory(int categoryId) async {

    _logger.warning("deleteCategory returned a generic TRUE response for development only!");
    return true;
  }

}



