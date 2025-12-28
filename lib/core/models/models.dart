import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart'; // For Color

// 1.1. Participants Model
class Participant extends Equatable {
  final int participantId;
  final String firstName;
  final String? lastName;
  final String? nickname;
  final Role role;
  final String email;
  // PasswordHash is usually not exposed in the app model

  Participant({
    required this.participantId,
    required this.firstName,
    this.lastName,
    this.nickname,
    required this.role,
    required this.email,
  });

  @override
  List<Object?> get props => [
        participantId,
        firstName,
        lastName,
        nickname,
        role,
        email,
      ];
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

// 1.2. Categories Model
class Category extends Equatable {
  final int categoryId;
  final int templateId;
  final String categoryName;
  final String colorHex;

  Color get color =>
      Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);

  Category({
    required this.categoryId,
    required this.templateId,
    required this.categoryName,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [
        categoryId,
        templateId,
        categoryName,
        colorHex,
      ];
}

// 1.7. Templates Model
class Template extends Equatable {
  final int templateId;
  final int? syncId;
  final String? spreadSheetId;
  final String templateName;
  final int creatorParticipantId;
  final DateTime dateCreated;
  final int? timesUsed;
  final String period;

  Template({
    required this.templateId,
    this.syncId,
    this.spreadSheetId,
    required this.templateName,
    required this.creatorParticipantId,
    required this.dateCreated,
    this.timesUsed,
    required this.period,
  });

  @override
  List<Object?> get props => [
        templateId,
        syncId,
        spreadSheetId,
        templateName,
        creatorParticipantId,
        dateCreated,
        timesUsed,
        period,
      ];
}

// 1.3. Accounts Model
class Account extends Equatable {
  final int accountId;
  final int categoryId;
  final int templateId;
  final String accountName;
  final String colorHex;
  final double budgetAmount;
  final double expenditureTotal;
  final int? responsibleParticipantId;
  final DateTime dateCreated;

  // Calculated Field from NOTE:
  double get balance => budgetAmount - expenditureTotal;

  Color get color =>
      Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);

  Account({
    required this.accountId,
    required this.categoryId,
    required this.templateId,
    required this.accountName,
    required this.colorHex,
    required this.budgetAmount,
    required this.expenditureTotal,
    this.responsibleParticipantId,
    required this.dateCreated,
  });

  @override
  List<Object?> get props => [
        accountId,
        categoryId,
        templateId,
        accountName,
        colorHex,
        budgetAmount,
        expenditureTotal,
        responsibleParticipantId,
        dateCreated,
      ];
}

// 1.5. Vendors Model
class Vendor extends Equatable {
  final int vendorId;
  final String vendorName;

  Vendor({
    required this.vendorId,
    required this.vendorName,
  });

  @override
  List<Object?> get props => [vendorId, vendorName];
}

// 1.9 SyncLog Model
class SyncLogEntry extends Equatable {
  final int syncId;
  final int? transactionId;
  final SyncDirection syncDirection;
  final DateTime dateSynced;
  final bool synced;
  final bool success;
  final String? errorMessage;
  final String sheetUrl;
  final int associatedTemplate;

  SyncLogEntry({
    required this.syncId,
    this.transactionId,
    required this.syncDirection,
    required this.dateSynced,
    required this.synced,
    required this.success,
    this.errorMessage,
    required this.sheetUrl,
    required this.associatedTemplate,
  });

  @override
  List<Object?> get props => [
        syncId,
        transactionId,
        syncDirection,
        dateSynced,
        synced,
        success,
        errorMessage,
        sheetUrl,
        associatedTemplate,
      ];
}

enum SyncDirection {
  upload('upload'),
  download('download');

  final String value;
  const SyncDirection(this.value);

  static SyncDirection fromString(String syncDirection) {
    return SyncDirection.values.firstWhere(
      (sd) => sd.value.toLowerCase() == syncDirection.toLowerCase(),
      orElse: () =>
          throw ArgumentError('Invalid sync direction: $syncDirection'),
    );
  }
}

// 1.4. Transactions Model
class Transaction extends Equatable {
  final int transactionId;
  final int syncId;
  final int accountId;
  final bool isIgnored;
  final DateTime date;
  final int vendorId;
  final double amount;
  final int participantId;
  final int editorParticipantId;
  final String? reason;

  Transaction({
    required this.transactionId,
    required this.syncId,
    required this.accountId,
    required this.isIgnored,
    required this.date,
    required this.vendorId,
    required this.amount,
    required this.participantId,
    required this.editorParticipantId,
    this.reason,
  });

  @override
  List<Object?> get props => [
        transactionId,
        syncId,
        accountId,
        isIgnored,
        date,
        vendorId,
        amount,
        participantId,
        editorParticipantId,
        reason,
      ];
}

// 1.10 VendorMatchHistory Model
class VendorMatchHistory extends Equatable {
  final int vendorMatchId;
  final int vendorId;
  final int accountId;
  final int participantId;
  final int useCount;
  final DateTime lastUsed;

  VendorMatchHistory({
    required this.vendorMatchId,
    required this.vendorId,
    required this.accountId,
    required this.participantId,
    required this.useCount,
    required this.lastUsed,
  });

  @override
  List<Object?> get props => [
        vendorMatchId,
        vendorId,
        accountId,
        participantId,
        useCount,
        lastUsed,
      ];
}

// (Other models like TransactionEditHistory, VendorPreference,
// ParticipantIncome, TemplateParticipant, ChartSnapshot would follow a similar structure)
