// Add these extensions to your models.dart file or create a separate file

import 'models.dart';

/// JSON serialization extension for Participant
extension ParticipantJson on Participant {
  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
      'role': role.toString().split('.').last,
      'email': email,
    };
  }

  static Participant fromJson(Map<String, dynamic> json) {
    return Participant(
      participantId: json['participantId'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      nickname: json['nickname'] as String?,
      role: _parseRole(json['role'] as String),
      email: json['email'] as String,
    );
  }

  static Role _parseRole(String roleString) {
    switch (roleString) {
      case 'manager':
        return Role.manager;
      case 'participant':
        return Role.participant;
      default:
        return Role.participant;
    }
  }
}

/// JSON serialization extension for Template
extension TemplateJson on Template {
  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'templateName': templateName,
      'creatorParticipantId': creatorParticipantId,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  static Template fromJson(Map<String, dynamic> json) {
    return Template(
      templateId: json['templateId'] as int,
      templateName: json['templateName'] as String,
      creatorParticipantId: json['creatorParticipantId'] as int,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );
  }
}

/// JSON serialization extension for Category (if you need to cache categories)
extension CategoryJson on Category {
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'colorHex': colorHex,
      'templateId': templateId,
    };
  }

  static Category fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      colorHex: json['colorHex'] as String,
      templateId: json['templateId'] as int,
    );
  }
}

/// JSON serialization extension for Account (if you need to cache accounts)
extension AccountJson on Account {
  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'categoryId': categoryId,
      'templateId': templateId,
      'accountName': accountName,
      'colorHex': colorHex,
      'budgetAmount': budgetAmount,
      'expenditureTotal': expenditureTotal,
      'responsibleParticipantId': responsibleParticipantId,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'] as int,
      categoryId: json['categoryId'] as int,
      templateId: json['templateId'] as int,
      accountName: json['accountName'] as String,
      colorHex: json['colorHex'] as String,
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      expenditureTotal: (json['expenditureTotal'] as num).toDouble(),
      responsibleParticipantId: json['responsibleParticipantId'] as int,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );
  }
}