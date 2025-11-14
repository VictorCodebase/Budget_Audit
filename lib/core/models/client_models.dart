import 'package:flutter/painting.dart'; // For Color


class Account {
  final int categoryId;
  final int templateId;
  final String colorHex;
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