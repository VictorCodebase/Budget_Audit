import 'package:flutter/painting.dart'; // For Color
import './models.dart' as models;

class Account {
  final int categoryId;
  final int templateId;
  final String colorHex;
  final String accountName;
  final double budgetAmount;
  final double expenditureTotal;
  final int responsibleParticipantId;
  final DateTime dateCreated;

  // Calculated Field from NOTE:
  double get balance => budgetAmount - expenditureTotal;

  Color get color => Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);


  Account({
    required this.categoryId,
    required this.templateId,
    required this.accountName,
    required this.colorHex,
    required this.budgetAmount,
    required this.expenditureTotal,
    required this.responsibleParticipantId,
    required this.dateCreated,
  });
}

// 1.7. Templates Model
class Template {
  final int? syncId;
  final String? spreadSheetId;
  final String templateName;
  final int creatorParticipantId;
  final DateTime dateCreated;

  Template({
    this.syncId,
    this.spreadSheetId,
    required this.templateName,
    required this.creatorParticipantId,
    required this.dateCreated,
  });
}

class Category {
  final String categoryName;
  final String colorHex;
  final int templateId;

  Color get color => Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);

  Category({
    required this.categoryName,
    required this.colorHex,
    required this.templateId,
  });
}


class Participant {
  final String firstName;
  final String? lastName;
  final String? nickname;
  final Role role;
  final String email;
  // PasswordHash is usually not exposed in the app model

  Participant({
    required this.firstName,
    this.lastName,
    this.nickname,
    required this.role,
    required this.email,
  });
}

enum Role {
  participant('participant'),
  editor('editor'),
  manager('manager');

  final String value;
  const Role(this.value);

  static Role fromString(String role) {
    return Role.values.firstWhere(
          (r) => r.value.toLowerCase() == role.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid role: $role'),
    );
  }
}

class CategoryData {
  String id;
  String name;
  Color color;
  List<AccountData> accounts;
  String? validationError;

  CategoryData({
    required this.id,
    required this.name,
    required this.color,
    List<AccountData>? accounts,
    this.validationError,
  }) : accounts = accounts ?? [];

  double get totalBudget =>
      accounts.fold(0.0, (sum, account) => sum + account.budgetAmount);

  Set<models.Participant> get allParticipants =>
      accounts.expand((a) => a.participants).toSet();

  CategoryData copyWith({
    String? id,
    String? name,
    Color? color,
    List<AccountData>? accounts,
    String? validationError,
  }) {
    return CategoryData(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      accounts: accounts ?? this.accounts,
      validationError: validationError,
    );
  }
}

class AccountData {
  String id;
  String name;
  double budgetAmount;
  List<models.Participant> participants;
  Color color;
  String? validationError;

  AccountData({
    required this.id,
    required this.name,
    required this.budgetAmount,
    List<models.Participant>? participants,
    required this.color,
    this.validationError,
  }) : participants = participants ?? [];

  AccountData copyWith({
    String? id,
    String? name,
    double? budgetAmount,
    List<models.Participant>? participants,
    Color? color,
    String? validationError,
  }) {
    return AccountData(
      id: id ?? this.id,
      name: name ?? this.name,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      participants: participants ?? this.participants,
      color: color ?? this.color,
      validationError: validationError,
    );
  }
}