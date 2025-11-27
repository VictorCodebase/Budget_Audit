import 'package:flutter/painting.dart'; // For Color
import './models.dart' as models;
import 'package:equatable/equatable.dart';

/// Represents a document uploaded by the user before processing
class UploadedDocument extends Equatable {
  final String id;
  final String fileName;
  final String filePath;
  final String? password;
  final int ownerParticipantId;
  final FinancialInstitution institution;
  final DateTime uploadedAt;

  const UploadedDocument({
    required this.id,
    required this.fileName,
    required this.filePath,
    this.password,
    required this.ownerParticipantId,
    required this.institution,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [
        id,
        fileName,
        filePath,
        password,
        ownerParticipantId,
        institution,
        uploadedAt,
      ];
}

/// Financial institutions supported by the app
enum FinancialInstitution {
  hsbc,
  equity,
  mpesa,
  custom;

  String get displayName {
    switch (this) {
      case FinancialInstitution.hsbc:
        return 'HSBC';
      case FinancialInstitution.equity:
        return 'Equity';
      case FinancialInstitution.mpesa:
        return 'M-PESA';
      case FinancialInstitution.custom:
        return 'Custom';
    }
  }
  String get logoPath {
    switch (this) {
      case FinancialInstitution.hsbc:
        return 'assets/banks/hsbc.png';
      case FinancialInstitution.equity:
        return 'assets/banks/equity.png';
      case FinancialInstitution.mpesa:
        return 'assets/banks/mpesa.png';
      case FinancialInstitution.custom:
        return 'assets/banks/custom.png';
    }
  }
}


/// Represents a transaction extracted from a PDF but not yet saved to database
class ParsedTransaction extends Equatable {
  final String id; // Temporary ID for UI tracking
  final DateTime date;
  final String vendorName;
  final double amount;
  final String? originalDescription;
  final String? category;
  final String? account;
  final String? reason;
  final bool useMemory; // Maps to "Use Memory" checkbox

  const ParsedTransaction({
    required this.id,
    required this.date,
    required this.vendorName,
    required this.amount,
    this.originalDescription,
    this.category,
    this.account,
    this.reason,
    this.useMemory = false,
  });

  ParsedTransaction copyWith({
    String? id,
    DateTime? date,
    String? vendorName,
    double? amount,
    String? originalDescription,
    String? category,
    String? account,
    String? reason,
    bool? useMemory,
  }) {
    return ParsedTransaction(
      id: id ?? this.id,
      date: date ?? this.date,
      vendorName: vendorName ?? this.vendorName,
      amount: amount ?? this.amount,
      originalDescription: originalDescription ?? this.originalDescription,
      category: category ?? this.category,
      account: account ?? this.account,
      reason: reason ?? this.reason,
      useMemory: useMemory ?? this.useMemory,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        vendorName,
        amount,
        category,
        originalDescription,
        account,
        reason,
        useMemory,
      ];
}



/// Result of parsing a document
class ParseResult extends Equatable {
  final bool success;
  final String? errorMessage;
  final List<ParsedTransaction> transactions;
  final UploadedDocument document;

  const ParseResult({
    required this.success,
    this.errorMessage,
    required this.transactions,
    required this.document,
  });

  @override
  List<Object?> get props => [success, errorMessage, transactions, document];
}

/// Validation result for document parseability
class ValidationResult extends Equatable {
  final bool canParse;
  final String? errorMessage;
  final List<String> missingCheckpoints;

  const ValidationResult({
    required this.canParse,
    this.errorMessage,
    this.missingCheckpoints = const [],
  });

  const ValidationResult.success()
      : canParse = true,
        errorMessage = null,
        missingCheckpoints = const [];

  const ValidationResult.failure({
    required String error,
    List<String> missing = const [],
  })  : canParse = false,
        errorMessage = error,
        missingCheckpoints = missing;

  @override
  List<Object?> get props => [canParse, errorMessage, missingCheckpoints];
}


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