// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ParticipantsTable extends Participants
    with drift.TableInfo<$ParticipantsTable, Participant> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _participantIdMeta =
      const drift.VerificationMeta('participantId');
  @override
  late final drift.GeneratedColumn<int> participantId =
      drift.GeneratedColumn<int>('participant_id', aliasedName, false,
          hasAutoIncrement: true,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _firstNameMeta =
      const drift.VerificationMeta('firstName');
  @override
  late final drift.GeneratedColumn<String> firstName =
      drift.GeneratedColumn<String>('first_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 255),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _lastNameMeta =
      const drift.VerificationMeta('lastName');
  @override
  late final drift.GeneratedColumn<String> lastName =
      drift.GeneratedColumn<String>('last_name', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
          type: DriftSqlType.string,
          requiredDuringInsert: false);
  static const drift.VerificationMeta _nickNameMeta =
      const drift.VerificationMeta('nickName');
  @override
  late final drift.GeneratedColumn<String> nickName =
      drift.GeneratedColumn<String>('nick_name', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: false);
  static const drift.VerificationMeta _roleMeta =
      const drift.VerificationMeta('role');
  @override
  late final drift.GeneratedColumn<String> role = drift.GeneratedColumn<String>(
      'role', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const drift.VerificationMeta _emailMeta =
      const drift.VerificationMeta('email');
  @override
  late final drift.GeneratedColumn<String> email =
      drift.GeneratedColumn<String>('email', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 255),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const drift.VerificationMeta _pwdhashMeta =
      const drift.VerificationMeta('pwdhash');
  @override
  late final drift.GeneratedColumn<String> pwdhash =
      drift.GeneratedColumn<String>('pwdhash', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 60, maxTextLength: 60),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns =>
      [participantId, firstName, lastName, nickName, role, email, pwdhash];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<Participant> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('nick_name')) {
      context.handle(_nickNameMeta,
          nickName.isAcceptableOrUnknown(data['nick_name']!, _nickNameMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('pwdhash')) {
      context.handle(_pwdhashMeta,
          pwdhash.isAcceptableOrUnknown(data['pwdhash']!, _pwdhashMeta));
    } else if (isInserting) {
      context.missing(_pwdhashMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {participantId};
  @override
  Participant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Participant(
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      nickName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nick_name']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      pwdhash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pwdhash'])!,
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class Participant extends drift.DataClass
    implements drift.Insertable<Participant> {
  final int participantId;
  final String firstName;
  final String? lastName;
  final String? nickName;
  final String role;
  final String email;
  final String pwdhash;
  const Participant(
      {required this.participantId,
      required this.firstName,
      this.lastName,
      this.nickName,
      required this.role,
      required this.email,
      required this.pwdhash});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['participant_id'] = drift.Variable<int>(participantId);
    map['first_name'] = drift.Variable<String>(firstName);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = drift.Variable<String>(lastName);
    }
    if (!nullToAbsent || nickName != null) {
      map['nick_name'] = drift.Variable<String>(nickName);
    }
    map['role'] = drift.Variable<String>(role);
    map['email'] = drift.Variable<String>(email);
    map['pwdhash'] = drift.Variable<String>(pwdhash);
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      participantId: drift.Value(participantId),
      firstName: drift.Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(lastName),
      nickName: nickName == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(nickName),
      role: drift.Value(role),
      email: drift.Value(email),
      pwdhash: drift.Value(pwdhash),
    );
  }

  factory Participant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Participant(
      participantId: serializer.fromJson<int>(json['participantId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      nickName: serializer.fromJson<String?>(json['nickName']),
      role: serializer.fromJson<String>(json['role']),
      email: serializer.fromJson<String>(json['email']),
      pwdhash: serializer.fromJson<String>(json['pwdhash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'participantId': serializer.toJson<int>(participantId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'nickName': serializer.toJson<String?>(nickName),
      'role': serializer.toJson<String>(role),
      'email': serializer.toJson<String>(email),
      'pwdhash': serializer.toJson<String>(pwdhash),
    };
  }

  Participant copyWith(
          {int? participantId,
          String? firstName,
          drift.Value<String?> lastName = const drift.Value.absent(),
          drift.Value<String?> nickName = const drift.Value.absent(),
          String? role,
          String? email,
          String? pwdhash}) =>
      Participant(
        participantId: participantId ?? this.participantId,
        firstName: firstName ?? this.firstName,
        lastName: lastName.present ? lastName.value : this.lastName,
        nickName: nickName.present ? nickName.value : this.nickName,
        role: role ?? this.role,
        email: email ?? this.email,
        pwdhash: pwdhash ?? this.pwdhash,
      );
  Participant copyWithCompanion(ParticipantsCompanion data) {
    return Participant(
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      nickName: data.nickName.present ? data.nickName.value : this.nickName,
      role: data.role.present ? data.role.value : this.role,
      email: data.email.present ? data.email.value : this.email,
      pwdhash: data.pwdhash.present ? data.pwdhash.value : this.pwdhash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Participant(')
          ..write('participantId: $participantId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('nickName: $nickName, ')
          ..write('role: $role, ')
          ..write('email: $email, ')
          ..write('pwdhash: $pwdhash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      participantId, firstName, lastName, nickName, role, email, pwdhash);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Participant &&
          other.participantId == this.participantId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.nickName == this.nickName &&
          other.role == this.role &&
          other.email == this.email &&
          other.pwdhash == this.pwdhash);
}

class ParticipantsCompanion extends drift.UpdateCompanion<Participant> {
  final drift.Value<int> participantId;
  final drift.Value<String> firstName;
  final drift.Value<String?> lastName;
  final drift.Value<String?> nickName;
  final drift.Value<String> role;
  final drift.Value<String> email;
  final drift.Value<String> pwdhash;
  const ParticipantsCompanion({
    this.participantId = const drift.Value.absent(),
    this.firstName = const drift.Value.absent(),
    this.lastName = const drift.Value.absent(),
    this.nickName = const drift.Value.absent(),
    this.role = const drift.Value.absent(),
    this.email = const drift.Value.absent(),
    this.pwdhash = const drift.Value.absent(),
  });
  ParticipantsCompanion.insert({
    this.participantId = const drift.Value.absent(),
    required String firstName,
    this.lastName = const drift.Value.absent(),
    this.nickName = const drift.Value.absent(),
    required String role,
    required String email,
    required String pwdhash,
  })  : firstName = drift.Value(firstName),
        role = drift.Value(role),
        email = drift.Value(email),
        pwdhash = drift.Value(pwdhash);
  static drift.Insertable<Participant> custom({
    drift.Expression<int>? participantId,
    drift.Expression<String>? firstName,
    drift.Expression<String>? lastName,
    drift.Expression<String>? nickName,
    drift.Expression<String>? role,
    drift.Expression<String>? email,
    drift.Expression<String>? pwdhash,
  }) {
    return drift.RawValuesInsertable({
      if (participantId != null) 'participant_id': participantId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (nickName != null) 'nick_name': nickName,
      if (role != null) 'role': role,
      if (email != null) 'email': email,
      if (pwdhash != null) 'pwdhash': pwdhash,
    });
  }

  ParticipantsCompanion copyWith(
      {drift.Value<int>? participantId,
      drift.Value<String>? firstName,
      drift.Value<String?>? lastName,
      drift.Value<String?>? nickName,
      drift.Value<String>? role,
      drift.Value<String>? email,
      drift.Value<String>? pwdhash}) {
    return ParticipantsCompanion(
      participantId: participantId ?? this.participantId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickName: nickName ?? this.nickName,
      role: role ?? this.role,
      email: email ?? this.email,
      pwdhash: pwdhash ?? this.pwdhash,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (participantId.present) {
      map['participant_id'] = drift.Variable<int>(participantId.value);
    }
    if (firstName.present) {
      map['first_name'] = drift.Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = drift.Variable<String>(lastName.value);
    }
    if (nickName.present) {
      map['nick_name'] = drift.Variable<String>(nickName.value);
    }
    if (role.present) {
      map['role'] = drift.Variable<String>(role.value);
    }
    if (email.present) {
      map['email'] = drift.Variable<String>(email.value);
    }
    if (pwdhash.present) {
      map['pwdhash'] = drift.Variable<String>(pwdhash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantsCompanion(')
          ..write('participantId: $participantId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('nickName: $nickName, ')
          ..write('role: $role, ')
          ..write('email: $email, ')
          ..write('pwdhash: $pwdhash')
          ..write(')'))
        .toString();
  }
}

class $SyncLogTable extends SyncLog
    with drift.TableInfo<$SyncLogTable, SyncLogEntry> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _syncIdMeta =
      const drift.VerificationMeta('syncId');
  @override
  late final drift.GeneratedColumn<int> syncId = drift.GeneratedColumn<int>(
      'sync_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _syncDirectionMeta =
      const drift.VerificationMeta('syncDirection');
  @override
  late final drift.GeneratedColumn<String> syncDirection =
      drift.GeneratedColumn<String>('sync_direction', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _syncedMeta =
      const drift.VerificationMeta('synced');
  @override
  late final drift.GeneratedColumn<bool> synced = drift.GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'));
  static const drift.VerificationMeta _successMeta =
      const drift.VerificationMeta('success');
  @override
  late final drift.GeneratedColumn<bool> success = drift.GeneratedColumn<bool>(
      'success', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("success" IN (0, 1))'));
  static const drift.VerificationMeta _errorMessageMeta =
      const drift.VerificationMeta('errorMessage');
  @override
  late final drift.GeneratedColumn<String> errorMessage =
      drift.GeneratedColumn<String>('error_message', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const drift.VerificationMeta _sheetUrlMeta =
      const drift.VerificationMeta('sheetUrl');
  @override
  late final drift.GeneratedColumn<String> sheetUrl =
      drift.GeneratedColumn<String>('sheet_url', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns =>
      [syncId, syncDirection, synced, success, errorMessage, sheetUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_log';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<SyncLogEntry> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    }
    if (data.containsKey('sync_direction')) {
      context.handle(
          _syncDirectionMeta,
          syncDirection.isAcceptableOrUnknown(
              data['sync_direction']!, _syncDirectionMeta));
    } else if (isInserting) {
      context.missing(_syncDirectionMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    } else if (isInserting) {
      context.missing(_syncedMeta);
    }
    if (data.containsKey('success')) {
      context.handle(_successMeta,
          success.isAcceptableOrUnknown(data['success']!, _successMeta));
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('sheet_url')) {
      context.handle(_sheetUrlMeta,
          sheetUrl.isAcceptableOrUnknown(data['sheet_url']!, _sheetUrlMeta));
    } else if (isInserting) {
      context.missing(_sheetUrlMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {syncId};
  @override
  SyncLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLogEntry(
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_id'])!,
      syncDirection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_direction'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      success: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}success'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      sheetUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sheet_url'])!,
    );
  }

  @override
  $SyncLogTable createAlias(String alias) {
    return $SyncLogTable(attachedDatabase, alias);
  }
}

class SyncLogEntry extends drift.DataClass
    implements drift.Insertable<SyncLogEntry> {
  final int syncId;
  final String syncDirection;
  final bool synced;
  final bool success;
  final String? errorMessage;
  final String sheetUrl;
  const SyncLogEntry(
      {required this.syncId,
      required this.syncDirection,
      required this.synced,
      required this.success,
      this.errorMessage,
      required this.sheetUrl});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['sync_id'] = drift.Variable<int>(syncId);
    map['sync_direction'] = drift.Variable<String>(syncDirection);
    map['synced'] = drift.Variable<bool>(synced);
    map['success'] = drift.Variable<bool>(success);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = drift.Variable<String>(errorMessage);
    }
    map['sheet_url'] = drift.Variable<String>(sheetUrl);
    return map;
  }

  SyncLogCompanion toCompanion(bool nullToAbsent) {
    return SyncLogCompanion(
      syncId: drift.Value(syncId),
      syncDirection: drift.Value(syncDirection),
      synced: drift.Value(synced),
      success: drift.Value(success),
      errorMessage: errorMessage == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(errorMessage),
      sheetUrl: drift.Value(sheetUrl),
    );
  }

  factory SyncLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return SyncLogEntry(
      syncId: serializer.fromJson<int>(json['syncId']),
      syncDirection: serializer.fromJson<String>(json['syncDirection']),
      synced: serializer.fromJson<bool>(json['synced']),
      success: serializer.fromJson<bool>(json['success']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      sheetUrl: serializer.fromJson<String>(json['sheetUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<int>(syncId),
      'syncDirection': serializer.toJson<String>(syncDirection),
      'synced': serializer.toJson<bool>(synced),
      'success': serializer.toJson<bool>(success),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'sheetUrl': serializer.toJson<String>(sheetUrl),
    };
  }

  SyncLogEntry copyWith(
          {int? syncId,
          String? syncDirection,
          bool? synced,
          bool? success,
          drift.Value<String?> errorMessage = const drift.Value.absent(),
          String? sheetUrl}) =>
      SyncLogEntry(
        syncId: syncId ?? this.syncId,
        syncDirection: syncDirection ?? this.syncDirection,
        synced: synced ?? this.synced,
        success: success ?? this.success,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        sheetUrl: sheetUrl ?? this.sheetUrl,
      );
  SyncLogEntry copyWithCompanion(SyncLogCompanion data) {
    return SyncLogEntry(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      syncDirection: data.syncDirection.present
          ? data.syncDirection.value
          : this.syncDirection,
      synced: data.synced.present ? data.synced.value : this.synced,
      success: data.success.present ? data.success.value : this.success,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      sheetUrl: data.sheetUrl.present ? data.sheetUrl.value : this.sheetUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogEntry(')
          ..write('syncId: $syncId, ')
          ..write('syncDirection: $syncDirection, ')
          ..write('synced: $synced, ')
          ..write('success: $success, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('sheetUrl: $sheetUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      syncId, syncDirection, synced, success, errorMessage, sheetUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLogEntry &&
          other.syncId == this.syncId &&
          other.syncDirection == this.syncDirection &&
          other.synced == this.synced &&
          other.success == this.success &&
          other.errorMessage == this.errorMessage &&
          other.sheetUrl == this.sheetUrl);
}

class SyncLogCompanion extends drift.UpdateCompanion<SyncLogEntry> {
  final drift.Value<int> syncId;
  final drift.Value<String> syncDirection;
  final drift.Value<bool> synced;
  final drift.Value<bool> success;
  final drift.Value<String?> errorMessage;
  final drift.Value<String> sheetUrl;
  const SyncLogCompanion({
    this.syncId = const drift.Value.absent(),
    this.syncDirection = const drift.Value.absent(),
    this.synced = const drift.Value.absent(),
    this.success = const drift.Value.absent(),
    this.errorMessage = const drift.Value.absent(),
    this.sheetUrl = const drift.Value.absent(),
  });
  SyncLogCompanion.insert({
    this.syncId = const drift.Value.absent(),
    required String syncDirection,
    required bool synced,
    required bool success,
    this.errorMessage = const drift.Value.absent(),
    required String sheetUrl,
  })  : syncDirection = drift.Value(syncDirection),
        synced = drift.Value(synced),
        success = drift.Value(success),
        sheetUrl = drift.Value(sheetUrl);
  static drift.Insertable<SyncLogEntry> custom({
    drift.Expression<int>? syncId,
    drift.Expression<String>? syncDirection,
    drift.Expression<bool>? synced,
    drift.Expression<bool>? success,
    drift.Expression<String>? errorMessage,
    drift.Expression<String>? sheetUrl,
  }) {
    return drift.RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (syncDirection != null) 'sync_direction': syncDirection,
      if (synced != null) 'synced': synced,
      if (success != null) 'success': success,
      if (errorMessage != null) 'error_message': errorMessage,
      if (sheetUrl != null) 'sheet_url': sheetUrl,
    });
  }

  SyncLogCompanion copyWith(
      {drift.Value<int>? syncId,
      drift.Value<String>? syncDirection,
      drift.Value<bool>? synced,
      drift.Value<bool>? success,
      drift.Value<String?>? errorMessage,
      drift.Value<String>? sheetUrl}) {
    return SyncLogCompanion(
      syncId: syncId ?? this.syncId,
      syncDirection: syncDirection ?? this.syncDirection,
      synced: synced ?? this.synced,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      sheetUrl: sheetUrl ?? this.sheetUrl,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (syncId.present) {
      map['sync_id'] = drift.Variable<int>(syncId.value);
    }
    if (syncDirection.present) {
      map['sync_direction'] = drift.Variable<String>(syncDirection.value);
    }
    if (synced.present) {
      map['synced'] = drift.Variable<bool>(synced.value);
    }
    if (success.present) {
      map['success'] = drift.Variable<bool>(success.value);
    }
    if (errorMessage.present) {
      map['error_message'] = drift.Variable<String>(errorMessage.value);
    }
    if (sheetUrl.present) {
      map['sheet_url'] = drift.Variable<String>(sheetUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogCompanion(')
          ..write('syncId: $syncId, ')
          ..write('syncDirection: $syncDirection, ')
          ..write('synced: $synced, ')
          ..write('success: $success, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('sheetUrl: $sheetUrl')
          ..write(')'))
        .toString();
  }
}

class $TemplatesTable extends Templates
    with drift.TableInfo<$TemplatesTable, Template> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _templateIdMeta =
      const drift.VerificationMeta('templateId');
  @override
  late final drift.GeneratedColumn<int> templateId = drift.GeneratedColumn<int>(
      'template_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _syncIdMeta =
      const drift.VerificationMeta('syncId');
  @override
  late final drift.GeneratedColumn<int> syncId = drift.GeneratedColumn<int>(
      'sync_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sync_log (sync_id)'));
  static const drift.VerificationMeta _spreadSheetIdMeta =
      const drift.VerificationMeta('spreadSheetId');
  @override
  late final drift.GeneratedColumn<String> spreadSheetId =
      drift.GeneratedColumn<String>('spread_sheet_id', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 250),
          type: DriftSqlType.string,
          requiredDuringInsert: false);
  static const drift.VerificationMeta _templateNameMeta =
      const drift.VerificationMeta('templateName');
  @override
  late final drift.GeneratedColumn<String> templateName =
      drift.GeneratedColumn<String>('template_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _creatorParticipantIdMeta =
      const drift.VerificationMeta('creatorParticipantId');
  @override
  late final drift.GeneratedColumn<int> creatorParticipantId =
      drift.GeneratedColumn<int>('creator_participant_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES participants (participant_id)'));
  static const drift.VerificationMeta _dateCreatedMeta =
      const drift.VerificationMeta('dateCreated');
  @override
  late final drift.GeneratedColumn<DateTime> dateCreated =
      drift.GeneratedColumn<DateTime>('date_created', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const drift.VerificationMeta _timesUsedMeta =
      const drift.VerificationMeta('timesUsed');
  @override
  late final drift.GeneratedColumn<int> timesUsed = drift.GeneratedColumn<int>(
      'times_used', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<drift.GeneratedColumn> get $columns => [
        templateId,
        syncId,
        spreadSheetId,
        templateName,
        creatorParticipantId,
        dateCreated,
        timesUsed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<Template> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    }
    if (data.containsKey('spread_sheet_id')) {
      context.handle(
          _spreadSheetIdMeta,
          spreadSheetId.isAcceptableOrUnknown(
              data['spread_sheet_id']!, _spreadSheetIdMeta));
    }
    if (data.containsKey('template_name')) {
      context.handle(
          _templateNameMeta,
          templateName.isAcceptableOrUnknown(
              data['template_name']!, _templateNameMeta));
    } else if (isInserting) {
      context.missing(_templateNameMeta);
    }
    if (data.containsKey('creator_participant_id')) {
      context.handle(
          _creatorParticipantIdMeta,
          creatorParticipantId.isAcceptableOrUnknown(
              data['creator_participant_id']!, _creatorParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_creatorParticipantIdMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    } else if (isInserting) {
      context.missing(_dateCreatedMeta);
    }
    if (data.containsKey('times_used')) {
      context.handle(_timesUsedMeta,
          timesUsed.isAcceptableOrUnknown(data['times_used']!, _timesUsedMeta));
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {templateId};
  @override
  Template map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Template(
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}template_id'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_id']),
      spreadSheetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}spread_sheet_id']),
      templateName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_name'])!,
      creatorParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}creator_participant_id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      timesUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times_used']),
    );
  }

  @override
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }
}

class Template extends drift.DataClass implements drift.Insertable<Template> {
  final int templateId;
  final int? syncId;
  final String? spreadSheetId;
  final String templateName;
  final int creatorParticipantId;
  final DateTime dateCreated;
  final int? timesUsed;
  const Template(
      {required this.templateId,
      this.syncId,
      this.spreadSheetId,
      required this.templateName,
      required this.creatorParticipantId,
      required this.dateCreated,
      this.timesUsed});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['template_id'] = drift.Variable<int>(templateId);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = drift.Variable<int>(syncId);
    }
    if (!nullToAbsent || spreadSheetId != null) {
      map['spread_sheet_id'] = drift.Variable<String>(spreadSheetId);
    }
    map['template_name'] = drift.Variable<String>(templateName);
    map['creator_participant_id'] = drift.Variable<int>(creatorParticipantId);
    map['date_created'] = drift.Variable<DateTime>(dateCreated);
    if (!nullToAbsent || timesUsed != null) {
      map['times_used'] = drift.Variable<int>(timesUsed);
    }
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      templateId: drift.Value(templateId),
      syncId: syncId == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(syncId),
      spreadSheetId: spreadSheetId == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(spreadSheetId),
      templateName: drift.Value(templateName),
      creatorParticipantId: drift.Value(creatorParticipantId),
      dateCreated: drift.Value(dateCreated),
      timesUsed: timesUsed == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(timesUsed),
    );
  }

  factory Template.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Template(
      templateId: serializer.fromJson<int>(json['templateId']),
      syncId: serializer.fromJson<int?>(json['syncId']),
      spreadSheetId: serializer.fromJson<String?>(json['spreadSheetId']),
      templateName: serializer.fromJson<String>(json['templateName']),
      creatorParticipantId:
          serializer.fromJson<int>(json['creatorParticipantId']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      timesUsed: serializer.fromJson<int?>(json['timesUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateId': serializer.toJson<int>(templateId),
      'syncId': serializer.toJson<int?>(syncId),
      'spreadSheetId': serializer.toJson<String?>(spreadSheetId),
      'templateName': serializer.toJson<String>(templateName),
      'creatorParticipantId': serializer.toJson<int>(creatorParticipantId),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'timesUsed': serializer.toJson<int?>(timesUsed),
    };
  }

  Template copyWith(
          {int? templateId,
          drift.Value<int?> syncId = const drift.Value.absent(),
          drift.Value<String?> spreadSheetId = const drift.Value.absent(),
          String? templateName,
          int? creatorParticipantId,
          DateTime? dateCreated,
          drift.Value<int?> timesUsed = const drift.Value.absent()}) =>
      Template(
        templateId: templateId ?? this.templateId,
        syncId: syncId.present ? syncId.value : this.syncId,
        spreadSheetId:
            spreadSheetId.present ? spreadSheetId.value : this.spreadSheetId,
        templateName: templateName ?? this.templateName,
        creatorParticipantId: creatorParticipantId ?? this.creatorParticipantId,
        dateCreated: dateCreated ?? this.dateCreated,
        timesUsed: timesUsed.present ? timesUsed.value : this.timesUsed,
      );
  Template copyWithCompanion(TemplatesCompanion data) {
    return Template(
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      spreadSheetId: data.spreadSheetId.present
          ? data.spreadSheetId.value
          : this.spreadSheetId,
      templateName: data.templateName.present
          ? data.templateName.value
          : this.templateName,
      creatorParticipantId: data.creatorParticipantId.present
          ? data.creatorParticipantId.value
          : this.creatorParticipantId,
      dateCreated:
          data.dateCreated.present ? data.dateCreated.value : this.dateCreated,
      timesUsed: data.timesUsed.present ? data.timesUsed.value : this.timesUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Template(')
          ..write('templateId: $templateId, ')
          ..write('syncId: $syncId, ')
          ..write('spreadSheetId: $spreadSheetId, ')
          ..write('templateName: $templateName, ')
          ..write('creatorParticipantId: $creatorParticipantId, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('timesUsed: $timesUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(templateId, syncId, spreadSheetId,
      templateName, creatorParticipantId, dateCreated, timesUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Template &&
          other.templateId == this.templateId &&
          other.syncId == this.syncId &&
          other.spreadSheetId == this.spreadSheetId &&
          other.templateName == this.templateName &&
          other.creatorParticipantId == this.creatorParticipantId &&
          other.dateCreated == this.dateCreated &&
          other.timesUsed == this.timesUsed);
}

class TemplatesCompanion extends drift.UpdateCompanion<Template> {
  final drift.Value<int> templateId;
  final drift.Value<int?> syncId;
  final drift.Value<String?> spreadSheetId;
  final drift.Value<String> templateName;
  final drift.Value<int> creatorParticipantId;
  final drift.Value<DateTime> dateCreated;
  final drift.Value<int?> timesUsed;
  const TemplatesCompanion({
    this.templateId = const drift.Value.absent(),
    this.syncId = const drift.Value.absent(),
    this.spreadSheetId = const drift.Value.absent(),
    this.templateName = const drift.Value.absent(),
    this.creatorParticipantId = const drift.Value.absent(),
    this.dateCreated = const drift.Value.absent(),
    this.timesUsed = const drift.Value.absent(),
  });
  TemplatesCompanion.insert({
    this.templateId = const drift.Value.absent(),
    this.syncId = const drift.Value.absent(),
    this.spreadSheetId = const drift.Value.absent(),
    required String templateName,
    required int creatorParticipantId,
    required DateTime dateCreated,
    this.timesUsed = const drift.Value.absent(),
  })  : templateName = drift.Value(templateName),
        creatorParticipantId = drift.Value(creatorParticipantId),
        dateCreated = drift.Value(dateCreated);
  static drift.Insertable<Template> custom({
    drift.Expression<int>? templateId,
    drift.Expression<int>? syncId,
    drift.Expression<String>? spreadSheetId,
    drift.Expression<String>? templateName,
    drift.Expression<int>? creatorParticipantId,
    drift.Expression<DateTime>? dateCreated,
    drift.Expression<int>? timesUsed,
  }) {
    return drift.RawValuesInsertable({
      if (templateId != null) 'template_id': templateId,
      if (syncId != null) 'sync_id': syncId,
      if (spreadSheetId != null) 'spread_sheet_id': spreadSheetId,
      if (templateName != null) 'template_name': templateName,
      if (creatorParticipantId != null)
        'creator_participant_id': creatorParticipantId,
      if (dateCreated != null) 'date_created': dateCreated,
      if (timesUsed != null) 'times_used': timesUsed,
    });
  }

  TemplatesCompanion copyWith(
      {drift.Value<int>? templateId,
      drift.Value<int?>? syncId,
      drift.Value<String?>? spreadSheetId,
      drift.Value<String>? templateName,
      drift.Value<int>? creatorParticipantId,
      drift.Value<DateTime>? dateCreated,
      drift.Value<int?>? timesUsed}) {
    return TemplatesCompanion(
      templateId: templateId ?? this.templateId,
      syncId: syncId ?? this.syncId,
      spreadSheetId: spreadSheetId ?? this.spreadSheetId,
      templateName: templateName ?? this.templateName,
      creatorParticipantId: creatorParticipantId ?? this.creatorParticipantId,
      dateCreated: dateCreated ?? this.dateCreated,
      timesUsed: timesUsed ?? this.timesUsed,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (templateId.present) {
      map['template_id'] = drift.Variable<int>(templateId.value);
    }
    if (syncId.present) {
      map['sync_id'] = drift.Variable<int>(syncId.value);
    }
    if (spreadSheetId.present) {
      map['spread_sheet_id'] = drift.Variable<String>(spreadSheetId.value);
    }
    if (templateName.present) {
      map['template_name'] = drift.Variable<String>(templateName.value);
    }
    if (creatorParticipantId.present) {
      map['creator_participant_id'] =
          drift.Variable<int>(creatorParticipantId.value);
    }
    if (dateCreated.present) {
      map['date_created'] = drift.Variable<DateTime>(dateCreated.value);
    }
    if (timesUsed.present) {
      map['times_used'] = drift.Variable<int>(timesUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesCompanion(')
          ..write('templateId: $templateId, ')
          ..write('syncId: $syncId, ')
          ..write('spreadSheetId: $spreadSheetId, ')
          ..write('templateName: $templateName, ')
          ..write('creatorParticipantId: $creatorParticipantId, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('timesUsed: $timesUsed')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with drift.TableInfo<$CategoriesTable, Category> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _categoryIdMeta =
      const drift.VerificationMeta('categoryId');
  @override
  late final drift.GeneratedColumn<int> categoryId = drift.GeneratedColumn<int>(
      'category_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _templateIdMeta =
      const drift.VerificationMeta('templateId');
  @override
  late final drift.GeneratedColumn<int> templateId = drift.GeneratedColumn<int>(
      'template_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES templates (template_id)'));
  static const drift.VerificationMeta _categoryNameMeta =
      const drift.VerificationMeta('categoryName');
  @override
  late final drift.GeneratedColumn<String> categoryName =
      drift.GeneratedColumn<String>('category_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const drift.VerificationMeta _colorHexMeta =
      const drift.VerificationMeta('colorHex');
  @override
  late final drift.GeneratedColumn<String> colorHex =
      drift.GeneratedColumn<String>(
          'color_hex', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 7, maxTextLength: 7),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns =>
      [categoryId, templateId, categoryName, colorHex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
          _categoryNameMeta,
          categoryName.isAcceptableOrUnknown(
              data['category_name']!, _categoryNameMeta));
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {categoryId};
  @override
  List<Set<drift.GeneratedColumn>> get uniqueKeys => [
        {templateId, categoryName},
      ];
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}template_id'])!,
      categoryName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends drift.DataClass implements drift.Insertable<Category> {
  final int categoryId;
  final int templateId;
  final String categoryName;
  final String colorHex;
  const Category(
      {required this.categoryId,
      required this.templateId,
      required this.categoryName,
      required this.colorHex});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['category_id'] = drift.Variable<int>(categoryId);
    map['template_id'] = drift.Variable<int>(templateId);
    map['category_name'] = drift.Variable<String>(categoryName);
    map['color_hex'] = drift.Variable<String>(colorHex);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      categoryId: drift.Value(categoryId),
      templateId: drift.Value(templateId),
      categoryName: drift.Value(categoryName),
      colorHex: drift.Value(colorHex),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Category(
      categoryId: serializer.fromJson<int>(json['categoryId']),
      templateId: serializer.fromJson<int>(json['templateId']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<int>(categoryId),
      'templateId': serializer.toJson<int>(templateId),
      'categoryName': serializer.toJson<String>(categoryName),
      'colorHex': serializer.toJson<String>(colorHex),
    };
  }

  Category copyWith(
          {int? categoryId,
          int? templateId,
          String? categoryName,
          String? colorHex}) =>
      Category(
        categoryId: categoryId ?? this.categoryId,
        templateId: templateId ?? this.templateId,
        categoryName: categoryName ?? this.categoryName,
        colorHex: colorHex ?? this.colorHex,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('categoryId: $categoryId, ')
          ..write('templateId: $templateId, ')
          ..write('categoryName: $categoryName, ')
          ..write('colorHex: $colorHex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(categoryId, templateId, categoryName, colorHex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.categoryId == this.categoryId &&
          other.templateId == this.templateId &&
          other.categoryName == this.categoryName &&
          other.colorHex == this.colorHex);
}

class CategoriesCompanion extends drift.UpdateCompanion<Category> {
  final drift.Value<int> categoryId;
  final drift.Value<int> templateId;
  final drift.Value<String> categoryName;
  final drift.Value<String> colorHex;
  const CategoriesCompanion({
    this.categoryId = const drift.Value.absent(),
    this.templateId = const drift.Value.absent(),
    this.categoryName = const drift.Value.absent(),
    this.colorHex = const drift.Value.absent(),
  });
  CategoriesCompanion.insert({
    this.categoryId = const drift.Value.absent(),
    required int templateId,
    required String categoryName,
    required String colorHex,
  })  : templateId = drift.Value(templateId),
        categoryName = drift.Value(categoryName),
        colorHex = drift.Value(colorHex);
  static drift.Insertable<Category> custom({
    drift.Expression<int>? categoryId,
    drift.Expression<int>? templateId,
    drift.Expression<String>? categoryName,
    drift.Expression<String>? colorHex,
  }) {
    return drift.RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (templateId != null) 'template_id': templateId,
      if (categoryName != null) 'category_name': categoryName,
      if (colorHex != null) 'color_hex': colorHex,
    });
  }

  CategoriesCompanion copyWith(
      {drift.Value<int>? categoryId,
      drift.Value<int>? templateId,
      drift.Value<String>? categoryName,
      drift.Value<String>? colorHex}) {
    return CategoriesCompanion(
      categoryId: categoryId ?? this.categoryId,
      templateId: templateId ?? this.templateId,
      categoryName: categoryName ?? this.categoryName,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (categoryId.present) {
      map['category_id'] = drift.Variable<int>(categoryId.value);
    }
    if (templateId.present) {
      map['template_id'] = drift.Variable<int>(templateId.value);
    }
    if (categoryName.present) {
      map['category_name'] = drift.Variable<String>(categoryName.value);
    }
    if (colorHex.present) {
      map['color_hex'] = drift.Variable<String>(colorHex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('templateId: $templateId, ')
          ..write('categoryName: $categoryName, ')
          ..write('colorHex: $colorHex')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts
    with drift.TableInfo<$AccountsTable, Account> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _accountIdMeta =
      const drift.VerificationMeta('accountId');
  @override
  late final drift.GeneratedColumn<int> accountId = drift.GeneratedColumn<int>(
      'account_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _categoryIdMeta =
      const drift.VerificationMeta('categoryId');
  @override
  late final drift.GeneratedColumn<int> categoryId = drift.GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (category_id)'));
  static const drift.VerificationMeta _templateIdMeta =
      const drift.VerificationMeta('templateId');
  @override
  late final drift.GeneratedColumn<int> templateId = drift.GeneratedColumn<int>(
      'template_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES templates (template_id)'));
  static const drift.VerificationMeta _accountNameMeta =
      const drift.VerificationMeta('accountName');
  @override
  late final drift.GeneratedColumn<String> accountName =
      drift.GeneratedColumn<String>('account_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _colorHexMeta =
      const drift.VerificationMeta('colorHex');
  @override
  late final drift.GeneratedColumn<String> colorHex =
      drift.GeneratedColumn<String>(
          'color_hex', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 7, maxTextLength: 7),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _budgetAmountMeta =
      const drift.VerificationMeta('budgetAmount');
  @override
  late final drift.GeneratedColumn<double> budgetAmount =
      drift.GeneratedColumn<double>('budget_amount', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const drift.VerificationMeta _expenditureTotalMeta =
      const drift.VerificationMeta('expenditureTotal');
  @override
  late final drift.GeneratedColumn<double> expenditureTotal =
      drift.GeneratedColumn<double>('expenditure_total', aliasedName, true,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const drift.Constant(0.00));
  static const drift.VerificationMeta _responsibleParticipantIdMeta =
      const drift.VerificationMeta('responsibleParticipantId');
  @override
  late final drift.GeneratedColumn<int> responsibleParticipantId =
      drift.GeneratedColumn<int>(
          'responsible_participant_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES participants (participant_id)'));
  static const drift.VerificationMeta _dateCreatedMeta =
      const drift.VerificationMeta('dateCreated');
  @override
  late final drift.GeneratedColumn<DateTime> dateCreated =
      drift.GeneratedColumn<DateTime>('date_created', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns => [
        accountId,
        categoryId,
        templateId,
        accountName,
        colorHex,
        budgetAmount,
        expenditureTotal,
        responsibleParticipantId,
        dateCreated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('account_name')) {
      context.handle(
          _accountNameMeta,
          accountName.isAcceptableOrUnknown(
              data['account_name']!, _accountNameMeta));
    } else if (isInserting) {
      context.missing(_accountNameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('budget_amount')) {
      context.handle(
          _budgetAmountMeta,
          budgetAmount.isAcceptableOrUnknown(
              data['budget_amount']!, _budgetAmountMeta));
    } else if (isInserting) {
      context.missing(_budgetAmountMeta);
    }
    if (data.containsKey('expenditure_total')) {
      context.handle(
          _expenditureTotalMeta,
          expenditureTotal.isAcceptableOrUnknown(
              data['expenditure_total']!, _expenditureTotalMeta));
    }
    if (data.containsKey('responsible_participant_id')) {
      context.handle(
          _responsibleParticipantIdMeta,
          responsibleParticipantId.isAcceptableOrUnknown(
              data['responsible_participant_id']!,
              _responsibleParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_responsibleParticipantIdMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    } else if (isInserting) {
      context.missing(_dateCreatedMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {accountId};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}template_id'])!,
      accountName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      budgetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}budget_amount'])!,
      expenditureTotal: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}expenditure_total']),
      responsibleParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}responsible_participant_id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends drift.DataClass implements drift.Insertable<Account> {
  final int accountId;
  final int categoryId;
  final int templateId;
  final String accountName;
  final String colorHex;
  final double budgetAmount;
  final double? expenditureTotal;
  final int responsibleParticipantId;
  final DateTime dateCreated;
  const Account(
      {required this.accountId,
      required this.categoryId,
      required this.templateId,
      required this.accountName,
      required this.colorHex,
      required this.budgetAmount,
      this.expenditureTotal,
      required this.responsibleParticipantId,
      required this.dateCreated});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['account_id'] = drift.Variable<int>(accountId);
    map['category_id'] = drift.Variable<int>(categoryId);
    map['template_id'] = drift.Variable<int>(templateId);
    map['account_name'] = drift.Variable<String>(accountName);
    map['color_hex'] = drift.Variable<String>(colorHex);
    map['budget_amount'] = drift.Variable<double>(budgetAmount);
    if (!nullToAbsent || expenditureTotal != null) {
      map['expenditure_total'] = drift.Variable<double>(expenditureTotal);
    }
    map['responsible_participant_id'] =
        drift.Variable<int>(responsibleParticipantId);
    map['date_created'] = drift.Variable<DateTime>(dateCreated);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      accountId: drift.Value(accountId),
      categoryId: drift.Value(categoryId),
      templateId: drift.Value(templateId),
      accountName: drift.Value(accountName),
      colorHex: drift.Value(colorHex),
      budgetAmount: drift.Value(budgetAmount),
      expenditureTotal: expenditureTotal == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(expenditureTotal),
      responsibleParticipantId: drift.Value(responsibleParticipantId),
      dateCreated: drift.Value(dateCreated),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Account(
      accountId: serializer.fromJson<int>(json['accountId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      templateId: serializer.fromJson<int>(json['templateId']),
      accountName: serializer.fromJson<String>(json['accountName']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      budgetAmount: serializer.fromJson<double>(json['budgetAmount']),
      expenditureTotal: serializer.fromJson<double?>(json['expenditureTotal']),
      responsibleParticipantId:
          serializer.fromJson<int>(json['responsibleParticipantId']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<int>(accountId),
      'categoryId': serializer.toJson<int>(categoryId),
      'templateId': serializer.toJson<int>(templateId),
      'accountName': serializer.toJson<String>(accountName),
      'colorHex': serializer.toJson<String>(colorHex),
      'budgetAmount': serializer.toJson<double>(budgetAmount),
      'expenditureTotal': serializer.toJson<double?>(expenditureTotal),
      'responsibleParticipantId':
          serializer.toJson<int>(responsibleParticipantId),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
    };
  }

  Account copyWith(
          {int? accountId,
          int? categoryId,
          int? templateId,
          String? accountName,
          String? colorHex,
          double? budgetAmount,
          drift.Value<double?> expenditureTotal = const drift.Value.absent(),
          int? responsibleParticipantId,
          DateTime? dateCreated}) =>
      Account(
        accountId: accountId ?? this.accountId,
        categoryId: categoryId ?? this.categoryId,
        templateId: templateId ?? this.templateId,
        accountName: accountName ?? this.accountName,
        colorHex: colorHex ?? this.colorHex,
        budgetAmount: budgetAmount ?? this.budgetAmount,
        expenditureTotal: expenditureTotal.present
            ? expenditureTotal.value
            : this.expenditureTotal,
        responsibleParticipantId:
            responsibleParticipantId ?? this.responsibleParticipantId,
        dateCreated: dateCreated ?? this.dateCreated,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      accountName:
          data.accountName.present ? data.accountName.value : this.accountName,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      budgetAmount: data.budgetAmount.present
          ? data.budgetAmount.value
          : this.budgetAmount,
      expenditureTotal: data.expenditureTotal.present
          ? data.expenditureTotal.value
          : this.expenditureTotal,
      responsibleParticipantId: data.responsibleParticipantId.present
          ? data.responsibleParticipantId.value
          : this.responsibleParticipantId,
      dateCreated:
          data.dateCreated.present ? data.dateCreated.value : this.dateCreated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('templateId: $templateId, ')
          ..write('accountName: $accountName, ')
          ..write('colorHex: $colorHex, ')
          ..write('budgetAmount: $budgetAmount, ')
          ..write('expenditureTotal: $expenditureTotal, ')
          ..write('responsibleParticipantId: $responsibleParticipantId, ')
          ..write('dateCreated: $dateCreated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      accountId,
      categoryId,
      templateId,
      accountName,
      colorHex,
      budgetAmount,
      expenditureTotal,
      responsibleParticipantId,
      dateCreated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.templateId == this.templateId &&
          other.accountName == this.accountName &&
          other.colorHex == this.colorHex &&
          other.budgetAmount == this.budgetAmount &&
          other.expenditureTotal == this.expenditureTotal &&
          other.responsibleParticipantId == this.responsibleParticipantId &&
          other.dateCreated == this.dateCreated);
}

class AccountsCompanion extends drift.UpdateCompanion<Account> {
  final drift.Value<int> accountId;
  final drift.Value<int> categoryId;
  final drift.Value<int> templateId;
  final drift.Value<String> accountName;
  final drift.Value<String> colorHex;
  final drift.Value<double> budgetAmount;
  final drift.Value<double?> expenditureTotal;
  final drift.Value<int> responsibleParticipantId;
  final drift.Value<DateTime> dateCreated;
  const AccountsCompanion({
    this.accountId = const drift.Value.absent(),
    this.categoryId = const drift.Value.absent(),
    this.templateId = const drift.Value.absent(),
    this.accountName = const drift.Value.absent(),
    this.colorHex = const drift.Value.absent(),
    this.budgetAmount = const drift.Value.absent(),
    this.expenditureTotal = const drift.Value.absent(),
    this.responsibleParticipantId = const drift.Value.absent(),
    this.dateCreated = const drift.Value.absent(),
  });
  AccountsCompanion.insert({
    this.accountId = const drift.Value.absent(),
    required int categoryId,
    required int templateId,
    required String accountName,
    required String colorHex,
    required double budgetAmount,
    this.expenditureTotal = const drift.Value.absent(),
    required int responsibleParticipantId,
    required DateTime dateCreated,
  })  : categoryId = drift.Value(categoryId),
        templateId = drift.Value(templateId),
        accountName = drift.Value(accountName),
        colorHex = drift.Value(colorHex),
        budgetAmount = drift.Value(budgetAmount),
        responsibleParticipantId = drift.Value(responsibleParticipantId),
        dateCreated = drift.Value(dateCreated);
  static drift.Insertable<Account> custom({
    drift.Expression<int>? accountId,
    drift.Expression<int>? categoryId,
    drift.Expression<int>? templateId,
    drift.Expression<String>? accountName,
    drift.Expression<String>? colorHex,
    drift.Expression<double>? budgetAmount,
    drift.Expression<double>? expenditureTotal,
    drift.Expression<int>? responsibleParticipantId,
    drift.Expression<DateTime>? dateCreated,
  }) {
    return drift.RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (templateId != null) 'template_id': templateId,
      if (accountName != null) 'account_name': accountName,
      if (colorHex != null) 'color_hex': colorHex,
      if (budgetAmount != null) 'budget_amount': budgetAmount,
      if (expenditureTotal != null) 'expenditure_total': expenditureTotal,
      if (responsibleParticipantId != null)
        'responsible_participant_id': responsibleParticipantId,
      if (dateCreated != null) 'date_created': dateCreated,
    });
  }

  AccountsCompanion copyWith(
      {drift.Value<int>? accountId,
      drift.Value<int>? categoryId,
      drift.Value<int>? templateId,
      drift.Value<String>? accountName,
      drift.Value<String>? colorHex,
      drift.Value<double>? budgetAmount,
      drift.Value<double?>? expenditureTotal,
      drift.Value<int>? responsibleParticipantId,
      drift.Value<DateTime>? dateCreated}) {
    return AccountsCompanion(
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      templateId: templateId ?? this.templateId,
      accountName: accountName ?? this.accountName,
      colorHex: colorHex ?? this.colorHex,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      expenditureTotal: expenditureTotal ?? this.expenditureTotal,
      responsibleParticipantId:
          responsibleParticipantId ?? this.responsibleParticipantId,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (accountId.present) {
      map['account_id'] = drift.Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = drift.Variable<int>(categoryId.value);
    }
    if (templateId.present) {
      map['template_id'] = drift.Variable<int>(templateId.value);
    }
    if (accountName.present) {
      map['account_name'] = drift.Variable<String>(accountName.value);
    }
    if (colorHex.present) {
      map['color_hex'] = drift.Variable<String>(colorHex.value);
    }
    if (budgetAmount.present) {
      map['budget_amount'] = drift.Variable<double>(budgetAmount.value);
    }
    if (expenditureTotal.present) {
      map['expenditure_total'] = drift.Variable<double>(expenditureTotal.value);
    }
    if (responsibleParticipantId.present) {
      map['responsible_participant_id'] =
          drift.Variable<int>(responsibleParticipantId.value);
    }
    if (dateCreated.present) {
      map['date_created'] = drift.Variable<DateTime>(dateCreated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('templateId: $templateId, ')
          ..write('accountName: $accountName, ')
          ..write('colorHex: $colorHex, ')
          ..write('budgetAmount: $budgetAmount, ')
          ..write('expenditureTotal: $expenditureTotal, ')
          ..write('responsibleParticipantId: $responsibleParticipantId, ')
          ..write('dateCreated: $dateCreated')
          ..write(')'))
        .toString();
  }
}

class $VendorsTable extends Vendors
    with drift.TableInfo<$VendorsTable, Vendor> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _vendorIdMeta =
      const drift.VerificationMeta('vendorId');
  @override
  late final drift.GeneratedColumn<int> vendorId = drift.GeneratedColumn<int>(
      'vendor_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _vendorNameMeta =
      const drift.VerificationMeta('vendorName');
  @override
  late final drift.GeneratedColumn<String> vendorName =
      drift.GeneratedColumn<String>('vendor_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 250),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns => [vendorId, vendorName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendors';
  @override
  drift.VerificationContext validateIntegrity(drift.Insertable<Vendor> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
    }
    if (data.containsKey('vendor_name')) {
      context.handle(
          _vendorNameMeta,
          vendorName.isAcceptableOrUnknown(
              data['vendor_name']!, _vendorNameMeta));
    } else if (isInserting) {
      context.missing(_vendorNameMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {vendorId};
  @override
  Vendor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vendor(
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_id'])!,
      vendorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_name'])!,
    );
  }

  @override
  $VendorsTable createAlias(String alias) {
    return $VendorsTable(attachedDatabase, alias);
  }
}

class Vendor extends drift.DataClass implements drift.Insertable<Vendor> {
  final int vendorId;
  final String vendorName;
  const Vendor({required this.vendorId, required this.vendorName});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['vendor_id'] = drift.Variable<int>(vendorId);
    map['vendor_name'] = drift.Variable<String>(vendorName);
    return map;
  }

  VendorsCompanion toCompanion(bool nullToAbsent) {
    return VendorsCompanion(
      vendorId: drift.Value(vendorId),
      vendorName: drift.Value(vendorName),
    );
  }

  factory Vendor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Vendor(
      vendorId: serializer.fromJson<int>(json['vendorId']),
      vendorName: serializer.fromJson<String>(json['vendorName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vendorId': serializer.toJson<int>(vendorId),
      'vendorName': serializer.toJson<String>(vendorName),
    };
  }

  Vendor copyWith({int? vendorId, String? vendorName}) => Vendor(
        vendorId: vendorId ?? this.vendorId,
        vendorName: vendorName ?? this.vendorName,
      );
  Vendor copyWithCompanion(VendorsCompanion data) {
    return Vendor(
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      vendorName:
          data.vendorName.present ? data.vendorName.value : this.vendorName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vendor(')
          ..write('vendorId: $vendorId, ')
          ..write('vendorName: $vendorName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(vendorId, vendorName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vendor &&
          other.vendorId == this.vendorId &&
          other.vendorName == this.vendorName);
}

class VendorsCompanion extends drift.UpdateCompanion<Vendor> {
  final drift.Value<int> vendorId;
  final drift.Value<String> vendorName;
  const VendorsCompanion({
    this.vendorId = const drift.Value.absent(),
    this.vendorName = const drift.Value.absent(),
  });
  VendorsCompanion.insert({
    this.vendorId = const drift.Value.absent(),
    required String vendorName,
  }) : vendorName = drift.Value(vendorName);
  static drift.Insertable<Vendor> custom({
    drift.Expression<int>? vendorId,
    drift.Expression<String>? vendorName,
  }) {
    return drift.RawValuesInsertable({
      if (vendorId != null) 'vendor_id': vendorId,
      if (vendorName != null) 'vendor_name': vendorName,
    });
  }

  VendorsCompanion copyWith(
      {drift.Value<int>? vendorId, drift.Value<String>? vendorName}) {
    return VendorsCompanion(
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (vendorId.present) {
      map['vendor_id'] = drift.Variable<int>(vendorId.value);
    }
    if (vendorName.present) {
      map['vendor_name'] = drift.Variable<String>(vendorName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorsCompanion(')
          ..write('vendorId: $vendorId, ')
          ..write('vendorName: $vendorName')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with drift.TableInfo<$TransactionsTable, Transaction> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _transactionIdMeta =
      const drift.VerificationMeta('transactionId');
  @override
  late final drift.GeneratedColumn<int> transactionId =
      drift.GeneratedColumn<int>('transaction_id', aliasedName, false,
          hasAutoIncrement: true,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _syncIdMeta =
      const drift.VerificationMeta('syncId');
  @override
  late final drift.GeneratedColumn<int> syncId = drift.GeneratedColumn<int>(
      'sync_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sync_log (sync_id)'));
  static const drift.VerificationMeta _accountIdMeta =
      const drift.VerificationMeta('accountId');
  @override
  late final drift.GeneratedColumn<int> accountId = drift.GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES accounts (account_id)'));
  static const drift.VerificationMeta _isIgnoredMeta =
      const drift.VerificationMeta('isIgnored');
  @override
  late final drift.GeneratedColumn<bool> isIgnored =
      drift.GeneratedColumn<bool>('is_ignored', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("is_ignored" IN (0, 1))'),
          defaultValue: const drift.Constant(false));
  static const drift.VerificationMeta _dateMeta =
      const drift.VerificationMeta('date');
  @override
  late final drift.GeneratedColumn<DateTime> date =
      drift.GeneratedColumn<DateTime>('date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const drift.VerificationMeta _vendorIdMeta =
      const drift.VerificationMeta('vendorId');
  @override
  late final drift.GeneratedColumn<int> vendorId = drift.GeneratedColumn<int>(
      'vendor_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vendors (vendor_id)'));
  static const drift.VerificationMeta _amountMeta =
      const drift.VerificationMeta('amount');
  @override
  late final drift.GeneratedColumn<double> amount =
      drift.GeneratedColumn<double>('amount', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const drift.VerificationMeta _participantIdMeta =
      const drift.VerificationMeta('participantId');
  @override
  late final drift.GeneratedColumn<int> participantId =
      drift.GeneratedColumn<int>('participant_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES participants (participant_id)'));
  static const drift.VerificationMeta _editorParticipantIdMeta =
      const drift.VerificationMeta('editorParticipantId');
  @override
  late final drift.GeneratedColumn<int> editorParticipantId =
      drift.GeneratedColumn<int>('editor_participant_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES participants (participant_id)'));
  static const drift.VerificationMeta _reasonMeta =
      const drift.VerificationMeta('reason');
  @override
  late final drift.GeneratedColumn<String> reason =
      drift.GeneratedColumn<String>('reason', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<drift.GeneratedColumn> get $columns => [
        transactionId,
        syncId,
        accountId,
        isIgnored,
        date,
        vendorId,
        amount,
        participantId,
        editorParticipantId,
        reason
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('is_ignored')) {
      context.handle(_isIgnoredMeta,
          isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
    } else if (isInserting) {
      context.missing(_vendorIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('editor_participant_id')) {
      context.handle(
          _editorParticipantIdMeta,
          editorParticipantId.isAcceptableOrUnknown(
              data['editor_participant_id']!, _editorParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_editorParticipantIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {transactionId};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      isIgnored: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_ignored'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_id'])!,
      editorParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}editor_participant_id'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends drift.DataClass
    implements drift.Insertable<Transaction> {
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
  const Transaction(
      {required this.transactionId,
      required this.syncId,
      required this.accountId,
      required this.isIgnored,
      required this.date,
      required this.vendorId,
      required this.amount,
      required this.participantId,
      required this.editorParticipantId,
      this.reason});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['transaction_id'] = drift.Variable<int>(transactionId);
    map['sync_id'] = drift.Variable<int>(syncId);
    map['account_id'] = drift.Variable<int>(accountId);
    map['is_ignored'] = drift.Variable<bool>(isIgnored);
    map['date'] = drift.Variable<DateTime>(date);
    map['vendor_id'] = drift.Variable<int>(vendorId);
    map['amount'] = drift.Variable<double>(amount);
    map['participant_id'] = drift.Variable<int>(participantId);
    map['editor_participant_id'] = drift.Variable<int>(editorParticipantId);
    if (!nullToAbsent || reason != null) {
      map['reason'] = drift.Variable<String>(reason);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      transactionId: drift.Value(transactionId),
      syncId: drift.Value(syncId),
      accountId: drift.Value(accountId),
      isIgnored: drift.Value(isIgnored),
      date: drift.Value(date),
      vendorId: drift.Value(vendorId),
      amount: drift.Value(amount),
      participantId: drift.Value(participantId),
      editorParticipantId: drift.Value(editorParticipantId),
      reason: reason == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(reason),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Transaction(
      transactionId: serializer.fromJson<int>(json['transactionId']),
      syncId: serializer.fromJson<int>(json['syncId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
      date: serializer.fromJson<DateTime>(json['date']),
      vendorId: serializer.fromJson<int>(json['vendorId']),
      amount: serializer.fromJson<double>(json['amount']),
      participantId: serializer.fromJson<int>(json['participantId']),
      editorParticipantId:
          serializer.fromJson<int>(json['editorParticipantId']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<int>(transactionId),
      'syncId': serializer.toJson<int>(syncId),
      'accountId': serializer.toJson<int>(accountId),
      'isIgnored': serializer.toJson<bool>(isIgnored),
      'date': serializer.toJson<DateTime>(date),
      'vendorId': serializer.toJson<int>(vendorId),
      'amount': serializer.toJson<double>(amount),
      'participantId': serializer.toJson<int>(participantId),
      'editorParticipantId': serializer.toJson<int>(editorParticipantId),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  Transaction copyWith(
          {int? transactionId,
          int? syncId,
          int? accountId,
          bool? isIgnored,
          DateTime? date,
          int? vendorId,
          double? amount,
          int? participantId,
          int? editorParticipantId,
          drift.Value<String?> reason = const drift.Value.absent()}) =>
      Transaction(
        transactionId: transactionId ?? this.transactionId,
        syncId: syncId ?? this.syncId,
        accountId: accountId ?? this.accountId,
        isIgnored: isIgnored ?? this.isIgnored,
        date: date ?? this.date,
        vendorId: vendorId ?? this.vendorId,
        amount: amount ?? this.amount,
        participantId: participantId ?? this.participantId,
        editorParticipantId: editorParticipantId ?? this.editorParticipantId,
        reason: reason.present ? reason.value : this.reason,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
      date: data.date.present ? data.date.value : this.date,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      amount: data.amount.present ? data.amount.value : this.amount,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      editorParticipantId: data.editorParticipantId.present
          ? data.editorParticipantId.value
          : this.editorParticipantId,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('transactionId: $transactionId, ')
          ..write('syncId: $syncId, ')
          ..write('accountId: $accountId, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('date: $date, ')
          ..write('vendorId: $vendorId, ')
          ..write('amount: $amount, ')
          ..write('participantId: $participantId, ')
          ..write('editorParticipantId: $editorParticipantId, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(transactionId, syncId, accountId, isIgnored,
      date, vendorId, amount, participantId, editorParticipantId, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.transactionId == this.transactionId &&
          other.syncId == this.syncId &&
          other.accountId == this.accountId &&
          other.isIgnored == this.isIgnored &&
          other.date == this.date &&
          other.vendorId == this.vendorId &&
          other.amount == this.amount &&
          other.participantId == this.participantId &&
          other.editorParticipantId == this.editorParticipantId &&
          other.reason == this.reason);
}

class TransactionsCompanion extends drift.UpdateCompanion<Transaction> {
  final drift.Value<int> transactionId;
  final drift.Value<int> syncId;
  final drift.Value<int> accountId;
  final drift.Value<bool> isIgnored;
  final drift.Value<DateTime> date;
  final drift.Value<int> vendorId;
  final drift.Value<double> amount;
  final drift.Value<int> participantId;
  final drift.Value<int> editorParticipantId;
  final drift.Value<String?> reason;
  const TransactionsCompanion({
    this.transactionId = const drift.Value.absent(),
    this.syncId = const drift.Value.absent(),
    this.accountId = const drift.Value.absent(),
    this.isIgnored = const drift.Value.absent(),
    this.date = const drift.Value.absent(),
    this.vendorId = const drift.Value.absent(),
    this.amount = const drift.Value.absent(),
    this.participantId = const drift.Value.absent(),
    this.editorParticipantId = const drift.Value.absent(),
    this.reason = const drift.Value.absent(),
  });
  TransactionsCompanion.insert({
    this.transactionId = const drift.Value.absent(),
    required int syncId,
    required int accountId,
    this.isIgnored = const drift.Value.absent(),
    required DateTime date,
    required int vendorId,
    required double amount,
    required int participantId,
    required int editorParticipantId,
    this.reason = const drift.Value.absent(),
  })  : syncId = drift.Value(syncId),
        accountId = drift.Value(accountId),
        date = drift.Value(date),
        vendorId = drift.Value(vendorId),
        amount = drift.Value(amount),
        participantId = drift.Value(participantId),
        editorParticipantId = drift.Value(editorParticipantId);
  static drift.Insertable<Transaction> custom({
    drift.Expression<int>? transactionId,
    drift.Expression<int>? syncId,
    drift.Expression<int>? accountId,
    drift.Expression<bool>? isIgnored,
    drift.Expression<DateTime>? date,
    drift.Expression<int>? vendorId,
    drift.Expression<double>? amount,
    drift.Expression<int>? participantId,
    drift.Expression<int>? editorParticipantId,
    drift.Expression<String>? reason,
  }) {
    return drift.RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (syncId != null) 'sync_id': syncId,
      if (accountId != null) 'account_id': accountId,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (date != null) 'date': date,
      if (vendorId != null) 'vendor_id': vendorId,
      if (amount != null) 'amount': amount,
      if (participantId != null) 'participant_id': participantId,
      if (editorParticipantId != null)
        'editor_participant_id': editorParticipantId,
      if (reason != null) 'reason': reason,
    });
  }

  TransactionsCompanion copyWith(
      {drift.Value<int>? transactionId,
      drift.Value<int>? syncId,
      drift.Value<int>? accountId,
      drift.Value<bool>? isIgnored,
      drift.Value<DateTime>? date,
      drift.Value<int>? vendorId,
      drift.Value<double>? amount,
      drift.Value<int>? participantId,
      drift.Value<int>? editorParticipantId,
      drift.Value<String?>? reason}) {
    return TransactionsCompanion(
      transactionId: transactionId ?? this.transactionId,
      syncId: syncId ?? this.syncId,
      accountId: accountId ?? this.accountId,
      isIgnored: isIgnored ?? this.isIgnored,
      date: date ?? this.date,
      vendorId: vendorId ?? this.vendorId,
      amount: amount ?? this.amount,
      participantId: participantId ?? this.participantId,
      editorParticipantId: editorParticipantId ?? this.editorParticipantId,
      reason: reason ?? this.reason,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = drift.Variable<int>(transactionId.value);
    }
    if (syncId.present) {
      map['sync_id'] = drift.Variable<int>(syncId.value);
    }
    if (accountId.present) {
      map['account_id'] = drift.Variable<int>(accountId.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = drift.Variable<bool>(isIgnored.value);
    }
    if (date.present) {
      map['date'] = drift.Variable<DateTime>(date.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = drift.Variable<int>(vendorId.value);
    }
    if (amount.present) {
      map['amount'] = drift.Variable<double>(amount.value);
    }
    if (participantId.present) {
      map['participant_id'] = drift.Variable<int>(participantId.value);
    }
    if (editorParticipantId.present) {
      map['editor_participant_id'] =
          drift.Variable<int>(editorParticipantId.value);
    }
    if (reason.present) {
      map['reason'] = drift.Variable<String>(reason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('syncId: $syncId, ')
          ..write('accountId: $accountId, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('date: $date, ')
          ..write('vendorId: $vendorId, ')
          ..write('amount: $amount, ')
          ..write('participantId: $participantId, ')
          ..write('editorParticipantId: $editorParticipantId, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }
}

class $TransactionEditHistoriesTable extends TransactionEditHistories
    with
        drift
        .TableInfo<$TransactionEditHistoriesTable, TransactionEditHistory> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionEditHistoriesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _transactionEditIdMeta =
      const drift.VerificationMeta('transactionEditId');
  @override
  late final drift.GeneratedColumn<int> transactionEditId =
      drift.GeneratedColumn<int>('transaction_edit_id', aliasedName, false,
          hasAutoIncrement: true,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _editorParticipantIdMeta =
      const drift.VerificationMeta('editorParticipantId');
  @override
  late final drift.GeneratedColumn<int> editorParticipantId =
      drift.GeneratedColumn<int>('editor_participant_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES participants (participant_id)'));
  static const drift.VerificationMeta _transactionIdMeta =
      const drift.VerificationMeta('transactionId');
  @override
  late final drift.GeneratedColumn<int> transactionId =
      drift.GeneratedColumn<int>('transaction_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES transactions (transaction_id)'));
  static const drift.VerificationMeta _editedFieldMeta =
      const drift.VerificationMeta('editedField');
  @override
  late final drift.GeneratedColumn<String> editedField =
      drift.GeneratedColumn<String>('edited_field', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _originalValueMeta =
      const drift.VerificationMeta('originalValue');
  @override
  late final drift.GeneratedColumn<String> originalValue =
      drift.GeneratedColumn<String>('original_value', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 250),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _newValueMeta =
      const drift.VerificationMeta('newValue');
  @override
  late final drift.GeneratedColumn<String> newValue =
      drift.GeneratedColumn<String>(
          'new_value', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 250),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _timeStampMeta =
      const drift.VerificationMeta('timeStamp');
  @override
  late final drift.GeneratedColumn<DateTime> timeStamp =
      drift.GeneratedColumn<DateTime>('time_stamp', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns => [
        transactionEditId,
        editorParticipantId,
        transactionId,
        editedField,
        originalValue,
        newValue,
        timeStamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_edit_histories';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<TransactionEditHistory> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_edit_id')) {
      context.handle(
          _transactionEditIdMeta,
          transactionEditId.isAcceptableOrUnknown(
              data['transaction_edit_id']!, _transactionEditIdMeta));
    }
    if (data.containsKey('editor_participant_id')) {
      context.handle(
          _editorParticipantIdMeta,
          editorParticipantId.isAcceptableOrUnknown(
              data['editor_participant_id']!, _editorParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_editorParticipantIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('edited_field')) {
      context.handle(
          _editedFieldMeta,
          editedField.isAcceptableOrUnknown(
              data['edited_field']!, _editedFieldMeta));
    } else if (isInserting) {
      context.missing(_editedFieldMeta);
    }
    if (data.containsKey('original_value')) {
      context.handle(
          _originalValueMeta,
          originalValue.isAcceptableOrUnknown(
              data['original_value']!, _originalValueMeta));
    } else if (isInserting) {
      context.missing(_originalValueMeta);
    }
    if (data.containsKey('new_value')) {
      context.handle(_newValueMeta,
          newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta));
    } else if (isInserting) {
      context.missing(_newValueMeta);
    }
    if (data.containsKey('time_stamp')) {
      context.handle(_timeStampMeta,
          timeStamp.isAcceptableOrUnknown(data['time_stamp']!, _timeStampMeta));
    } else if (isInserting) {
      context.missing(_timeStampMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {transactionEditId};
  @override
  TransactionEditHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEditHistory(
      transactionEditId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}transaction_edit_id'])!,
      editorParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}editor_participant_id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      editedField: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edited_field'])!,
      originalValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_value'])!,
      newValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_value'])!,
      timeStamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time_stamp'])!,
    );
  }

  @override
  $TransactionEditHistoriesTable createAlias(String alias) {
    return $TransactionEditHistoriesTable(attachedDatabase, alias);
  }
}

class TransactionEditHistory extends drift.DataClass
    implements drift.Insertable<TransactionEditHistory> {
  final int transactionEditId;
  final int editorParticipantId;
  final int transactionId;
  final String editedField;
  final String originalValue;
  final String newValue;
  final DateTime timeStamp;
  const TransactionEditHistory(
      {required this.transactionEditId,
      required this.editorParticipantId,
      required this.transactionId,
      required this.editedField,
      required this.originalValue,
      required this.newValue,
      required this.timeStamp});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['transaction_edit_id'] = drift.Variable<int>(transactionEditId);
    map['editor_participant_id'] = drift.Variable<int>(editorParticipantId);
    map['transaction_id'] = drift.Variable<int>(transactionId);
    map['edited_field'] = drift.Variable<String>(editedField);
    map['original_value'] = drift.Variable<String>(originalValue);
    map['new_value'] = drift.Variable<String>(newValue);
    map['time_stamp'] = drift.Variable<DateTime>(timeStamp);
    return map;
  }

  TransactionEditHistoriesCompanion toCompanion(bool nullToAbsent) {
    return TransactionEditHistoriesCompanion(
      transactionEditId: drift.Value(transactionEditId),
      editorParticipantId: drift.Value(editorParticipantId),
      transactionId: drift.Value(transactionId),
      editedField: drift.Value(editedField),
      originalValue: drift.Value(originalValue),
      newValue: drift.Value(newValue),
      timeStamp: drift.Value(timeStamp),
    );
  }

  factory TransactionEditHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return TransactionEditHistory(
      transactionEditId: serializer.fromJson<int>(json['transactionEditId']),
      editorParticipantId:
          serializer.fromJson<int>(json['editorParticipantId']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      editedField: serializer.fromJson<String>(json['editedField']),
      originalValue: serializer.fromJson<String>(json['originalValue']),
      newValue: serializer.fromJson<String>(json['newValue']),
      timeStamp: serializer.fromJson<DateTime>(json['timeStamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionEditId': serializer.toJson<int>(transactionEditId),
      'editorParticipantId': serializer.toJson<int>(editorParticipantId),
      'transactionId': serializer.toJson<int>(transactionId),
      'editedField': serializer.toJson<String>(editedField),
      'originalValue': serializer.toJson<String>(originalValue),
      'newValue': serializer.toJson<String>(newValue),
      'timeStamp': serializer.toJson<DateTime>(timeStamp),
    };
  }

  TransactionEditHistory copyWith(
          {int? transactionEditId,
          int? editorParticipantId,
          int? transactionId,
          String? editedField,
          String? originalValue,
          String? newValue,
          DateTime? timeStamp}) =>
      TransactionEditHistory(
        transactionEditId: transactionEditId ?? this.transactionEditId,
        editorParticipantId: editorParticipantId ?? this.editorParticipantId,
        transactionId: transactionId ?? this.transactionId,
        editedField: editedField ?? this.editedField,
        originalValue: originalValue ?? this.originalValue,
        newValue: newValue ?? this.newValue,
        timeStamp: timeStamp ?? this.timeStamp,
      );
  TransactionEditHistory copyWithCompanion(
      TransactionEditHistoriesCompanion data) {
    return TransactionEditHistory(
      transactionEditId: data.transactionEditId.present
          ? data.transactionEditId.value
          : this.transactionEditId,
      editorParticipantId: data.editorParticipantId.present
          ? data.editorParticipantId.value
          : this.editorParticipantId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      editedField:
          data.editedField.present ? data.editedField.value : this.editedField,
      originalValue: data.originalValue.present
          ? data.originalValue.value
          : this.originalValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      timeStamp: data.timeStamp.present ? data.timeStamp.value : this.timeStamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEditHistory(')
          ..write('transactionEditId: $transactionEditId, ')
          ..write('editorParticipantId: $editorParticipantId, ')
          ..write('transactionId: $transactionId, ')
          ..write('editedField: $editedField, ')
          ..write('originalValue: $originalValue, ')
          ..write('newValue: $newValue, ')
          ..write('timeStamp: $timeStamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(transactionEditId, editorParticipantId,
      transactionId, editedField, originalValue, newValue, timeStamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEditHistory &&
          other.transactionEditId == this.transactionEditId &&
          other.editorParticipantId == this.editorParticipantId &&
          other.transactionId == this.transactionId &&
          other.editedField == this.editedField &&
          other.originalValue == this.originalValue &&
          other.newValue == this.newValue &&
          other.timeStamp == this.timeStamp);
}

class TransactionEditHistoriesCompanion
    extends drift.UpdateCompanion<TransactionEditHistory> {
  final drift.Value<int> transactionEditId;
  final drift.Value<int> editorParticipantId;
  final drift.Value<int> transactionId;
  final drift.Value<String> editedField;
  final drift.Value<String> originalValue;
  final drift.Value<String> newValue;
  final drift.Value<DateTime> timeStamp;
  const TransactionEditHistoriesCompanion({
    this.transactionEditId = const drift.Value.absent(),
    this.editorParticipantId = const drift.Value.absent(),
    this.transactionId = const drift.Value.absent(),
    this.editedField = const drift.Value.absent(),
    this.originalValue = const drift.Value.absent(),
    this.newValue = const drift.Value.absent(),
    this.timeStamp = const drift.Value.absent(),
  });
  TransactionEditHistoriesCompanion.insert({
    this.transactionEditId = const drift.Value.absent(),
    required int editorParticipantId,
    required int transactionId,
    required String editedField,
    required String originalValue,
    required String newValue,
    required DateTime timeStamp,
  })  : editorParticipantId = drift.Value(editorParticipantId),
        transactionId = drift.Value(transactionId),
        editedField = drift.Value(editedField),
        originalValue = drift.Value(originalValue),
        newValue = drift.Value(newValue),
        timeStamp = drift.Value(timeStamp);
  static drift.Insertable<TransactionEditHistory> custom({
    drift.Expression<int>? transactionEditId,
    drift.Expression<int>? editorParticipantId,
    drift.Expression<int>? transactionId,
    drift.Expression<String>? editedField,
    drift.Expression<String>? originalValue,
    drift.Expression<String>? newValue,
    drift.Expression<DateTime>? timeStamp,
  }) {
    return drift.RawValuesInsertable({
      if (transactionEditId != null) 'transaction_edit_id': transactionEditId,
      if (editorParticipantId != null)
        'editor_participant_id': editorParticipantId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (editedField != null) 'edited_field': editedField,
      if (originalValue != null) 'original_value': originalValue,
      if (newValue != null) 'new_value': newValue,
      if (timeStamp != null) 'time_stamp': timeStamp,
    });
  }

  TransactionEditHistoriesCompanion copyWith(
      {drift.Value<int>? transactionEditId,
      drift.Value<int>? editorParticipantId,
      drift.Value<int>? transactionId,
      drift.Value<String>? editedField,
      drift.Value<String>? originalValue,
      drift.Value<String>? newValue,
      drift.Value<DateTime>? timeStamp}) {
    return TransactionEditHistoriesCompanion(
      transactionEditId: transactionEditId ?? this.transactionEditId,
      editorParticipantId: editorParticipantId ?? this.editorParticipantId,
      transactionId: transactionId ?? this.transactionId,
      editedField: editedField ?? this.editedField,
      originalValue: originalValue ?? this.originalValue,
      newValue: newValue ?? this.newValue,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (transactionEditId.present) {
      map['transaction_edit_id'] = drift.Variable<int>(transactionEditId.value);
    }
    if (editorParticipantId.present) {
      map['editor_participant_id'] =
          drift.Variable<int>(editorParticipantId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = drift.Variable<int>(transactionId.value);
    }
    if (editedField.present) {
      map['edited_field'] = drift.Variable<String>(editedField.value);
    }
    if (originalValue.present) {
      map['original_value'] = drift.Variable<String>(originalValue.value);
    }
    if (newValue.present) {
      map['new_value'] = drift.Variable<String>(newValue.value);
    }
    if (timeStamp.present) {
      map['time_stamp'] = drift.Variable<DateTime>(timeStamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEditHistoriesCompanion(')
          ..write('transactionEditId: $transactionEditId, ')
          ..write('editorParticipantId: $editorParticipantId, ')
          ..write('transactionId: $transactionId, ')
          ..write('editedField: $editedField, ')
          ..write('originalValue: $originalValue, ')
          ..write('newValue: $newValue, ')
          ..write('timeStamp: $timeStamp')
          ..write(')'))
        .toString();
  }
}

class $VendorPreferencesTable extends VendorPreferences
    with drift.TableInfo<$VendorPreferencesTable, VendorPreference> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorPreferencesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _vendorPreferenceIdMeta =
      const drift.VerificationMeta('vendorPreferenceId');
  @override
  late final drift.GeneratedColumn<int> vendorPreferenceId =
      drift.GeneratedColumn<int>('vendor_preference_id', aliasedName, false,
          hasAutoIncrement: true,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _vendorIdMeta =
      const drift.VerificationMeta('vendorId');
  @override
  late final drift.GeneratedColumn<int> vendorId = drift.GeneratedColumn<int>(
      'vendor_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vendors (vendor_id)'));
  static const drift.VerificationMeta _participantIdMeta =
      const drift.VerificationMeta('participantId');
  @override
  late final drift.GeneratedColumn<int> participantId =
      drift.GeneratedColumn<int>('participant_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES participants (participant_id)'));
  @override
  List<drift.GeneratedColumn> get $columns =>
      [vendorPreferenceId, vendorId, participantId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendor_preferences';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<VendorPreference> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vendor_preference_id')) {
      context.handle(
          _vendorPreferenceIdMeta,
          vendorPreferenceId.isAcceptableOrUnknown(
              data['vendor_preference_id']!, _vendorPreferenceIdMeta));
    }
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
    } else if (isInserting) {
      context.missing(_vendorIdMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {vendorPreferenceId};
  @override
  VendorPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VendorPreference(
      vendorPreferenceId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}vendor_preference_id'])!,
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_id'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_id'])!,
    );
  }

  @override
  $VendorPreferencesTable createAlias(String alias) {
    return $VendorPreferencesTable(attachedDatabase, alias);
  }
}

class VendorPreference extends drift.DataClass
    implements drift.Insertable<VendorPreference> {
  final int vendorPreferenceId;
  final int vendorId;
  final int participantId;
  const VendorPreference(
      {required this.vendorPreferenceId,
      required this.vendorId,
      required this.participantId});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['vendor_preference_id'] = drift.Variable<int>(vendorPreferenceId);
    map['vendor_id'] = drift.Variable<int>(vendorId);
    map['participant_id'] = drift.Variable<int>(participantId);
    return map;
  }

  VendorPreferencesCompanion toCompanion(bool nullToAbsent) {
    return VendorPreferencesCompanion(
      vendorPreferenceId: drift.Value(vendorPreferenceId),
      vendorId: drift.Value(vendorId),
      participantId: drift.Value(participantId),
    );
  }

  factory VendorPreference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return VendorPreference(
      vendorPreferenceId: serializer.fromJson<int>(json['vendorPreferenceId']),
      vendorId: serializer.fromJson<int>(json['vendorId']),
      participantId: serializer.fromJson<int>(json['participantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vendorPreferenceId': serializer.toJson<int>(vendorPreferenceId),
      'vendorId': serializer.toJson<int>(vendorId),
      'participantId': serializer.toJson<int>(participantId),
    };
  }

  VendorPreference copyWith(
          {int? vendorPreferenceId, int? vendorId, int? participantId}) =>
      VendorPreference(
        vendorPreferenceId: vendorPreferenceId ?? this.vendorPreferenceId,
        vendorId: vendorId ?? this.vendorId,
        participantId: participantId ?? this.participantId,
      );
  VendorPreference copyWithCompanion(VendorPreferencesCompanion data) {
    return VendorPreference(
      vendorPreferenceId: data.vendorPreferenceId.present
          ? data.vendorPreferenceId.value
          : this.vendorPreferenceId,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VendorPreference(')
          ..write('vendorPreferenceId: $vendorPreferenceId, ')
          ..write('vendorId: $vendorId, ')
          ..write('participantId: $participantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(vendorPreferenceId, vendorId, participantId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VendorPreference &&
          other.vendorPreferenceId == this.vendorPreferenceId &&
          other.vendorId == this.vendorId &&
          other.participantId == this.participantId);
}

class VendorPreferencesCompanion
    extends drift.UpdateCompanion<VendorPreference> {
  final drift.Value<int> vendorPreferenceId;
  final drift.Value<int> vendorId;
  final drift.Value<int> participantId;
  const VendorPreferencesCompanion({
    this.vendorPreferenceId = const drift.Value.absent(),
    this.vendorId = const drift.Value.absent(),
    this.participantId = const drift.Value.absent(),
  });
  VendorPreferencesCompanion.insert({
    this.vendorPreferenceId = const drift.Value.absent(),
    required int vendorId,
    required int participantId,
  })  : vendorId = drift.Value(vendorId),
        participantId = drift.Value(participantId);
  static drift.Insertable<VendorPreference> custom({
    drift.Expression<int>? vendorPreferenceId,
    drift.Expression<int>? vendorId,
    drift.Expression<int>? participantId,
  }) {
    return drift.RawValuesInsertable({
      if (vendorPreferenceId != null)
        'vendor_preference_id': vendorPreferenceId,
      if (vendorId != null) 'vendor_id': vendorId,
      if (participantId != null) 'participant_id': participantId,
    });
  }

  VendorPreferencesCompanion copyWith(
      {drift.Value<int>? vendorPreferenceId,
      drift.Value<int>? vendorId,
      drift.Value<int>? participantId}) {
    return VendorPreferencesCompanion(
      vendorPreferenceId: vendorPreferenceId ?? this.vendorPreferenceId,
      vendorId: vendorId ?? this.vendorId,
      participantId: participantId ?? this.participantId,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (vendorPreferenceId.present) {
      map['vendor_preference_id'] =
          drift.Variable<int>(vendorPreferenceId.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = drift.Variable<int>(vendorId.value);
    }
    if (participantId.present) {
      map['participant_id'] = drift.Variable<int>(participantId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorPreferencesCompanion(')
          ..write('vendorPreferenceId: $vendorPreferenceId, ')
          ..write('vendorId: $vendorId, ')
          ..write('participantId: $participantId')
          ..write(')'))
        .toString();
  }
}

class $ParticipantIncomesTable extends ParticipantIncomes
    with drift.TableInfo<$ParticipantIncomesTable, ParticipantIncome> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantIncomesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _incomeIdMeta =
      const drift.VerificationMeta('incomeId');
  @override
  late final drift.GeneratedColumn<int> incomeId = drift.GeneratedColumn<int>(
      'income_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _participantIdMeta =
      const drift.VerificationMeta('participantId');
  @override
  late final drift.GeneratedColumn<int> participantId =
      drift.GeneratedColumn<int>('participant_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES participants (participant_id)'));
  static const drift.VerificationMeta _incomeAmountMeta =
      const drift.VerificationMeta('incomeAmount');
  @override
  late final drift.GeneratedColumn<double> incomeAmount =
      drift.GeneratedColumn<double>('income_amount', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const drift.VerificationMeta _incomeNameMeta =
      const drift.VerificationMeta('incomeName');
  @override
  late final drift.GeneratedColumn<String> incomeName =
      drift.GeneratedColumn<String>('income_name', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: false);
  static const drift.VerificationMeta _incomeTypeMeta =
      const drift.VerificationMeta('incomeType');
  @override
  late final drift.GeneratedColumn<String> incomeType =
      drift.GeneratedColumn<String>('income_type', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _dateReceivedMeta =
      const drift.VerificationMeta('dateReceived');
  @override
  late final drift.GeneratedColumn<DateTime> dateReceived =
      drift.GeneratedColumn<DateTime>('date_received', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          clientDefault: () => DateTime.now());
  @override
  List<drift.GeneratedColumn> get $columns => [
        incomeId,
        participantId,
        incomeAmount,
        incomeName,
        incomeType,
        dateReceived
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participant_incomes';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<ParticipantIncome> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('income_id')) {
      context.handle(_incomeIdMeta,
          incomeId.isAcceptableOrUnknown(data['income_id']!, _incomeIdMeta));
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('income_amount')) {
      context.handle(
          _incomeAmountMeta,
          incomeAmount.isAcceptableOrUnknown(
              data['income_amount']!, _incomeAmountMeta));
    } else if (isInserting) {
      context.missing(_incomeAmountMeta);
    }
    if (data.containsKey('income_name')) {
      context.handle(
          _incomeNameMeta,
          incomeName.isAcceptableOrUnknown(
              data['income_name']!, _incomeNameMeta));
    }
    if (data.containsKey('income_type')) {
      context.handle(
          _incomeTypeMeta,
          incomeType.isAcceptableOrUnknown(
              data['income_type']!, _incomeTypeMeta));
    } else if (isInserting) {
      context.missing(_incomeTypeMeta);
    }
    if (data.containsKey('date_received')) {
      context.handle(
          _dateReceivedMeta,
          dateReceived.isAcceptableOrUnknown(
              data['date_received']!, _dateReceivedMeta));
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {incomeId};
  @override
  ParticipantIncome map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParticipantIncome(
      incomeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}income_id'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_id'])!,
      incomeAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}income_amount'])!,
      incomeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}income_name']),
      incomeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}income_type'])!,
      dateReceived: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_received'])!,
    );
  }

  @override
  $ParticipantIncomesTable createAlias(String alias) {
    return $ParticipantIncomesTable(attachedDatabase, alias);
  }
}

class ParticipantIncome extends drift.DataClass
    implements drift.Insertable<ParticipantIncome> {
  final int incomeId;
  final int participantId;
  final double incomeAmount;
  final String? incomeName;
  final String incomeType;
  final DateTime dateReceived;
  const ParticipantIncome(
      {required this.incomeId,
      required this.participantId,
      required this.incomeAmount,
      this.incomeName,
      required this.incomeType,
      required this.dateReceived});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['income_id'] = drift.Variable<int>(incomeId);
    map['participant_id'] = drift.Variable<int>(participantId);
    map['income_amount'] = drift.Variable<double>(incomeAmount);
    if (!nullToAbsent || incomeName != null) {
      map['income_name'] = drift.Variable<String>(incomeName);
    }
    map['income_type'] = drift.Variable<String>(incomeType);
    map['date_received'] = drift.Variable<DateTime>(dateReceived);
    return map;
  }

  ParticipantIncomesCompanion toCompanion(bool nullToAbsent) {
    return ParticipantIncomesCompanion(
      incomeId: drift.Value(incomeId),
      participantId: drift.Value(participantId),
      incomeAmount: drift.Value(incomeAmount),
      incomeName: incomeName == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(incomeName),
      incomeType: drift.Value(incomeType),
      dateReceived: drift.Value(dateReceived),
    );
  }

  factory ParticipantIncome.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return ParticipantIncome(
      incomeId: serializer.fromJson<int>(json['incomeId']),
      participantId: serializer.fromJson<int>(json['participantId']),
      incomeAmount: serializer.fromJson<double>(json['incomeAmount']),
      incomeName: serializer.fromJson<String?>(json['incomeName']),
      incomeType: serializer.fromJson<String>(json['incomeType']),
      dateReceived: serializer.fromJson<DateTime>(json['dateReceived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'incomeId': serializer.toJson<int>(incomeId),
      'participantId': serializer.toJson<int>(participantId),
      'incomeAmount': serializer.toJson<double>(incomeAmount),
      'incomeName': serializer.toJson<String?>(incomeName),
      'incomeType': serializer.toJson<String>(incomeType),
      'dateReceived': serializer.toJson<DateTime>(dateReceived),
    };
  }

  ParticipantIncome copyWith(
          {int? incomeId,
          int? participantId,
          double? incomeAmount,
          drift.Value<String?> incomeName = const drift.Value.absent(),
          String? incomeType,
          DateTime? dateReceived}) =>
      ParticipantIncome(
        incomeId: incomeId ?? this.incomeId,
        participantId: participantId ?? this.participantId,
        incomeAmount: incomeAmount ?? this.incomeAmount,
        incomeName: incomeName.present ? incomeName.value : this.incomeName,
        incomeType: incomeType ?? this.incomeType,
        dateReceived: dateReceived ?? this.dateReceived,
      );
  ParticipantIncome copyWithCompanion(ParticipantIncomesCompanion data) {
    return ParticipantIncome(
      incomeId: data.incomeId.present ? data.incomeId.value : this.incomeId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      incomeAmount: data.incomeAmount.present
          ? data.incomeAmount.value
          : this.incomeAmount,
      incomeName:
          data.incomeName.present ? data.incomeName.value : this.incomeName,
      incomeType:
          data.incomeType.present ? data.incomeType.value : this.incomeType,
      dateReceived: data.dateReceived.present
          ? data.dateReceived.value
          : this.dateReceived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantIncome(')
          ..write('incomeId: $incomeId, ')
          ..write('participantId: $participantId, ')
          ..write('incomeAmount: $incomeAmount, ')
          ..write('incomeName: $incomeName, ')
          ..write('incomeType: $incomeType, ')
          ..write('dateReceived: $dateReceived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(incomeId, participantId, incomeAmount,
      incomeName, incomeType, dateReceived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParticipantIncome &&
          other.incomeId == this.incomeId &&
          other.participantId == this.participantId &&
          other.incomeAmount == this.incomeAmount &&
          other.incomeName == this.incomeName &&
          other.incomeType == this.incomeType &&
          other.dateReceived == this.dateReceived);
}

class ParticipantIncomesCompanion
    extends drift.UpdateCompanion<ParticipantIncome> {
  final drift.Value<int> incomeId;
  final drift.Value<int> participantId;
  final drift.Value<double> incomeAmount;
  final drift.Value<String?> incomeName;
  final drift.Value<String> incomeType;
  final drift.Value<DateTime> dateReceived;
  const ParticipantIncomesCompanion({
    this.incomeId = const drift.Value.absent(),
    this.participantId = const drift.Value.absent(),
    this.incomeAmount = const drift.Value.absent(),
    this.incomeName = const drift.Value.absent(),
    this.incomeType = const drift.Value.absent(),
    this.dateReceived = const drift.Value.absent(),
  });
  ParticipantIncomesCompanion.insert({
    this.incomeId = const drift.Value.absent(),
    required int participantId,
    required double incomeAmount,
    this.incomeName = const drift.Value.absent(),
    required String incomeType,
    this.dateReceived = const drift.Value.absent(),
  })  : participantId = drift.Value(participantId),
        incomeAmount = drift.Value(incomeAmount),
        incomeType = drift.Value(incomeType);
  static drift.Insertable<ParticipantIncome> custom({
    drift.Expression<int>? incomeId,
    drift.Expression<int>? participantId,
    drift.Expression<double>? incomeAmount,
    drift.Expression<String>? incomeName,
    drift.Expression<String>? incomeType,
    drift.Expression<DateTime>? dateReceived,
  }) {
    return drift.RawValuesInsertable({
      if (incomeId != null) 'income_id': incomeId,
      if (participantId != null) 'participant_id': participantId,
      if (incomeAmount != null) 'income_amount': incomeAmount,
      if (incomeName != null) 'income_name': incomeName,
      if (incomeType != null) 'income_type': incomeType,
      if (dateReceived != null) 'date_received': dateReceived,
    });
  }

  ParticipantIncomesCompanion copyWith(
      {drift.Value<int>? incomeId,
      drift.Value<int>? participantId,
      drift.Value<double>? incomeAmount,
      drift.Value<String?>? incomeName,
      drift.Value<String>? incomeType,
      drift.Value<DateTime>? dateReceived}) {
    return ParticipantIncomesCompanion(
      incomeId: incomeId ?? this.incomeId,
      participantId: participantId ?? this.participantId,
      incomeAmount: incomeAmount ?? this.incomeAmount,
      incomeName: incomeName ?? this.incomeName,
      incomeType: incomeType ?? this.incomeType,
      dateReceived: dateReceived ?? this.dateReceived,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (incomeId.present) {
      map['income_id'] = drift.Variable<int>(incomeId.value);
    }
    if (participantId.present) {
      map['participant_id'] = drift.Variable<int>(participantId.value);
    }
    if (incomeAmount.present) {
      map['income_amount'] = drift.Variable<double>(incomeAmount.value);
    }
    if (incomeName.present) {
      map['income_name'] = drift.Variable<String>(incomeName.value);
    }
    if (incomeType.present) {
      map['income_type'] = drift.Variable<String>(incomeType.value);
    }
    if (dateReceived.present) {
      map['date_received'] = drift.Variable<DateTime>(dateReceived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantIncomesCompanion(')
          ..write('incomeId: $incomeId, ')
          ..write('participantId: $participantId, ')
          ..write('incomeAmount: $incomeAmount, ')
          ..write('incomeName: $incomeName, ')
          ..write('incomeType: $incomeType, ')
          ..write('dateReceived: $dateReceived')
          ..write(')'))
        .toString();
  }
}

class $TemplateParticipantsTable extends TemplateParticipants
    with drift.TableInfo<$TemplateParticipantsTable, TemplateParticipant> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateParticipantsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _templateIdMeta =
      const drift.VerificationMeta('templateId');
  @override
  late final drift.GeneratedColumn<int> templateId = drift.GeneratedColumn<int>(
      'template_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES templates (template_id)'));
  static const drift.VerificationMeta _participantIdMeta =
      const drift.VerificationMeta('participantId');
  @override
  late final drift.GeneratedColumn<int> participantId =
      drift.GeneratedColumn<int>('participant_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES participants (participant_id)'));
  static const drift.VerificationMeta _permissionRoleMeta =
      const drift.VerificationMeta('permissionRole');
  @override
  late final drift.GeneratedColumn<String> permissionRole =
      drift.GeneratedColumn<String>('permission_role', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 50),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns =>
      [templateId, participantId, permissionRole];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_participants';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<TemplateParticipant> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('permission_role')) {
      context.handle(
          _permissionRoleMeta,
          permissionRole.isAcceptableOrUnknown(
              data['permission_role']!, _permissionRoleMeta));
    } else if (isInserting) {
      context.missing(_permissionRoleMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => const {};
  @override
  TemplateParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateParticipant(
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}template_id'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_id'])!,
      permissionRole: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permission_role'])!,
    );
  }

  @override
  $TemplateParticipantsTable createAlias(String alias) {
    return $TemplateParticipantsTable(attachedDatabase, alias);
  }
}

class TemplateParticipant extends drift.DataClass
    implements drift.Insertable<TemplateParticipant> {
  final int templateId;
  final int participantId;
  final String permissionRole;
  const TemplateParticipant(
      {required this.templateId,
      required this.participantId,
      required this.permissionRole});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['template_id'] = drift.Variable<int>(templateId);
    map['participant_id'] = drift.Variable<int>(participantId);
    map['permission_role'] = drift.Variable<String>(permissionRole);
    return map;
  }

  TemplateParticipantsCompanion toCompanion(bool nullToAbsent) {
    return TemplateParticipantsCompanion(
      templateId: drift.Value(templateId),
      participantId: drift.Value(participantId),
      permissionRole: drift.Value(permissionRole),
    );
  }

  factory TemplateParticipant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return TemplateParticipant(
      templateId: serializer.fromJson<int>(json['templateId']),
      participantId: serializer.fromJson<int>(json['participantId']),
      permissionRole: serializer.fromJson<String>(json['permissionRole']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateId': serializer.toJson<int>(templateId),
      'participantId': serializer.toJson<int>(participantId),
      'permissionRole': serializer.toJson<String>(permissionRole),
    };
  }

  TemplateParticipant copyWith(
          {int? templateId, int? participantId, String? permissionRole}) =>
      TemplateParticipant(
        templateId: templateId ?? this.templateId,
        participantId: participantId ?? this.participantId,
        permissionRole: permissionRole ?? this.permissionRole,
      );
  TemplateParticipant copyWithCompanion(TemplateParticipantsCompanion data) {
    return TemplateParticipant(
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      permissionRole: data.permissionRole.present
          ? data.permissionRole.value
          : this.permissionRole,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateParticipant(')
          ..write('templateId: $templateId, ')
          ..write('participantId: $participantId, ')
          ..write('permissionRole: $permissionRole')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(templateId, participantId, permissionRole);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateParticipant &&
          other.templateId == this.templateId &&
          other.participantId == this.participantId &&
          other.permissionRole == this.permissionRole);
}

class TemplateParticipantsCompanion
    extends drift.UpdateCompanion<TemplateParticipant> {
  final drift.Value<int> templateId;
  final drift.Value<int> participantId;
  final drift.Value<String> permissionRole;
  final drift.Value<int> rowid;
  const TemplateParticipantsCompanion({
    this.templateId = const drift.Value.absent(),
    this.participantId = const drift.Value.absent(),
    this.permissionRole = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  });
  TemplateParticipantsCompanion.insert({
    required int templateId,
    required int participantId,
    required String permissionRole,
    this.rowid = const drift.Value.absent(),
  })  : templateId = drift.Value(templateId),
        participantId = drift.Value(participantId),
        permissionRole = drift.Value(permissionRole);
  static drift.Insertable<TemplateParticipant> custom({
    drift.Expression<int>? templateId,
    drift.Expression<int>? participantId,
    drift.Expression<String>? permissionRole,
    drift.Expression<int>? rowid,
  }) {
    return drift.RawValuesInsertable({
      if (templateId != null) 'template_id': templateId,
      if (participantId != null) 'participant_id': participantId,
      if (permissionRole != null) 'permission_role': permissionRole,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplateParticipantsCompanion copyWith(
      {drift.Value<int>? templateId,
      drift.Value<int>? participantId,
      drift.Value<String>? permissionRole,
      drift.Value<int>? rowid}) {
    return TemplateParticipantsCompanion(
      templateId: templateId ?? this.templateId,
      participantId: participantId ?? this.participantId,
      permissionRole: permissionRole ?? this.permissionRole,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (templateId.present) {
      map['template_id'] = drift.Variable<int>(templateId.value);
    }
    if (participantId.present) {
      map['participant_id'] = drift.Variable<int>(participantId.value);
    }
    if (permissionRole.present) {
      map['permission_role'] = drift.Variable<String>(permissionRole.value);
    }
    if (rowid.present) {
      map['rowid'] = drift.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateParticipantsCompanion(')
          ..write('templateId: $templateId, ')
          ..write('participantId: $participantId, ')
          ..write('permissionRole: $permissionRole, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChartSnapshotsTable extends ChartSnapshots
    with drift.TableInfo<$ChartSnapshotsTable, ChartSnapshot> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChartSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _snapshotIdMeta =
      const drift.VerificationMeta('snapshotId');
  @override
  late final drift.GeneratedColumn<int> snapshotId = drift.GeneratedColumn<int>(
      'snapshot_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _nameMeta =
      const drift.VerificationMeta('name');
  @override
  late final drift.GeneratedColumn<String> name = drift.GeneratedColumn<String>(
      'name', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const drift.VerificationMeta _configurationMeta =
      const drift.VerificationMeta('configuration');
  @override
  late final drift.GeneratedColumn<String> configuration =
      drift.GeneratedColumn<String>('configuration', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const drift.VerificationMeta _createdAtMeta =
      const drift.VerificationMeta('createdAt');
  @override
  late final drift.GeneratedColumn<DateTime> createdAt =
      drift.GeneratedColumn<DateTime>('created_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const drift.VerificationMeta _permissionRoleMeta =
      const drift.VerificationMeta('permissionRole');
  @override
  late final drift.GeneratedColumn<String> permissionRole =
      drift.GeneratedColumn<String>('permission_role', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 50),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const drift.VerificationMeta _associatedTemplateMeta =
      const drift.VerificationMeta('associatedTemplate');
  @override
  late final drift.GeneratedColumn<int> associatedTemplate =
      drift.GeneratedColumn<int>('associated_template', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES templates (template_id)'));
  @override
  List<drift.GeneratedColumn> get $columns => [
        snapshotId,
        name,
        configuration,
        createdAt,
        permissionRole,
        associatedTemplate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chart_snapshots';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<ChartSnapshot> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('snapshot_id')) {
      context.handle(
          _snapshotIdMeta,
          snapshotId.isAcceptableOrUnknown(
              data['snapshot_id']!, _snapshotIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('configuration')) {
      context.handle(
          _configurationMeta,
          configuration.isAcceptableOrUnknown(
              data['configuration']!, _configurationMeta));
    } else if (isInserting) {
      context.missing(_configurationMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('permission_role')) {
      context.handle(
          _permissionRoleMeta,
          permissionRole.isAcceptableOrUnknown(
              data['permission_role']!, _permissionRoleMeta));
    } else if (isInserting) {
      context.missing(_permissionRoleMeta);
    }
    if (data.containsKey('associated_template')) {
      context.handle(
          _associatedTemplateMeta,
          associatedTemplate.isAcceptableOrUnknown(
              data['associated_template']!, _associatedTemplateMeta));
    } else if (isInserting) {
      context.missing(_associatedTemplateMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {snapshotId};
  @override
  ChartSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChartSnapshot(
      snapshotId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}snapshot_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      configuration: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}configuration'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      permissionRole: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permission_role'])!,
      associatedTemplate: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}associated_template'])!,
    );
  }

  @override
  $ChartSnapshotsTable createAlias(String alias) {
    return $ChartSnapshotsTable(attachedDatabase, alias);
  }
}

class ChartSnapshot extends drift.DataClass
    implements drift.Insertable<ChartSnapshot> {
  final int snapshotId;
  final String? name;
  final String configuration;
  final DateTime createdAt;
  final String permissionRole;
  final int associatedTemplate;
  const ChartSnapshot(
      {required this.snapshotId,
      this.name,
      required this.configuration,
      required this.createdAt,
      required this.permissionRole,
      required this.associatedTemplate});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['snapshot_id'] = drift.Variable<int>(snapshotId);
    if (!nullToAbsent || name != null) {
      map['name'] = drift.Variable<String>(name);
    }
    map['configuration'] = drift.Variable<String>(configuration);
    map['created_at'] = drift.Variable<DateTime>(createdAt);
    map['permission_role'] = drift.Variable<String>(permissionRole);
    map['associated_template'] = drift.Variable<int>(associatedTemplate);
    return map;
  }

  ChartSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ChartSnapshotsCompanion(
      snapshotId: drift.Value(snapshotId),
      name: name == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(name),
      configuration: drift.Value(configuration),
      createdAt: drift.Value(createdAt),
      permissionRole: drift.Value(permissionRole),
      associatedTemplate: drift.Value(associatedTemplate),
    );
  }

  factory ChartSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return ChartSnapshot(
      snapshotId: serializer.fromJson<int>(json['snapshotId']),
      name: serializer.fromJson<String?>(json['name']),
      configuration: serializer.fromJson<String>(json['configuration']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      permissionRole: serializer.fromJson<String>(json['permissionRole']),
      associatedTemplate: serializer.fromJson<int>(json['associatedTemplate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'snapshotId': serializer.toJson<int>(snapshotId),
      'name': serializer.toJson<String?>(name),
      'configuration': serializer.toJson<String>(configuration),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'permissionRole': serializer.toJson<String>(permissionRole),
      'associatedTemplate': serializer.toJson<int>(associatedTemplate),
    };
  }

  ChartSnapshot copyWith(
          {int? snapshotId,
          drift.Value<String?> name = const drift.Value.absent(),
          String? configuration,
          DateTime? createdAt,
          String? permissionRole,
          int? associatedTemplate}) =>
      ChartSnapshot(
        snapshotId: snapshotId ?? this.snapshotId,
        name: name.present ? name.value : this.name,
        configuration: configuration ?? this.configuration,
        createdAt: createdAt ?? this.createdAt,
        permissionRole: permissionRole ?? this.permissionRole,
        associatedTemplate: associatedTemplate ?? this.associatedTemplate,
      );
  ChartSnapshot copyWithCompanion(ChartSnapshotsCompanion data) {
    return ChartSnapshot(
      snapshotId:
          data.snapshotId.present ? data.snapshotId.value : this.snapshotId,
      name: data.name.present ? data.name.value : this.name,
      configuration: data.configuration.present
          ? data.configuration.value
          : this.configuration,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      permissionRole: data.permissionRole.present
          ? data.permissionRole.value
          : this.permissionRole,
      associatedTemplate: data.associatedTemplate.present
          ? data.associatedTemplate.value
          : this.associatedTemplate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChartSnapshot(')
          ..write('snapshotId: $snapshotId, ')
          ..write('name: $name, ')
          ..write('configuration: $configuration, ')
          ..write('createdAt: $createdAt, ')
          ..write('permissionRole: $permissionRole, ')
          ..write('associatedTemplate: $associatedTemplate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(snapshotId, name, configuration, createdAt,
      permissionRole, associatedTemplate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChartSnapshot &&
          other.snapshotId == this.snapshotId &&
          other.name == this.name &&
          other.configuration == this.configuration &&
          other.createdAt == this.createdAt &&
          other.permissionRole == this.permissionRole &&
          other.associatedTemplate == this.associatedTemplate);
}

class ChartSnapshotsCompanion extends drift.UpdateCompanion<ChartSnapshot> {
  final drift.Value<int> snapshotId;
  final drift.Value<String?> name;
  final drift.Value<String> configuration;
  final drift.Value<DateTime> createdAt;
  final drift.Value<String> permissionRole;
  final drift.Value<int> associatedTemplate;
  const ChartSnapshotsCompanion({
    this.snapshotId = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    this.configuration = const drift.Value.absent(),
    this.createdAt = const drift.Value.absent(),
    this.permissionRole = const drift.Value.absent(),
    this.associatedTemplate = const drift.Value.absent(),
  });
  ChartSnapshotsCompanion.insert({
    this.snapshotId = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    required String configuration,
    required DateTime createdAt,
    required String permissionRole,
    required int associatedTemplate,
  })  : configuration = drift.Value(configuration),
        createdAt = drift.Value(createdAt),
        permissionRole = drift.Value(permissionRole),
        associatedTemplate = drift.Value(associatedTemplate);
  static drift.Insertable<ChartSnapshot> custom({
    drift.Expression<int>? snapshotId,
    drift.Expression<String>? name,
    drift.Expression<String>? configuration,
    drift.Expression<DateTime>? createdAt,
    drift.Expression<String>? permissionRole,
    drift.Expression<int>? associatedTemplate,
  }) {
    return drift.RawValuesInsertable({
      if (snapshotId != null) 'snapshot_id': snapshotId,
      if (name != null) 'name': name,
      if (configuration != null) 'configuration': configuration,
      if (createdAt != null) 'created_at': createdAt,
      if (permissionRole != null) 'permission_role': permissionRole,
      if (associatedTemplate != null) 'associated_template': associatedTemplate,
    });
  }

  ChartSnapshotsCompanion copyWith(
      {drift.Value<int>? snapshotId,
      drift.Value<String?>? name,
      drift.Value<String>? configuration,
      drift.Value<DateTime>? createdAt,
      drift.Value<String>? permissionRole,
      drift.Value<int>? associatedTemplate}) {
    return ChartSnapshotsCompanion(
      snapshotId: snapshotId ?? this.snapshotId,
      name: name ?? this.name,
      configuration: configuration ?? this.configuration,
      createdAt: createdAt ?? this.createdAt,
      permissionRole: permissionRole ?? this.permissionRole,
      associatedTemplate: associatedTemplate ?? this.associatedTemplate,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (snapshotId.present) {
      map['snapshot_id'] = drift.Variable<int>(snapshotId.value);
    }
    if (name.present) {
      map['name'] = drift.Variable<String>(name.value);
    }
    if (configuration.present) {
      map['configuration'] = drift.Variable<String>(configuration.value);
    }
    if (createdAt.present) {
      map['created_at'] = drift.Variable<DateTime>(createdAt.value);
    }
    if (permissionRole.present) {
      map['permission_role'] = drift.Variable<String>(permissionRole.value);
    }
    if (associatedTemplate.present) {
      map['associated_template'] =
          drift.Variable<int>(associatedTemplate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChartSnapshotsCompanion(')
          ..write('snapshotId: $snapshotId, ')
          ..write('name: $name, ')
          ..write('configuration: $configuration, ')
          ..write('createdAt: $createdAt, ')
          ..write('permissionRole: $permissionRole, ')
          ..write('associatedTemplate: $associatedTemplate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends drift.GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  late final $SyncLogTable syncLog = $SyncLogTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $VendorsTable vendors = $VendorsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionEditHistoriesTable transactionEditHistories =
      $TransactionEditHistoriesTable(this);
  late final $VendorPreferencesTable vendorPreferences =
      $VendorPreferencesTable(this);
  late final $ParticipantIncomesTable participantIncomes =
      $ParticipantIncomesTable(this);
  late final $TemplateParticipantsTable templateParticipants =
      $TemplateParticipantsTable(this);
  late final $ChartSnapshotsTable chartSnapshots = $ChartSnapshotsTable(this);
  @override
  Iterable<drift.TableInfo<drift.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<drift.TableInfo<drift.Table, Object?>>();
  @override
  List<drift.DatabaseSchemaEntity> get allSchemaEntities => [
        participants,
        syncLog,
        templates,
        categories,
        accounts,
        vendors,
        transactions,
        transactionEditHistories,
        vendorPreferences,
        participantIncomes,
        templateParticipants,
        chartSnapshots
      ];
}

typedef $$ParticipantsTableCreateCompanionBuilder = ParticipantsCompanion
    Function({
  drift.Value<int> participantId,
  required String firstName,
  drift.Value<String?> lastName,
  drift.Value<String?> nickName,
  required String role,
  required String email,
  required String pwdhash,
});
typedef $$ParticipantsTableUpdateCompanionBuilder = ParticipantsCompanion
    Function({
  drift.Value<int> participantId,
  drift.Value<String> firstName,
  drift.Value<String?> lastName,
  drift.Value<String?> nickName,
  drift.Value<String> role,
  drift.Value<String> email,
  drift.Value<String> pwdhash,
});

final class $$ParticipantsTableReferences extends drift
    .BaseReferences<_$AppDatabase, $ParticipantsTable, Participant> {
  $$ParticipantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static drift.MultiTypedResultKey<$TemplatesTable, List<Template>>
      _templatesRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.templates,
              aliasName: drift.$_aliasNameGenerator(
                  db.participants.participantId,
                  db.templates.creatorParticipantId));

  $$TemplatesTableProcessedTableManager get templatesRefs {
    final manager = $$TemplatesTableTableManager($_db, $_db.templates).filter(
        (f) => f.creatorParticipantId.participantId
            .sqlEquals($_itemColumn<int>('participant_id')!));

    final cache = $_typedResult.readTableOrNull(_templatesRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$AccountsTable, List<Account>>
      _accountsRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.accounts,
              aliasName: drift.$_aliasNameGenerator(
                  db.participants.participantId,
                  db.accounts.responsibleParticipantId));

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager($_db, $_db.accounts).filter(
        (f) => f.responsibleParticipantId.participantId
            .sqlEquals($_itemColumn<int>('participant_id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionOwnerTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.transactions,
              aliasName: drift.$_aliasNameGenerator(
                  db.participants.participantId,
                  db.transactions.participantId));

  $$TransactionsTableProcessedTableManager get transactionOwner {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.participantId.participantId
            .sqlEquals($_itemColumn<int>('participant_id')!));

    final cache = $_typedResult.readTableOrNull(_transactionOwnerTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionEditorTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.transactions,
              aliasName: drift.$_aliasNameGenerator(
                  db.participants.participantId,
                  db.transactions.editorParticipantId));

  $$TransactionsTableProcessedTableManager get transactionEditor {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.editorParticipantId.participantId
            .sqlEquals($_itemColumn<int>('participant_id')!));

    final cache = $_typedResult.readTableOrNull(_transactionEditorTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$TransactionEditHistoriesTable,
      List<TransactionEditHistory>> _transactionEditHistoriesRefsTable(
          _$AppDatabase db) =>
      drift.MultiTypedResultKey.fromTable(db.transactionEditHistories,
          aliasName: drift.$_aliasNameGenerator(db.participants.participantId,
              db.transactionEditHistories.editorParticipantId));

  $$TransactionEditHistoriesTableProcessedTableManager
      get transactionEditHistoriesRefs {
    final manager = $$TransactionEditHistoriesTableTableManager(
            $_db, $_db.transactionEditHistories)
        .filter((f) => f.editorParticipantId.participantId
            .sqlEquals($_itemColumn<int>('participant_id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionEditHistoriesRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift
      .MultiTypedResultKey<$VendorPreferencesTable, List<VendorPreference>>
      _vendorPreferencesRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.vendorPreferences,
              aliasName: drift.$_aliasNameGenerator(
                  db.participants.participantId,
                  db.vendorPreferences.participantId));

  $$VendorPreferencesTableProcessedTableManager get vendorPreferencesRefs {
    final manager =
        $$VendorPreferencesTableTableManager($_db, $_db.vendorPreferences)
            .filter((f) => f.participantId.participantId
                .sqlEquals($_itemColumn<int>('participant_id')!));

    final cache =
        $_typedResult.readTableOrNull(_vendorPreferencesRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift
      .MultiTypedResultKey<$ParticipantIncomesTable, List<ParticipantIncome>>
      _participantIncomesRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.participantIncomes,
              aliasName: drift.$_aliasNameGenerator(
                  db.participants.participantId,
                  db.participantIncomes.participantId));

  $$ParticipantIncomesTableProcessedTableManager get participantIncomesRefs {
    final manager =
        $$ParticipantIncomesTableTableManager($_db, $_db.participantIncomes)
            .filter((f) => f.participantId.participantId
                .sqlEquals($_itemColumn<int>('participant_id')!));

    final cache =
        $_typedResult.readTableOrNull(_participantIncomesRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$TemplateParticipantsTable,
      List<TemplateParticipant>> _templateParticipantsRefsTable(
          _$AppDatabase db) =>
      drift.MultiTypedResultKey.fromTable(db.templateParticipants,
          aliasName: drift.$_aliasNameGenerator(db.participants.participantId,
              db.templateParticipants.participantId));

  $$TemplateParticipantsTableProcessedTableManager
      get templateParticipantsRefs {
    final manager =
        $$TemplateParticipantsTableTableManager($_db, $_db.templateParticipants)
            .filter((f) => f.participantId.participantId
                .sqlEquals($_itemColumn<int>('participant_id')!));

    final cache =
        $_typedResult.readTableOrNull(_templateParticipantsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ParticipantsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get participantId => $composableBuilder(
      column: $table.participantId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get nickName => $composableBuilder(
      column: $table.nickName,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get pwdhash => $composableBuilder(
      column: $table.pwdhash, builder: (column) => drift.ColumnFilters(column));

  drift.Expression<bool> templatesRefs(
      drift.Expression<bool> Function($$TemplatesTableFilterComposer f) f) {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.creatorParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> accountsRefs(
      drift.Expression<bool> Function($$AccountsTableFilterComposer f) f) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.responsibleParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> transactionOwner(
      drift.Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> transactionEditor(
      drift.Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.editorParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> transactionEditHistoriesRefs(
      drift.Expression<bool> Function(
              $$TransactionEditHistoriesTableFilterComposer f)
          f) {
    final $$TransactionEditHistoriesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.participantId,
            referencedTable: $db.transactionEditHistories,
            getReferencedColumn: (t) => t.editorParticipantId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionEditHistoriesTableFilterComposer(
                  $db: $db,
                  $table: $db.transactionEditHistories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  drift.Expression<bool> vendorPreferencesRefs(
      drift.Expression<bool> Function($$VendorPreferencesTableFilterComposer f)
          f) {
    final $$VendorPreferencesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.vendorPreferences,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorPreferencesTableFilterComposer(
              $db: $db,
              $table: $db.vendorPreferences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> participantIncomesRefs(
      drift.Expression<bool> Function($$ParticipantIncomesTableFilterComposer f)
          f) {
    final $$ParticipantIncomesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participantIncomes,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantIncomesTableFilterComposer(
              $db: $db,
              $table: $db.participantIncomes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> templateParticipantsRefs(
      drift.Expression<bool> Function(
              $$TemplateParticipantsTableFilterComposer f)
          f) {
    final $$TemplateParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.templateParticipants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.templateParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ParticipantsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get participantId => $composableBuilder(
      column: $table.participantId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get nickName => $composableBuilder(
      column: $table.nickName,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get pwdhash => $composableBuilder(
      column: $table.pwdhash,
      builder: (column) => drift.ColumnOrderings(column));
}

class $$ParticipantsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get participantId => $composableBuilder(
      column: $table.participantId, builder: (column) => column);

  drift.GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  drift.GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  drift.GeneratedColumn<String> get nickName =>
      $composableBuilder(column: $table.nickName, builder: (column) => column);

  drift.GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  drift.GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  drift.GeneratedColumn<String> get pwdhash =>
      $composableBuilder(column: $table.pwdhash, builder: (column) => column);

  drift.Expression<T> templatesRefs<T extends Object>(
      drift.Expression<T> Function($$TemplatesTableAnnotationComposer a) f) {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.creatorParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<T> accountsRefs<T extends Object>(
      drift.Expression<T> Function($$AccountsTableAnnotationComposer a) f) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.responsibleParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<T> transactionOwner<T extends Object>(
      drift.Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<T> transactionEditor<T extends Object>(
      drift.Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.editorParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<T> transactionEditHistoriesRefs<T extends Object>(
      drift.Expression<T> Function(
              $$TransactionEditHistoriesTableAnnotationComposer a)
          f) {
    final $$TransactionEditHistoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.participantId,
            referencedTable: $db.transactionEditHistories,
            getReferencedColumn: (t) => t.editorParticipantId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionEditHistoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionEditHistories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  drift.Expression<T> vendorPreferencesRefs<T extends Object>(
      drift.Expression<T> Function($$VendorPreferencesTableAnnotationComposer a)
          f) {
    final $$VendorPreferencesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.participantId,
            referencedTable: $db.vendorPreferences,
            getReferencedColumn: (t) => t.participantId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$VendorPreferencesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.vendorPreferences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  drift.Expression<T> participantIncomesRefs<T extends Object>(
      drift.Expression<T> Function(
              $$ParticipantIncomesTableAnnotationComposer a)
          f) {
    final $$ParticipantIncomesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.participantId,
            referencedTable: $db.participantIncomes,
            getReferencedColumn: (t) => t.participantId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ParticipantIncomesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.participantIncomes,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  drift.Expression<T> templateParticipantsRefs<T extends Object>(
      drift.Expression<T> Function(
              $$TemplateParticipantsTableAnnotationComposer a)
          f) {
    final $$TemplateParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.participantId,
            referencedTable: $db.templateParticipants,
            getReferencedColumn: (t) => t.participantId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.templateParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ParticipantsTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (Participant, $$ParticipantsTableReferences),
    Participant,
    drift.PrefetchHooks Function(
        {bool templatesRefs,
        bool accountsRefs,
        bool transactionOwner,
        bool transactionEditor,
        bool transactionEditHistoriesRefs,
        bool vendorPreferencesRefs,
        bool participantIncomesRefs,
        bool templateParticipantsRefs})> {
  $$ParticipantsTableTableManager(_$AppDatabase db, $ParticipantsTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> participantId = const drift.Value.absent(),
            drift.Value<String> firstName = const drift.Value.absent(),
            drift.Value<String?> lastName = const drift.Value.absent(),
            drift.Value<String?> nickName = const drift.Value.absent(),
            drift.Value<String> role = const drift.Value.absent(),
            drift.Value<String> email = const drift.Value.absent(),
            drift.Value<String> pwdhash = const drift.Value.absent(),
          }) =>
              ParticipantsCompanion(
            participantId: participantId,
            firstName: firstName,
            lastName: lastName,
            nickName: nickName,
            role: role,
            email: email,
            pwdhash: pwdhash,
          ),
          createCompanionCallback: ({
            drift.Value<int> participantId = const drift.Value.absent(),
            required String firstName,
            drift.Value<String?> lastName = const drift.Value.absent(),
            drift.Value<String?> nickName = const drift.Value.absent(),
            required String role,
            required String email,
            required String pwdhash,
          }) =>
              ParticipantsCompanion.insert(
            participantId: participantId,
            firstName: firstName,
            lastName: lastName,
            nickName: nickName,
            role: role,
            email: email,
            pwdhash: pwdhash,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ParticipantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {templatesRefs = false,
              accountsRefs = false,
              transactionOwner = false,
              transactionEditor = false,
              transactionEditHistoriesRefs = false,
              vendorPreferencesRefs = false,
              participantIncomesRefs = false,
              templateParticipantsRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (templatesRefs) db.templates,
                if (accountsRefs) db.accounts,
                if (transactionOwner) db.transactions,
                if (transactionEditor) db.transactions,
                if (transactionEditHistoriesRefs) db.transactionEditHistories,
                if (vendorPreferencesRefs) db.vendorPreferences,
                if (participantIncomesRefs) db.participantIncomes,
                if (templateParticipantsRefs) db.templateParticipants
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (templatesRefs)
                    await drift
                        .$_getPrefetchedData<Participant, $ParticipantsTable,
                                Template>(
                            currentTable: table,
                            referencedTable:
                                $$ParticipantsTableReferences
                                    ._templatesRefsTable(db),
                            managerFromTypedResult:
                                (p0) =>
                                    $$ParticipantsTableReferences(db, table,
                                            p0)
                                        .templatesRefs,
                            referencedItemsForCurrentItem: (item,
                                    referencedItems) =>
                                referencedItems.where((e) =>
                                    e.creatorParticipantId ==
                                    item.participantId),
                            typedResults: items),
                  if (accountsRefs)
                    await drift
                        .$_getPrefetchedData<Participant, $ParticipantsTable,
                                Account>(
                            currentTable: table,
                            referencedTable:
                                $$ParticipantsTableReferences
                                    ._accountsRefsTable(db),
                            managerFromTypedResult:
                                (p0) =>
                                    $$ParticipantsTableReferences(db, table,
                                            p0)
                                        .accountsRefs,
                            referencedItemsForCurrentItem: (item,
                                    referencedItems) =>
                                referencedItems.where((e) =>
                                    e.responsibleParticipantId ==
                                    item.participantId),
                            typedResults: items),
                  if (transactionOwner)
                    await drift.$_getPrefetchedData<Participant,
                            $ParticipantsTable, Transaction>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._transactionOwnerTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .transactionOwner,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.participantId),
                        typedResults: items),
                  if (transactionEditor)
                    await drift.$_getPrefetchedData<Participant,
                            $ParticipantsTable, Transaction>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._transactionEditorTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .transactionEditor,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) =>
                                e.editorParticipantId == item.participantId),
                        typedResults: items),
                  if (transactionEditHistoriesRefs)
                    await drift.$_getPrefetchedData<Participant,
                            $ParticipantsTable, TransactionEditHistory>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._transactionEditHistoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .transactionEditHistoriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) =>
                                e.editorParticipantId == item.participantId),
                        typedResults: items),
                  if (vendorPreferencesRefs)
                    await drift.$_getPrefetchedData<Participant,
                            $ParticipantsTable, VendorPreference>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._vendorPreferencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .vendorPreferencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.participantId),
                        typedResults: items),
                  if (participantIncomesRefs)
                    await drift.$_getPrefetchedData<Participant,
                            $ParticipantsTable, ParticipantIncome>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._participantIncomesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .participantIncomesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.participantId),
                        typedResults: items),
                  if (templateParticipantsRefs)
                    await drift.$_getPrefetchedData<Participant,
                            $ParticipantsTable, TemplateParticipant>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._templateParticipantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .templateParticipantsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.participantId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ParticipantsTableProcessedTableManager = drift.ProcessedTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (Participant, $$ParticipantsTableReferences),
    Participant,
    drift.PrefetchHooks Function(
        {bool templatesRefs,
        bool accountsRefs,
        bool transactionOwner,
        bool transactionEditor,
        bool transactionEditHistoriesRefs,
        bool vendorPreferencesRefs,
        bool participantIncomesRefs,
        bool templateParticipantsRefs})>;
typedef $$SyncLogTableCreateCompanionBuilder = SyncLogCompanion Function({
  drift.Value<int> syncId,
  required String syncDirection,
  required bool synced,
  required bool success,
  drift.Value<String?> errorMessage,
  required String sheetUrl,
});
typedef $$SyncLogTableUpdateCompanionBuilder = SyncLogCompanion Function({
  drift.Value<int> syncId,
  drift.Value<String> syncDirection,
  drift.Value<bool> synced,
  drift.Value<bool> success,
  drift.Value<String?> errorMessage,
  drift.Value<String> sheetUrl,
});

final class $$SyncLogTableReferences
    extends drift.BaseReferences<_$AppDatabase, $SyncLogTable, SyncLogEntry> {
  $$SyncLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static drift.MultiTypedResultKey<$TemplatesTable, List<Template>>
      _templatesRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.templates,
              aliasName: drift.$_aliasNameGenerator(
                  db.syncLog.syncId, db.templates.syncId));

  $$TemplatesTableProcessedTableManager get templatesRefs {
    final manager = $$TemplatesTableTableManager($_db, $_db.templates).filter(
        (f) => f.syncId.syncId.sqlEquals($_itemColumn<int>('sync_id')!));

    final cache = $_typedResult.readTableOrNull(_templatesRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.transactions,
              aliasName: drift.$_aliasNameGenerator(
                  db.syncLog.syncId, db.transactions.syncId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter(
            (f) => f.syncId.syncId.sqlEquals($_itemColumn<int>('sync_id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SyncLogTableFilterComposer
    extends drift.Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get syncId => $composableBuilder(
      column: $table.syncId, builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get syncDirection => $composableBuilder(
      column: $table.syncDirection,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<bool> get success => $composableBuilder(
      column: $table.success, builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get sheetUrl => $composableBuilder(
      column: $table.sheetUrl,
      builder: (column) => drift.ColumnFilters(column));

  drift.Expression<bool> templatesRefs(
      drift.Expression<bool> Function($$TemplatesTableFilterComposer f) f) {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> transactionsRefs(
      drift.Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SyncLogTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get syncId => $composableBuilder(
      column: $table.syncId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get syncDirection => $composableBuilder(
      column: $table.syncDirection,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<bool> get success => $composableBuilder(
      column: $table.success,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get sheetUrl => $composableBuilder(
      column: $table.sheetUrl,
      builder: (column) => drift.ColumnOrderings(column));
}

class $$SyncLogTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  drift.GeneratedColumn<String> get syncDirection => $composableBuilder(
      column: $table.syncDirection, builder: (column) => column);

  drift.GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  drift.GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  drift.GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  drift.GeneratedColumn<String> get sheetUrl =>
      $composableBuilder(column: $table.sheetUrl, builder: (column) => column);

  drift.Expression<T> templatesRefs<T extends Object>(
      drift.Expression<T> Function($$TemplatesTableAnnotationComposer a) f) {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<T> transactionsRefs<T extends Object>(
      drift.Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SyncLogTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $SyncLogTable,
    SyncLogEntry,
    $$SyncLogTableFilterComposer,
    $$SyncLogTableOrderingComposer,
    $$SyncLogTableAnnotationComposer,
    $$SyncLogTableCreateCompanionBuilder,
    $$SyncLogTableUpdateCompanionBuilder,
    (SyncLogEntry, $$SyncLogTableReferences),
    SyncLogEntry,
    drift.PrefetchHooks Function({bool templatesRefs, bool transactionsRefs})> {
  $$SyncLogTableTableManager(_$AppDatabase db, $SyncLogTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> syncId = const drift.Value.absent(),
            drift.Value<String> syncDirection = const drift.Value.absent(),
            drift.Value<bool> synced = const drift.Value.absent(),
            drift.Value<bool> success = const drift.Value.absent(),
            drift.Value<String?> errorMessage = const drift.Value.absent(),
            drift.Value<String> sheetUrl = const drift.Value.absent(),
          }) =>
              SyncLogCompanion(
            syncId: syncId,
            syncDirection: syncDirection,
            synced: synced,
            success: success,
            errorMessage: errorMessage,
            sheetUrl: sheetUrl,
          ),
          createCompanionCallback: ({
            drift.Value<int> syncId = const drift.Value.absent(),
            required String syncDirection,
            required bool synced,
            required bool success,
            drift.Value<String?> errorMessage = const drift.Value.absent(),
            required String sheetUrl,
          }) =>
              SyncLogCompanion.insert(
            syncId: syncId,
            syncDirection: syncDirection,
            synced: synced,
            success: success,
            errorMessage: errorMessage,
            sheetUrl: sheetUrl,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SyncLogTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {templatesRefs = false, transactionsRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (templatesRefs) db.templates,
                if (transactionsRefs) db.transactions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (templatesRefs)
                    await drift.$_getPrefetchedData<SyncLogEntry, $SyncLogTable,
                            Template>(
                        currentTable: table,
                        referencedTable:
                            $$SyncLogTableReferences._templatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SyncLogTableReferences(db, table, p0)
                                .templatesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.syncId == item.syncId),
                        typedResults: items),
                  if (transactionsRefs)
                    await drift.$_getPrefetchedData<SyncLogEntry, $SyncLogTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable:
                            $$SyncLogTableReferences._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SyncLogTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.syncId == item.syncId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SyncLogTableProcessedTableManager = drift.ProcessedTableManager<
    _$AppDatabase,
    $SyncLogTable,
    SyncLogEntry,
    $$SyncLogTableFilterComposer,
    $$SyncLogTableOrderingComposer,
    $$SyncLogTableAnnotationComposer,
    $$SyncLogTableCreateCompanionBuilder,
    $$SyncLogTableUpdateCompanionBuilder,
    (SyncLogEntry, $$SyncLogTableReferences),
    SyncLogEntry,
    drift.PrefetchHooks Function({bool templatesRefs, bool transactionsRefs})>;
typedef $$TemplatesTableCreateCompanionBuilder = TemplatesCompanion Function({
  drift.Value<int> templateId,
  drift.Value<int?> syncId,
  drift.Value<String?> spreadSheetId,
  required String templateName,
  required int creatorParticipantId,
  required DateTime dateCreated,
  drift.Value<int?> timesUsed,
});
typedef $$TemplatesTableUpdateCompanionBuilder = TemplatesCompanion Function({
  drift.Value<int> templateId,
  drift.Value<int?> syncId,
  drift.Value<String?> spreadSheetId,
  drift.Value<String> templateName,
  drift.Value<int> creatorParticipantId,
  drift.Value<DateTime> dateCreated,
  drift.Value<int?> timesUsed,
});

final class $$TemplatesTableReferences
    extends drift.BaseReferences<_$AppDatabase, $TemplatesTable, Template> {
  $$TemplatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncLogTable _syncIdTable(_$AppDatabase db) => db.syncLog.createAlias(
      drift.$_aliasNameGenerator(db.templates.syncId, db.syncLog.syncId));

  $$SyncLogTableProcessedTableManager? get syncId {
    final $_column = $_itemColumn<int>('sync_id');
    if ($_column == null) return null;
    final manager = $$SyncLogTableTableManager($_db, $_db.syncLog)
        .filter((f) => f.syncId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ParticipantsTable _creatorParticipantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(drift.$_aliasNameGenerator(
          db.templates.creatorParticipantId, db.participants.participantId));

  $$ParticipantsTableProcessedTableManager get creatorParticipantId {
    final $_column = $_itemColumn<int>('creator_participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.participantId.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_creatorParticipantIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static drift.MultiTypedResultKey<$CategoriesTable, List<Category>>
      _categoriesRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.categories,
              aliasName: drift.$_aliasNameGenerator(
                  db.templates.templateId, db.categories.templateId));

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories).filter(
        (f) => f.templateId.templateId
            .sqlEquals($_itemColumn<int>('template_id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$AccountsTable, List<Account>>
      _accountsRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.accounts,
              aliasName: drift.$_aliasNameGenerator(
                  db.templates.templateId, db.accounts.templateId));

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager($_db, $_db.accounts).filter(
        (f) => f.templateId.templateId
            .sqlEquals($_itemColumn<int>('template_id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$TemplateParticipantsTable,
      List<TemplateParticipant>> _templateParticipantsRefsTable(
          _$AppDatabase db) =>
      drift.MultiTypedResultKey.fromTable(db.templateParticipants,
          aliasName: drift.$_aliasNameGenerator(
              db.templates.templateId, db.templateParticipants.templateId));

  $$TemplateParticipantsTableProcessedTableManager
      get templateParticipantsRefs {
    final manager =
        $$TemplateParticipantsTableTableManager($_db, $_db.templateParticipants)
            .filter((f) => f.templateId.templateId
                .sqlEquals($_itemColumn<int>('template_id')!));

    final cache =
        $_typedResult.readTableOrNull(_templateParticipantsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$ChartSnapshotsTable, List<ChartSnapshot>>
      _chartSnapshotsRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.chartSnapshots,
              aliasName: drift.$_aliasNameGenerator(db.templates.templateId,
                  db.chartSnapshots.associatedTemplate));

  $$ChartSnapshotsTableProcessedTableManager get chartSnapshotsRefs {
    final manager = $$ChartSnapshotsTableTableManager($_db, $_db.chartSnapshots)
        .filter((f) => f.associatedTemplate.templateId
            .sqlEquals($_itemColumn<int>('template_id')!));

    final cache = $_typedResult.readTableOrNull(_chartSnapshotsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TemplatesTableFilterComposer
    extends drift.Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get templateId => $composableBuilder(
      column: $table.templateId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get spreadSheetId => $composableBuilder(
      column: $table.spreadSheetId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get templateName => $composableBuilder(
      column: $table.templateName,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<int> get timesUsed => $composableBuilder(
      column: $table.timesUsed,
      builder: (column) => drift.ColumnFilters(column));

  $$SyncLogTableFilterComposer get syncId {
    final $$SyncLogTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.syncLog,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncLogTableFilterComposer(
              $db: $db,
              $table: $db.syncLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableFilterComposer get creatorParticipantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creatorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  drift.Expression<bool> categoriesRefs(
      drift.Expression<bool> Function($$CategoriesTableFilterComposer f) f) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> accountsRefs(
      drift.Expression<bool> Function($$AccountsTableFilterComposer f) f) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> templateParticipantsRefs(
      drift.Expression<bool> Function(
              $$TemplateParticipantsTableFilterComposer f)
          f) {
    final $$TemplateParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templateParticipants,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.templateParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> chartSnapshotsRefs(
      drift.Expression<bool> Function($$ChartSnapshotsTableFilterComposer f)
          f) {
    final $$ChartSnapshotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.chartSnapshots,
        getReferencedColumn: (t) => t.associatedTemplate,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChartSnapshotsTableFilterComposer(
              $db: $db,
              $table: $db.chartSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TemplatesTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get templateId => $composableBuilder(
      column: $table.templateId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get spreadSheetId => $composableBuilder(
      column: $table.spreadSheetId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get templateName => $composableBuilder(
      column: $table.templateName,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<int> get timesUsed => $composableBuilder(
      column: $table.timesUsed,
      builder: (column) => drift.ColumnOrderings(column));

  $$SyncLogTableOrderingComposer get syncId {
    final $$SyncLogTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.syncLog,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncLogTableOrderingComposer(
              $db: $db,
              $table: $db.syncLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableOrderingComposer get creatorParticipantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creatorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TemplatesTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => column);

  drift.GeneratedColumn<String> get spreadSheetId => $composableBuilder(
      column: $table.spreadSheetId, builder: (column) => column);

  drift.GeneratedColumn<String> get templateName => $composableBuilder(
      column: $table.templateName, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated, builder: (column) => column);

  drift.GeneratedColumn<int> get timesUsed =>
      $composableBuilder(column: $table.timesUsed, builder: (column) => column);

  $$SyncLogTableAnnotationComposer get syncId {
    final $$SyncLogTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.syncLog,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncLogTableAnnotationComposer(
              $db: $db,
              $table: $db.syncLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableAnnotationComposer get creatorParticipantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creatorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  drift.Expression<T> categoriesRefs<T extends Object>(
      drift.Expression<T> Function($$CategoriesTableAnnotationComposer a) f) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<T> accountsRefs<T extends Object>(
      drift.Expression<T> Function($$AccountsTableAnnotationComposer a) f) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<T> templateParticipantsRefs<T extends Object>(
      drift.Expression<T> Function(
              $$TemplateParticipantsTableAnnotationComposer a)
          f) {
    final $$TemplateParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.templateId,
            referencedTable: $db.templateParticipants,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.templateParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  drift.Expression<T> chartSnapshotsRefs<T extends Object>(
      drift.Expression<T> Function($$ChartSnapshotsTableAnnotationComposer a)
          f) {
    final $$ChartSnapshotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.chartSnapshots,
        getReferencedColumn: (t) => t.associatedTemplate,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChartSnapshotsTableAnnotationComposer(
              $db: $db,
              $table: $db.chartSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TemplatesTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableAnnotationComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder,
    (Template, $$TemplatesTableReferences),
    Template,
    drift.PrefetchHooks Function(
        {bool syncId,
        bool creatorParticipantId,
        bool categoriesRefs,
        bool accountsRefs,
        bool templateParticipantsRefs,
        bool chartSnapshotsRefs})> {
  $$TemplatesTableTableManager(_$AppDatabase db, $TemplatesTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> templateId = const drift.Value.absent(),
            drift.Value<int?> syncId = const drift.Value.absent(),
            drift.Value<String?> spreadSheetId = const drift.Value.absent(),
            drift.Value<String> templateName = const drift.Value.absent(),
            drift.Value<int> creatorParticipantId = const drift.Value.absent(),
            drift.Value<DateTime> dateCreated = const drift.Value.absent(),
            drift.Value<int?> timesUsed = const drift.Value.absent(),
          }) =>
              TemplatesCompanion(
            templateId: templateId,
            syncId: syncId,
            spreadSheetId: spreadSheetId,
            templateName: templateName,
            creatorParticipantId: creatorParticipantId,
            dateCreated: dateCreated,
            timesUsed: timesUsed,
          ),
          createCompanionCallback: ({
            drift.Value<int> templateId = const drift.Value.absent(),
            drift.Value<int?> syncId = const drift.Value.absent(),
            drift.Value<String?> spreadSheetId = const drift.Value.absent(),
            required String templateName,
            required int creatorParticipantId,
            required DateTime dateCreated,
            drift.Value<int?> timesUsed = const drift.Value.absent(),
          }) =>
              TemplatesCompanion.insert(
            templateId: templateId,
            syncId: syncId,
            spreadSheetId: spreadSheetId,
            templateName: templateName,
            creatorParticipantId: creatorParticipantId,
            dateCreated: dateCreated,
            timesUsed: timesUsed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {syncId = false,
              creatorParticipantId = false,
              categoriesRefs = false,
              accountsRefs = false,
              templateParticipantsRefs = false,
              chartSnapshotsRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (categoriesRefs) db.categories,
                if (accountsRefs) db.accounts,
                if (templateParticipantsRefs) db.templateParticipants,
                if (chartSnapshotsRefs) db.chartSnapshots
              ],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (syncId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.syncId,
                    referencedTable:
                        $$TemplatesTableReferences._syncIdTable(db),
                    referencedColumn:
                        $$TemplatesTableReferences._syncIdTable(db).syncId,
                  ) as T;
                }
                if (creatorParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.creatorParticipantId,
                    referencedTable: $$TemplatesTableReferences
                        ._creatorParticipantIdTable(db),
                    referencedColumn: $$TemplatesTableReferences
                        ._creatorParticipantIdTable(db)
                        .participantId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (categoriesRefs)
                    await drift.$_getPrefetchedData<Template, $TemplatesTable,
                            Category>(
                        currentTable: table,
                        referencedTable:
                            $$TemplatesTableReferences._categoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplatesTableReferences(db, table, p0)
                                .categoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.templateId),
                        typedResults: items),
                  if (accountsRefs)
                    await drift.$_getPrefetchedData<Template, $TemplatesTable,
                            Account>(
                        currentTable: table,
                        referencedTable:
                            $$TemplatesTableReferences._accountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplatesTableReferences(db, table, p0)
                                .accountsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.templateId),
                        typedResults: items),
                  if (templateParticipantsRefs)
                    await drift.$_getPrefetchedData<Template, $TemplatesTable,
                            TemplateParticipant>(
                        currentTable: table,
                        referencedTable: $$TemplatesTableReferences
                            ._templateParticipantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplatesTableReferences(db, table, p0)
                                .templateParticipantsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.templateId),
                        typedResults: items),
                  if (chartSnapshotsRefs)
                    await drift.$_getPrefetchedData<Template, $TemplatesTable,
                            ChartSnapshot>(
                        currentTable: table,
                        referencedTable: $$TemplatesTableReferences
                            ._chartSnapshotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplatesTableReferences(db, table, p0)
                                .chartSnapshotsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.associatedTemplate == item.templateId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TemplatesTableProcessedTableManager = drift.ProcessedTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableAnnotationComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder,
    (Template, $$TemplatesTableReferences),
    Template,
    drift.PrefetchHooks Function(
        {bool syncId,
        bool creatorParticipantId,
        bool categoriesRefs,
        bool accountsRefs,
        bool templateParticipantsRefs,
        bool chartSnapshotsRefs})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  drift.Value<int> categoryId,
  required int templateId,
  required String categoryName,
  required String colorHex,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  drift.Value<int> categoryId,
  drift.Value<int> templateId,
  drift.Value<String> categoryName,
  drift.Value<String> colorHex,
});

final class $$CategoriesTableReferences
    extends drift.BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.templates.createAlias(drift.$_aliasNameGenerator(
          db.categories.templateId, db.templates.templateId));

  $$TemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<int>('template_id')!;

    final manager = $$TemplatesTableTableManager($_db, $_db.templates)
        .filter((f) => f.templateId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static drift.MultiTypedResultKey<$AccountsTable, List<Account>>
      _accountsRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.accounts,
              aliasName: drift.$_aliasNameGenerator(
                  db.categories.categoryId, db.accounts.categoryId));

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager($_db, $_db.accounts).filter(
        (f) => f.categoryId.categoryId
            .sqlEquals($_itemColumn<int>('category_id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends drift.Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get categoryName => $composableBuilder(
      column: $table.categoryName,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex,
      builder: (column) => drift.ColumnFilters(column));

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  drift.Expression<bool> accountsRefs(
      drift.Expression<bool> Function($$AccountsTableFilterComposer f) f) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get categoryName => $composableBuilder(
      column: $table.categoryName,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex,
      builder: (column) => drift.ColumnOrderings(column));

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  drift.GeneratedColumn<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => column);

  drift.GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  $$TemplatesTableAnnotationComposer get templateId {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  drift.Expression<T> accountsRefs<T extends Object>(
      drift.Expression<T> Function($$AccountsTableAnnotationComposer a) f) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    drift.PrefetchHooks Function({bool templateId, bool accountsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> categoryId = const drift.Value.absent(),
            drift.Value<int> templateId = const drift.Value.absent(),
            drift.Value<String> categoryName = const drift.Value.absent(),
            drift.Value<String> colorHex = const drift.Value.absent(),
          }) =>
              CategoriesCompanion(
            categoryId: categoryId,
            templateId: templateId,
            categoryName: categoryName,
            colorHex: colorHex,
          ),
          createCompanionCallback: ({
            drift.Value<int> categoryId = const drift.Value.absent(),
            required int templateId,
            required String categoryName,
            required String colorHex,
          }) =>
              CategoriesCompanion.insert(
            categoryId: categoryId,
            templateId: templateId,
            categoryName: categoryName,
            colorHex: colorHex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({templateId = false, accountsRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (accountsRefs) db.accounts],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable:
                        $$CategoriesTableReferences._templateIdTable(db),
                    referencedColumn: $$CategoriesTableReferences
                        ._templateIdTable(db)
                        .templateId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountsRefs)
                    await drift.$_getPrefetchedData<Category, $CategoriesTable,
                            Account>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._accountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .accountsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.categoryId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = drift.ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    drift.PrefetchHooks Function({bool templateId, bool accountsRefs})>;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  drift.Value<int> accountId,
  required int categoryId,
  required int templateId,
  required String accountName,
  required String colorHex,
  required double budgetAmount,
  drift.Value<double?> expenditureTotal,
  required int responsibleParticipantId,
  required DateTime dateCreated,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  drift.Value<int> accountId,
  drift.Value<int> categoryId,
  drift.Value<int> templateId,
  drift.Value<String> accountName,
  drift.Value<String> colorHex,
  drift.Value<double> budgetAmount,
  drift.Value<double?> expenditureTotal,
  drift.Value<int> responsibleParticipantId,
  drift.Value<DateTime> dateCreated,
});

final class $$AccountsTableReferences
    extends drift.BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(drift.$_aliasNameGenerator(
          db.accounts.categoryId, db.categories.categoryId));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.categoryId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.templates.createAlias(drift.$_aliasNameGenerator(
          db.accounts.templateId, db.templates.templateId));

  $$TemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<int>('template_id')!;

    final manager = $$TemplatesTableTableManager($_db, $_db.templates)
        .filter((f) => f.templateId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ParticipantsTable _responsibleParticipantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(drift.$_aliasNameGenerator(
          db.accounts.responsibleParticipantId, db.participants.participantId));

  $$ParticipantsTableProcessedTableManager get responsibleParticipantId {
    final $_column = $_itemColumn<int>('responsible_participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.participantId.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_responsibleParticipantIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static drift.MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.transactions,
              aliasName: drift.$_aliasNameGenerator(
                  db.accounts.accountId, db.transactions.accountId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) =>
            f.accountId.accountId.sqlEquals($_itemColumn<int>('account_id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get accountName => $composableBuilder(
      column: $table.accountName,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<double> get budgetAmount => $composableBuilder(
      column: $table.budgetAmount,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<double> get expenditureTotal => $composableBuilder(
      column: $table.expenditureTotal,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated,
      builder: (column) => drift.ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableFilterComposer get responsibleParticipantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.responsibleParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  drift.Expression<bool> transactionsRefs(
      drift.Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get accountName => $composableBuilder(
      column: $table.accountName,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<double> get budgetAmount => $composableBuilder(
      column: $table.budgetAmount,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<double> get expenditureTotal => $composableBuilder(
      column: $table.expenditureTotal,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated,
      builder: (column) => drift.ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableOrderingComposer get responsibleParticipantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.responsibleParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  drift.GeneratedColumn<String> get accountName => $composableBuilder(
      column: $table.accountName, builder: (column) => column);

  drift.GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  drift.GeneratedColumn<double> get budgetAmount => $composableBuilder(
      column: $table.budgetAmount, builder: (column) => column);

  drift.GeneratedColumn<double> get expenditureTotal => $composableBuilder(
      column: $table.expenditureTotal, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
      column: $table.dateCreated, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplatesTableAnnotationComposer get templateId {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableAnnotationComposer get responsibleParticipantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.responsibleParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  drift.Expression<T> transactionsRefs<T extends Object>(
      drift.Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    drift.PrefetchHooks Function(
        {bool categoryId,
        bool templateId,
        bool responsibleParticipantId,
        bool transactionsRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> accountId = const drift.Value.absent(),
            drift.Value<int> categoryId = const drift.Value.absent(),
            drift.Value<int> templateId = const drift.Value.absent(),
            drift.Value<String> accountName = const drift.Value.absent(),
            drift.Value<String> colorHex = const drift.Value.absent(),
            drift.Value<double> budgetAmount = const drift.Value.absent(),
            drift.Value<double?> expenditureTotal = const drift.Value.absent(),
            drift.Value<int> responsibleParticipantId =
                const drift.Value.absent(),
            drift.Value<DateTime> dateCreated = const drift.Value.absent(),
          }) =>
              AccountsCompanion(
            accountId: accountId,
            categoryId: categoryId,
            templateId: templateId,
            accountName: accountName,
            colorHex: colorHex,
            budgetAmount: budgetAmount,
            expenditureTotal: expenditureTotal,
            responsibleParticipantId: responsibleParticipantId,
            dateCreated: dateCreated,
          ),
          createCompanionCallback: ({
            drift.Value<int> accountId = const drift.Value.absent(),
            required int categoryId,
            required int templateId,
            required String accountName,
            required String colorHex,
            required double budgetAmount,
            drift.Value<double?> expenditureTotal = const drift.Value.absent(),
            required int responsibleParticipantId,
            required DateTime dateCreated,
          }) =>
              AccountsCompanion.insert(
            accountId: accountId,
            categoryId: categoryId,
            templateId: templateId,
            accountName: accountName,
            colorHex: colorHex,
            budgetAmount: budgetAmount,
            expenditureTotal: expenditureTotal,
            responsibleParticipantId: responsibleParticipantId,
            dateCreated: dateCreated,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              templateId = false,
              responsibleParticipantId = false,
              transactionsRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$AccountsTableReferences._categoryIdTable(db),
                    referencedColumn: $$AccountsTableReferences
                        ._categoryIdTable(db)
                        .categoryId,
                  ) as T;
                }
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable:
                        $$AccountsTableReferences._templateIdTable(db),
                    referencedColumn: $$AccountsTableReferences
                        ._templateIdTable(db)
                        .templateId,
                  ) as T;
                }
                if (responsibleParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.responsibleParticipantId,
                    referencedTable: $$AccountsTableReferences
                        ._responsibleParticipantIdTable(db),
                    referencedColumn: $$AccountsTableReferences
                        ._responsibleParticipantIdTable(db)
                        .participantId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await drift.$_getPrefetchedData<Account, $AccountsTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.accountId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = drift.ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    drift.PrefetchHooks Function(
        {bool categoryId,
        bool templateId,
        bool responsibleParticipantId,
        bool transactionsRefs})>;
typedef $$VendorsTableCreateCompanionBuilder = VendorsCompanion Function({
  drift.Value<int> vendorId,
  required String vendorName,
});
typedef $$VendorsTableUpdateCompanionBuilder = VendorsCompanion Function({
  drift.Value<int> vendorId,
  drift.Value<String> vendorName,
});

final class $$VendorsTableReferences
    extends drift.BaseReferences<_$AppDatabase, $VendorsTable, Vendor> {
  $$VendorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static drift.MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.transactions,
              aliasName: drift.$_aliasNameGenerator(
                  db.vendors.vendorId, db.transactions.vendorId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) =>
            f.vendorId.vendorId.sqlEquals($_itemColumn<int>('vendor_id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift
      .MultiTypedResultKey<$VendorPreferencesTable, List<VendorPreference>>
      _vendorPreferencesRefsTable(_$AppDatabase db) =>
          drift.MultiTypedResultKey.fromTable(db.vendorPreferences,
              aliasName: drift.$_aliasNameGenerator(
                  db.vendors.vendorId, db.vendorPreferences.vendorId));

  $$VendorPreferencesTableProcessedTableManager get vendorPreferencesRefs {
    final manager =
        $$VendorPreferencesTableTableManager($_db, $_db.vendorPreferences)
            .filter((f) =>
                f.vendorId.vendorId.sqlEquals($_itemColumn<int>('vendor_id')!));

    final cache =
        $_typedResult.readTableOrNull(_vendorPreferencesRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VendorsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get vendorId => $composableBuilder(
      column: $table.vendorId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get vendorName => $composableBuilder(
      column: $table.vendorName,
      builder: (column) => drift.ColumnFilters(column));

  drift.Expression<bool> transactionsRefs(
      drift.Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<bool> vendorPreferencesRefs(
      drift.Expression<bool> Function($$VendorPreferencesTableFilterComposer f)
          f) {
    final $$VendorPreferencesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendorPreferences,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorPreferencesTableFilterComposer(
              $db: $db,
              $table: $db.vendorPreferences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VendorsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get vendorId => $composableBuilder(
      column: $table.vendorId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get vendorName => $composableBuilder(
      column: $table.vendorName,
      builder: (column) => drift.ColumnOrderings(column));
}

class $$VendorsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get vendorId =>
      $composableBuilder(column: $table.vendorId, builder: (column) => column);

  drift.GeneratedColumn<String> get vendorName => $composableBuilder(
      column: $table.vendorName, builder: (column) => column);

  drift.Expression<T> transactionsRefs<T extends Object>(
      drift.Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  drift.Expression<T> vendorPreferencesRefs<T extends Object>(
      drift.Expression<T> Function($$VendorPreferencesTableAnnotationComposer a)
          f) {
    final $$VendorPreferencesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.vendorId,
            referencedTable: $db.vendorPreferences,
            getReferencedColumn: (t) => t.vendorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$VendorPreferencesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.vendorPreferences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$VendorsTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $VendorsTable,
    Vendor,
    $$VendorsTableFilterComposer,
    $$VendorsTableOrderingComposer,
    $$VendorsTableAnnotationComposer,
    $$VendorsTableCreateCompanionBuilder,
    $$VendorsTableUpdateCompanionBuilder,
    (Vendor, $$VendorsTableReferences),
    Vendor,
    drift.PrefetchHooks Function(
        {bool transactionsRefs, bool vendorPreferencesRefs})> {
  $$VendorsTableTableManager(_$AppDatabase db, $VendorsTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> vendorId = const drift.Value.absent(),
            drift.Value<String> vendorName = const drift.Value.absent(),
          }) =>
              VendorsCompanion(
            vendorId: vendorId,
            vendorName: vendorName,
          ),
          createCompanionCallback: ({
            drift.Value<int> vendorId = const drift.Value.absent(),
            required String vendorName,
          }) =>
              VendorsCompanion.insert(
            vendorId: vendorId,
            vendorName: vendorName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VendorsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {transactionsRefs = false, vendorPreferencesRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (vendorPreferencesRefs) db.vendorPreferences
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await drift.$_getPrefetchedData<Vendor, $VendorsTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable:
                            $$VendorsTableReferences._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VendorsTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vendorId == item.vendorId),
                        typedResults: items),
                  if (vendorPreferencesRefs)
                    await drift.$_getPrefetchedData<Vendor, $VendorsTable,
                            VendorPreference>(
                        currentTable: table,
                        referencedTable: $$VendorsTableReferences
                            ._vendorPreferencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VendorsTableReferences(db, table, p0)
                                .vendorPreferencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vendorId == item.vendorId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VendorsTableProcessedTableManager = drift.ProcessedTableManager<
    _$AppDatabase,
    $VendorsTable,
    Vendor,
    $$VendorsTableFilterComposer,
    $$VendorsTableOrderingComposer,
    $$VendorsTableAnnotationComposer,
    $$VendorsTableCreateCompanionBuilder,
    $$VendorsTableUpdateCompanionBuilder,
    (Vendor, $$VendorsTableReferences),
    Vendor,
    drift.PrefetchHooks Function(
        {bool transactionsRefs, bool vendorPreferencesRefs})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  drift.Value<int> transactionId,
  required int syncId,
  required int accountId,
  drift.Value<bool> isIgnored,
  required DateTime date,
  required int vendorId,
  required double amount,
  required int participantId,
  required int editorParticipantId,
  drift.Value<String?> reason,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  drift.Value<int> transactionId,
  drift.Value<int> syncId,
  drift.Value<int> accountId,
  drift.Value<bool> isIgnored,
  drift.Value<DateTime> date,
  drift.Value<int> vendorId,
  drift.Value<double> amount,
  drift.Value<int> participantId,
  drift.Value<int> editorParticipantId,
  drift.Value<String?> reason,
});

final class $$TransactionsTableReferences extends drift
    .BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncLogTable _syncIdTable(_$AppDatabase db) => db.syncLog.createAlias(
      drift.$_aliasNameGenerator(db.transactions.syncId, db.syncLog.syncId));

  $$SyncLogTableProcessedTableManager get syncId {
    final $_column = $_itemColumn<int>('sync_id')!;

    final manager = $$SyncLogTableTableManager($_db, $_db.syncLog)
        .filter((f) => f.syncId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(drift.$_aliasNameGenerator(
          db.transactions.accountId, db.accounts.accountId));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.accountId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $VendorsTable _vendorIdTable(_$AppDatabase db) =>
      db.vendors.createAlias(drift.$_aliasNameGenerator(
          db.transactions.vendorId, db.vendors.vendorId));

  $$VendorsTableProcessedTableManager get vendorId {
    final $_column = $_itemColumn<int>('vendor_id')!;

    final manager = $$VendorsTableTableManager($_db, $_db.vendors)
        .filter((f) => f.vendorId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(drift.$_aliasNameGenerator(
          db.transactions.participantId, db.participants.participantId));

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.participantId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ParticipantsTable _editorParticipantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(drift.$_aliasNameGenerator(
          db.transactions.editorParticipantId, db.participants.participantId));

  $$ParticipantsTableProcessedTableManager get editorParticipantId {
    final $_column = $_itemColumn<int>('editor_participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.participantId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_editorParticipantIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static drift.MultiTypedResultKey<$TransactionEditHistoriesTable,
      List<TransactionEditHistory>> _transactionEditHistoriesRefsTable(
          _$AppDatabase db) =>
      drift.MultiTypedResultKey.fromTable(db.transactionEditHistories,
          aliasName: drift.$_aliasNameGenerator(db.transactions.transactionId,
              db.transactionEditHistories.transactionId));

  $$TransactionEditHistoriesTableProcessedTableManager
      get transactionEditHistoriesRefs {
    final manager = $$TransactionEditHistoriesTableTableManager(
            $_db, $_db.transactionEditHistories)
        .filter((f) => f.transactionId.transactionId
            .sqlEquals($_itemColumn<int>('transaction_id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionEditHistoriesRefsTable($_db));
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<bool> get isIgnored => $composableBuilder(
      column: $table.isIgnored,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => drift.ColumnFilters(column));

  $$SyncLogTableFilterComposer get syncId {
    final $$SyncLogTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.syncLog,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncLogTableFilterComposer(
              $db: $db,
              $table: $db.syncLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableFilterComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableFilterComposer get editorParticipantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.editorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  drift.Expression<bool> transactionEditHistoriesRefs(
      drift.Expression<bool> Function(
              $$TransactionEditHistoriesTableFilterComposer f)
          f) {
    final $$TransactionEditHistoriesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.transactionEditHistories,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionEditHistoriesTableFilterComposer(
                  $db: $db,
                  $table: $db.transactionEditHistories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<bool> get isIgnored => $composableBuilder(
      column: $table.isIgnored,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason,
      builder: (column) => drift.ColumnOrderings(column));

  $$SyncLogTableOrderingComposer get syncId {
    final $$SyncLogTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.syncLog,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncLogTableOrderingComposer(
              $db: $db,
              $table: $db.syncLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableOrderingComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableOrderingComposer get editorParticipantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.editorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  drift.GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  drift.GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  drift.GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  $$SyncLogTableAnnotationComposer get syncId {
    final $$SyncLogTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.syncId,
        referencedTable: $db.syncLog,
        getReferencedColumn: (t) => t.syncId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncLogTableAnnotationComposer(
              $db: $db,
              $table: $db.syncLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableAnnotationComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableAnnotationComposer get editorParticipantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.editorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  drift.Expression<T> transactionEditHistoriesRefs<T extends Object>(
      drift.Expression<T> Function(
              $$TransactionEditHistoriesTableAnnotationComposer a)
          f) {
    final $$TransactionEditHistoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.transactionEditHistories,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionEditHistoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionEditHistories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    drift.PrefetchHooks Function(
        {bool syncId,
        bool accountId,
        bool vendorId,
        bool participantId,
        bool editorParticipantId,
        bool transactionEditHistoriesRefs})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> transactionId = const drift.Value.absent(),
            drift.Value<int> syncId = const drift.Value.absent(),
            drift.Value<int> accountId = const drift.Value.absent(),
            drift.Value<bool> isIgnored = const drift.Value.absent(),
            drift.Value<DateTime> date = const drift.Value.absent(),
            drift.Value<int> vendorId = const drift.Value.absent(),
            drift.Value<double> amount = const drift.Value.absent(),
            drift.Value<int> participantId = const drift.Value.absent(),
            drift.Value<int> editorParticipantId = const drift.Value.absent(),
            drift.Value<String?> reason = const drift.Value.absent(),
          }) =>
              TransactionsCompanion(
            transactionId: transactionId,
            syncId: syncId,
            accountId: accountId,
            isIgnored: isIgnored,
            date: date,
            vendorId: vendorId,
            amount: amount,
            participantId: participantId,
            editorParticipantId: editorParticipantId,
            reason: reason,
          ),
          createCompanionCallback: ({
            drift.Value<int> transactionId = const drift.Value.absent(),
            required int syncId,
            required int accountId,
            drift.Value<bool> isIgnored = const drift.Value.absent(),
            required DateTime date,
            required int vendorId,
            required double amount,
            required int participantId,
            required int editorParticipantId,
            drift.Value<String?> reason = const drift.Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            transactionId: transactionId,
            syncId: syncId,
            accountId: accountId,
            isIgnored: isIgnored,
            date: date,
            vendorId: vendorId,
            amount: amount,
            participantId: participantId,
            editorParticipantId: editorParticipantId,
            reason: reason,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {syncId = false,
              accountId = false,
              vendorId = false,
              participantId = false,
              editorParticipantId = false,
              transactionEditHistoriesRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionEditHistoriesRefs) db.transactionEditHistories
              ],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (syncId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.syncId,
                    referencedTable:
                        $$TransactionsTableReferences._syncIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._syncIdTable(db).syncId,
                  ) as T;
                }
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$TransactionsTableReferences._accountIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._accountIdTable(db)
                        .accountId,
                  ) as T;
                }
                if (vendorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vendorId,
                    referencedTable:
                        $$TransactionsTableReferences._vendorIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._vendorIdTable(db)
                        .vendorId,
                  ) as T;
                }
                if (participantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantId,
                    referencedTable:
                        $$TransactionsTableReferences._participantIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._participantIdTable(db)
                        .participantId,
                  ) as T;
                }
                if (editorParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.editorParticipantId,
                    referencedTable: $$TransactionsTableReferences
                        ._editorParticipantIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._editorParticipantIdTable(db)
                        .participantId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionEditHistoriesRefs)
                    await drift.$_getPrefetchedData<Transaction,
                            $TransactionsTable, TransactionEditHistory>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._transactionEditHistoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .transactionEditHistoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.transactionId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = drift.ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    drift.PrefetchHooks Function(
        {bool syncId,
        bool accountId,
        bool vendorId,
        bool participantId,
        bool editorParticipantId,
        bool transactionEditHistoriesRefs})>;
typedef $$TransactionEditHistoriesTableCreateCompanionBuilder
    = TransactionEditHistoriesCompanion Function({
  drift.Value<int> transactionEditId,
  required int editorParticipantId,
  required int transactionId,
  required String editedField,
  required String originalValue,
  required String newValue,
  required DateTime timeStamp,
});
typedef $$TransactionEditHistoriesTableUpdateCompanionBuilder
    = TransactionEditHistoriesCompanion Function({
  drift.Value<int> transactionEditId,
  drift.Value<int> editorParticipantId,
  drift.Value<int> transactionId,
  drift.Value<String> editedField,
  drift.Value<String> originalValue,
  drift.Value<String> newValue,
  drift.Value<DateTime> timeStamp,
});

final class $$TransactionEditHistoriesTableReferences
    extends drift.BaseReferences<_$AppDatabase, $TransactionEditHistoriesTable,
        TransactionEditHistory> {
  $$TransactionEditHistoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ParticipantsTable _editorParticipantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(drift.$_aliasNameGenerator(
          db.transactionEditHistories.editorParticipantId,
          db.participants.participantId));

  $$ParticipantsTableProcessedTableManager get editorParticipantId {
    final $_column = $_itemColumn<int>('editor_participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.participantId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_editorParticipantIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(drift.$_aliasNameGenerator(
          db.transactionEditHistories.transactionId,
          db.transactions.transactionId));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.transactionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionEditHistoriesTableFilterComposer
    extends drift.Composer<_$AppDatabase, $TransactionEditHistoriesTable> {
  $$TransactionEditHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get transactionEditId => $composableBuilder(
      column: $table.transactionEditId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get editedField => $composableBuilder(
      column: $table.editedField,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get originalValue => $composableBuilder(
      column: $table.originalValue,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get newValue => $composableBuilder(
      column: $table.newValue,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<DateTime> get timeStamp => $composableBuilder(
      column: $table.timeStamp,
      builder: (column) => drift.ColumnFilters(column));

  $$ParticipantsTableFilterComposer get editorParticipantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.editorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionEditHistoriesTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $TransactionEditHistoriesTable> {
  $$TransactionEditHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get transactionEditId => $composableBuilder(
      column: $table.transactionEditId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get editedField => $composableBuilder(
      column: $table.editedField,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get originalValue => $composableBuilder(
      column: $table.originalValue,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get newValue => $composableBuilder(
      column: $table.newValue,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<DateTime> get timeStamp => $composableBuilder(
      column: $table.timeStamp,
      builder: (column) => drift.ColumnOrderings(column));

  $$ParticipantsTableOrderingComposer get editorParticipantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.editorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionEditHistoriesTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $TransactionEditHistoriesTable> {
  $$TransactionEditHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get transactionEditId => $composableBuilder(
      column: $table.transactionEditId, builder: (column) => column);

  drift.GeneratedColumn<String> get editedField => $composableBuilder(
      column: $table.editedField, builder: (column) => column);

  drift.GeneratedColumn<String> get originalValue => $composableBuilder(
      column: $table.originalValue, builder: (column) => column);

  drift.GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get timeStamp =>
      $composableBuilder(column: $table.timeStamp, builder: (column) => column);

  $$ParticipantsTableAnnotationComposer get editorParticipantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.editorParticipantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionEditHistoriesTableTableManager
    extends drift.RootTableManager<
        _$AppDatabase,
        $TransactionEditHistoriesTable,
        TransactionEditHistory,
        $$TransactionEditHistoriesTableFilterComposer,
        $$TransactionEditHistoriesTableOrderingComposer,
        $$TransactionEditHistoriesTableAnnotationComposer,
        $$TransactionEditHistoriesTableCreateCompanionBuilder,
        $$TransactionEditHistoriesTableUpdateCompanionBuilder,
        (TransactionEditHistory, $$TransactionEditHistoriesTableReferences),
        TransactionEditHistory,
        drift.PrefetchHooks Function(
            {bool editorParticipantId, bool transactionId})> {
  $$TransactionEditHistoriesTableTableManager(
      _$AppDatabase db, $TransactionEditHistoriesTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionEditHistoriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionEditHistoriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionEditHistoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> transactionEditId = const drift.Value.absent(),
            drift.Value<int> editorParticipantId = const drift.Value.absent(),
            drift.Value<int> transactionId = const drift.Value.absent(),
            drift.Value<String> editedField = const drift.Value.absent(),
            drift.Value<String> originalValue = const drift.Value.absent(),
            drift.Value<String> newValue = const drift.Value.absent(),
            drift.Value<DateTime> timeStamp = const drift.Value.absent(),
          }) =>
              TransactionEditHistoriesCompanion(
            transactionEditId: transactionEditId,
            editorParticipantId: editorParticipantId,
            transactionId: transactionId,
            editedField: editedField,
            originalValue: originalValue,
            newValue: newValue,
            timeStamp: timeStamp,
          ),
          createCompanionCallback: ({
            drift.Value<int> transactionEditId = const drift.Value.absent(),
            required int editorParticipantId,
            required int transactionId,
            required String editedField,
            required String originalValue,
            required String newValue,
            required DateTime timeStamp,
          }) =>
              TransactionEditHistoriesCompanion.insert(
            transactionEditId: transactionEditId,
            editorParticipantId: editorParticipantId,
            transactionId: transactionId,
            editedField: editedField,
            originalValue: originalValue,
            newValue: newValue,
            timeStamp: timeStamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionEditHistoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {editorParticipantId = false, transactionId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (editorParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.editorParticipantId,
                    referencedTable: $$TransactionEditHistoriesTableReferences
                        ._editorParticipantIdTable(db),
                    referencedColumn: $$TransactionEditHistoriesTableReferences
                        ._editorParticipantIdTable(db)
                        .participantId,
                  ) as T;
                }
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$TransactionEditHistoriesTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$TransactionEditHistoriesTableReferences
                        ._transactionIdTable(db)
                        .transactionId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionEditHistoriesTableProcessedTableManager
    = drift.ProcessedTableManager<
        _$AppDatabase,
        $TransactionEditHistoriesTable,
        TransactionEditHistory,
        $$TransactionEditHistoriesTableFilterComposer,
        $$TransactionEditHistoriesTableOrderingComposer,
        $$TransactionEditHistoriesTableAnnotationComposer,
        $$TransactionEditHistoriesTableCreateCompanionBuilder,
        $$TransactionEditHistoriesTableUpdateCompanionBuilder,
        (TransactionEditHistory, $$TransactionEditHistoriesTableReferences),
        TransactionEditHistory,
        drift.PrefetchHooks Function(
            {bool editorParticipantId, bool transactionId})>;
typedef $$VendorPreferencesTableCreateCompanionBuilder
    = VendorPreferencesCompanion Function({
  drift.Value<int> vendorPreferenceId,
  required int vendorId,
  required int participantId,
});
typedef $$VendorPreferencesTableUpdateCompanionBuilder
    = VendorPreferencesCompanion Function({
  drift.Value<int> vendorPreferenceId,
  drift.Value<int> vendorId,
  drift.Value<int> participantId,
});

final class $$VendorPreferencesTableReferences extends drift
    .BaseReferences<_$AppDatabase, $VendorPreferencesTable, VendorPreference> {
  $$VendorPreferencesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $VendorsTable _vendorIdTable(_$AppDatabase db) =>
      db.vendors.createAlias(drift.$_aliasNameGenerator(
          db.vendorPreferences.vendorId, db.vendors.vendorId));

  $$VendorsTableProcessedTableManager get vendorId {
    final $_column = $_itemColumn<int>('vendor_id')!;

    final manager = $$VendorsTableTableManager($_db, $_db.vendors)
        .filter((f) => f.vendorId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(drift.$_aliasNameGenerator(
          db.vendorPreferences.participantId, db.participants.participantId));

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.participantId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VendorPreferencesTableFilterComposer
    extends drift.Composer<_$AppDatabase, $VendorPreferencesTable> {
  $$VendorPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get vendorPreferenceId => $composableBuilder(
      column: $table.vendorPreferenceId,
      builder: (column) => drift.ColumnFilters(column));

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableFilterComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VendorPreferencesTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $VendorPreferencesTable> {
  $$VendorPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get vendorPreferenceId => $composableBuilder(
      column: $table.vendorPreferenceId,
      builder: (column) => drift.ColumnOrderings(column));

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableOrderingComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VendorPreferencesTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $VendorPreferencesTable> {
  $$VendorPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get vendorPreferenceId => $composableBuilder(
      column: $table.vendorPreferenceId, builder: (column) => column);

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableAnnotationComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VendorPreferencesTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $VendorPreferencesTable,
    VendorPreference,
    $$VendorPreferencesTableFilterComposer,
    $$VendorPreferencesTableOrderingComposer,
    $$VendorPreferencesTableAnnotationComposer,
    $$VendorPreferencesTableCreateCompanionBuilder,
    $$VendorPreferencesTableUpdateCompanionBuilder,
    (VendorPreference, $$VendorPreferencesTableReferences),
    VendorPreference,
    drift.PrefetchHooks Function({bool vendorId, bool participantId})> {
  $$VendorPreferencesTableTableManager(
      _$AppDatabase db, $VendorPreferencesTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorPreferencesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> vendorPreferenceId = const drift.Value.absent(),
            drift.Value<int> vendorId = const drift.Value.absent(),
            drift.Value<int> participantId = const drift.Value.absent(),
          }) =>
              VendorPreferencesCompanion(
            vendorPreferenceId: vendorPreferenceId,
            vendorId: vendorId,
            participantId: participantId,
          ),
          createCompanionCallback: ({
            drift.Value<int> vendorPreferenceId = const drift.Value.absent(),
            required int vendorId,
            required int participantId,
          }) =>
              VendorPreferencesCompanion.insert(
            vendorPreferenceId: vendorPreferenceId,
            vendorId: vendorId,
            participantId: participantId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VendorPreferencesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vendorId = false, participantId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (vendorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vendorId,
                    referencedTable:
                        $$VendorPreferencesTableReferences._vendorIdTable(db),
                    referencedColumn: $$VendorPreferencesTableReferences
                        ._vendorIdTable(db)
                        .vendorId,
                  ) as T;
                }
                if (participantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantId,
                    referencedTable: $$VendorPreferencesTableReferences
                        ._participantIdTable(db),
                    referencedColumn: $$VendorPreferencesTableReferences
                        ._participantIdTable(db)
                        .participantId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VendorPreferencesTableProcessedTableManager
    = drift.ProcessedTableManager<
        _$AppDatabase,
        $VendorPreferencesTable,
        VendorPreference,
        $$VendorPreferencesTableFilterComposer,
        $$VendorPreferencesTableOrderingComposer,
        $$VendorPreferencesTableAnnotationComposer,
        $$VendorPreferencesTableCreateCompanionBuilder,
        $$VendorPreferencesTableUpdateCompanionBuilder,
        (VendorPreference, $$VendorPreferencesTableReferences),
        VendorPreference,
        drift.PrefetchHooks Function({bool vendorId, bool participantId})>;
typedef $$ParticipantIncomesTableCreateCompanionBuilder
    = ParticipantIncomesCompanion Function({
  drift.Value<int> incomeId,
  required int participantId,
  required double incomeAmount,
  drift.Value<String?> incomeName,
  required String incomeType,
  drift.Value<DateTime> dateReceived,
});
typedef $$ParticipantIncomesTableUpdateCompanionBuilder
    = ParticipantIncomesCompanion Function({
  drift.Value<int> incomeId,
  drift.Value<int> participantId,
  drift.Value<double> incomeAmount,
  drift.Value<String?> incomeName,
  drift.Value<String> incomeType,
  drift.Value<DateTime> dateReceived,
});

final class $$ParticipantIncomesTableReferences extends drift.BaseReferences<
    _$AppDatabase, $ParticipantIncomesTable, ParticipantIncome> {
  $$ParticipantIncomesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(drift.$_aliasNameGenerator(
          db.participantIncomes.participantId, db.participants.participantId));

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.participantId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ParticipantIncomesTableFilterComposer
    extends drift.Composer<_$AppDatabase, $ParticipantIncomesTable> {
  $$ParticipantIncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get incomeId => $composableBuilder(
      column: $table.incomeId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<double> get incomeAmount => $composableBuilder(
      column: $table.incomeAmount,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get incomeName => $composableBuilder(
      column: $table.incomeName,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get incomeType => $composableBuilder(
      column: $table.incomeType,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<DateTime> get dateReceived => $composableBuilder(
      column: $table.dateReceived,
      builder: (column) => drift.ColumnFilters(column));

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParticipantIncomesTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $ParticipantIncomesTable> {
  $$ParticipantIncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get incomeId => $composableBuilder(
      column: $table.incomeId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<double> get incomeAmount => $composableBuilder(
      column: $table.incomeAmount,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get incomeName => $composableBuilder(
      column: $table.incomeName,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get incomeType => $composableBuilder(
      column: $table.incomeType,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<DateTime> get dateReceived => $composableBuilder(
      column: $table.dateReceived,
      builder: (column) => drift.ColumnOrderings(column));

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParticipantIncomesTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $ParticipantIncomesTable> {
  $$ParticipantIncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get incomeId =>
      $composableBuilder(column: $table.incomeId, builder: (column) => column);

  drift.GeneratedColumn<double> get incomeAmount => $composableBuilder(
      column: $table.incomeAmount, builder: (column) => column);

  drift.GeneratedColumn<String> get incomeName => $composableBuilder(
      column: $table.incomeName, builder: (column) => column);

  drift.GeneratedColumn<String> get incomeType => $composableBuilder(
      column: $table.incomeType, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get dateReceived => $composableBuilder(
      column: $table.dateReceived, builder: (column) => column);

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParticipantIncomesTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $ParticipantIncomesTable,
    ParticipantIncome,
    $$ParticipantIncomesTableFilterComposer,
    $$ParticipantIncomesTableOrderingComposer,
    $$ParticipantIncomesTableAnnotationComposer,
    $$ParticipantIncomesTableCreateCompanionBuilder,
    $$ParticipantIncomesTableUpdateCompanionBuilder,
    (ParticipantIncome, $$ParticipantIncomesTableReferences),
    ParticipantIncome,
    drift.PrefetchHooks Function({bool participantId})> {
  $$ParticipantIncomesTableTableManager(
      _$AppDatabase db, $ParticipantIncomesTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantIncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantIncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantIncomesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> incomeId = const drift.Value.absent(),
            drift.Value<int> participantId = const drift.Value.absent(),
            drift.Value<double> incomeAmount = const drift.Value.absent(),
            drift.Value<String?> incomeName = const drift.Value.absent(),
            drift.Value<String> incomeType = const drift.Value.absent(),
            drift.Value<DateTime> dateReceived = const drift.Value.absent(),
          }) =>
              ParticipantIncomesCompanion(
            incomeId: incomeId,
            participantId: participantId,
            incomeAmount: incomeAmount,
            incomeName: incomeName,
            incomeType: incomeType,
            dateReceived: dateReceived,
          ),
          createCompanionCallback: ({
            drift.Value<int> incomeId = const drift.Value.absent(),
            required int participantId,
            required double incomeAmount,
            drift.Value<String?> incomeName = const drift.Value.absent(),
            required String incomeType,
            drift.Value<DateTime> dateReceived = const drift.Value.absent(),
          }) =>
              ParticipantIncomesCompanion.insert(
            incomeId: incomeId,
            participantId: participantId,
            incomeAmount: incomeAmount,
            incomeName: incomeName,
            incomeType: incomeType,
            dateReceived: dateReceived,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ParticipantIncomesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({participantId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (participantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantId,
                    referencedTable: $$ParticipantIncomesTableReferences
                        ._participantIdTable(db),
                    referencedColumn: $$ParticipantIncomesTableReferences
                        ._participantIdTable(db)
                        .participantId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ParticipantIncomesTableProcessedTableManager
    = drift.ProcessedTableManager<
        _$AppDatabase,
        $ParticipantIncomesTable,
        ParticipantIncome,
        $$ParticipantIncomesTableFilterComposer,
        $$ParticipantIncomesTableOrderingComposer,
        $$ParticipantIncomesTableAnnotationComposer,
        $$ParticipantIncomesTableCreateCompanionBuilder,
        $$ParticipantIncomesTableUpdateCompanionBuilder,
        (ParticipantIncome, $$ParticipantIncomesTableReferences),
        ParticipantIncome,
        drift.PrefetchHooks Function({bool participantId})>;
typedef $$TemplateParticipantsTableCreateCompanionBuilder
    = TemplateParticipantsCompanion Function({
  required int templateId,
  required int participantId,
  required String permissionRole,
  drift.Value<int> rowid,
});
typedef $$TemplateParticipantsTableUpdateCompanionBuilder
    = TemplateParticipantsCompanion Function({
  drift.Value<int> templateId,
  drift.Value<int> participantId,
  drift.Value<String> permissionRole,
  drift.Value<int> rowid,
});

final class $$TemplateParticipantsTableReferences extends drift.BaseReferences<
    _$AppDatabase, $TemplateParticipantsTable, TemplateParticipant> {
  $$TemplateParticipantsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.templates.createAlias(drift.$_aliasNameGenerator(
          db.templateParticipants.templateId, db.templates.templateId));

  $$TemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<int>('template_id')!;

    final manager = $$TemplatesTableTableManager($_db, $_db.templates)
        .filter((f) => f.templateId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) =>
      db.participants.createAlias(drift.$_aliasNameGenerator(
          db.templateParticipants.participantId,
          db.participants.participantId));

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.participantId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TemplateParticipantsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $TemplateParticipantsTable> {
  $$TemplateParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<String> get permissionRole => $composableBuilder(
      column: $table.permissionRole,
      builder: (column) => drift.ColumnFilters(column));

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TemplateParticipantsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $TemplateParticipantsTable> {
  $$TemplateParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<String> get permissionRole => $composableBuilder(
      column: $table.permissionRole,
      builder: (column) => drift.ColumnOrderings(column));

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TemplateParticipantsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $TemplateParticipantsTable> {
  $$TemplateParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<String> get permissionRole => $composableBuilder(
      column: $table.permissionRole, builder: (column) => column);

  $$TemplatesTableAnnotationComposer get templateId {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TemplateParticipantsTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $TemplateParticipantsTable,
    TemplateParticipant,
    $$TemplateParticipantsTableFilterComposer,
    $$TemplateParticipantsTableOrderingComposer,
    $$TemplateParticipantsTableAnnotationComposer,
    $$TemplateParticipantsTableCreateCompanionBuilder,
    $$TemplateParticipantsTableUpdateCompanionBuilder,
    (TemplateParticipant, $$TemplateParticipantsTableReferences),
    TemplateParticipant,
    drift.PrefetchHooks Function({bool templateId, bool participantId})> {
  $$TemplateParticipantsTableTableManager(
      _$AppDatabase db, $TemplateParticipantsTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateParticipantsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateParticipantsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> templateId = const drift.Value.absent(),
            drift.Value<int> participantId = const drift.Value.absent(),
            drift.Value<String> permissionRole = const drift.Value.absent(),
            drift.Value<int> rowid = const drift.Value.absent(),
          }) =>
              TemplateParticipantsCompanion(
            templateId: templateId,
            participantId: participantId,
            permissionRole: permissionRole,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int templateId,
            required int participantId,
            required String permissionRole,
            drift.Value<int> rowid = const drift.Value.absent(),
          }) =>
              TemplateParticipantsCompanion.insert(
            templateId: templateId,
            participantId: participantId,
            permissionRole: permissionRole,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TemplateParticipantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({templateId = false, participantId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable: $$TemplateParticipantsTableReferences
                        ._templateIdTable(db),
                    referencedColumn: $$TemplateParticipantsTableReferences
                        ._templateIdTable(db)
                        .templateId,
                  ) as T;
                }
                if (participantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantId,
                    referencedTable: $$TemplateParticipantsTableReferences
                        ._participantIdTable(db),
                    referencedColumn: $$TemplateParticipantsTableReferences
                        ._participantIdTable(db)
                        .participantId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TemplateParticipantsTableProcessedTableManager
    = drift.ProcessedTableManager<
        _$AppDatabase,
        $TemplateParticipantsTable,
        TemplateParticipant,
        $$TemplateParticipantsTableFilterComposer,
        $$TemplateParticipantsTableOrderingComposer,
        $$TemplateParticipantsTableAnnotationComposer,
        $$TemplateParticipantsTableCreateCompanionBuilder,
        $$TemplateParticipantsTableUpdateCompanionBuilder,
        (TemplateParticipant, $$TemplateParticipantsTableReferences),
        TemplateParticipant,
        drift.PrefetchHooks Function({bool templateId, bool participantId})>;
typedef $$ChartSnapshotsTableCreateCompanionBuilder = ChartSnapshotsCompanion
    Function({
  drift.Value<int> snapshotId,
  drift.Value<String?> name,
  required String configuration,
  required DateTime createdAt,
  required String permissionRole,
  required int associatedTemplate,
});
typedef $$ChartSnapshotsTableUpdateCompanionBuilder = ChartSnapshotsCompanion
    Function({
  drift.Value<int> snapshotId,
  drift.Value<String?> name,
  drift.Value<String> configuration,
  drift.Value<DateTime> createdAt,
  drift.Value<String> permissionRole,
  drift.Value<int> associatedTemplate,
});

final class $$ChartSnapshotsTableReferences extends drift
    .BaseReferences<_$AppDatabase, $ChartSnapshotsTable, ChartSnapshot> {
  $$ChartSnapshotsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TemplatesTable _associatedTemplateTable(_$AppDatabase db) =>
      db.templates.createAlias(drift.$_aliasNameGenerator(
          db.chartSnapshots.associatedTemplate, db.templates.templateId));

  $$TemplatesTableProcessedTableManager get associatedTemplate {
    final $_column = $_itemColumn<int>('associated_template')!;

    final manager = $$TemplatesTableTableManager($_db, $_db.templates)
        .filter((f) => f.templateId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_associatedTemplateTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ChartSnapshotsTableFilterComposer
    extends drift.Composer<_$AppDatabase, $ChartSnapshotsTable> {
  $$ChartSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get snapshotId => $composableBuilder(
      column: $table.snapshotId,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get configuration => $composableBuilder(
      column: $table.configuration,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => drift.ColumnFilters(column));

  drift.ColumnFilters<String> get permissionRole => $composableBuilder(
      column: $table.permissionRole,
      builder: (column) => drift.ColumnFilters(column));

  $$TemplatesTableFilterComposer get associatedTemplate {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.associatedTemplate,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChartSnapshotsTableOrderingComposer
    extends drift.Composer<_$AppDatabase, $ChartSnapshotsTable> {
  $$ChartSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get snapshotId => $composableBuilder(
      column: $table.snapshotId,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get configuration => $composableBuilder(
      column: $table.configuration,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => drift.ColumnOrderings(column));

  drift.ColumnOrderings<String> get permissionRole => $composableBuilder(
      column: $table.permissionRole,
      builder: (column) => drift.ColumnOrderings(column));

  $$TemplatesTableOrderingComposer get associatedTemplate {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.associatedTemplate,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChartSnapshotsTableAnnotationComposer
    extends drift.Composer<_$AppDatabase, $ChartSnapshotsTable> {
  $$ChartSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get snapshotId => $composableBuilder(
      column: $table.snapshotId, builder: (column) => column);

  drift.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  drift.GeneratedColumn<String> get configuration => $composableBuilder(
      column: $table.configuration, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  drift.GeneratedColumn<String> get permissionRole => $composableBuilder(
      column: $table.permissionRole, builder: (column) => column);

  $$TemplatesTableAnnotationComposer get associatedTemplate {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.associatedTemplate,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChartSnapshotsTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $ChartSnapshotsTable,
    ChartSnapshot,
    $$ChartSnapshotsTableFilterComposer,
    $$ChartSnapshotsTableOrderingComposer,
    $$ChartSnapshotsTableAnnotationComposer,
    $$ChartSnapshotsTableCreateCompanionBuilder,
    $$ChartSnapshotsTableUpdateCompanionBuilder,
    (ChartSnapshot, $$ChartSnapshotsTableReferences),
    ChartSnapshot,
    drift.PrefetchHooks Function({bool associatedTemplate})> {
  $$ChartSnapshotsTableTableManager(
      _$AppDatabase db, $ChartSnapshotsTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChartSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChartSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChartSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            drift.Value<int> snapshotId = const drift.Value.absent(),
            drift.Value<String?> name = const drift.Value.absent(),
            drift.Value<String> configuration = const drift.Value.absent(),
            drift.Value<DateTime> createdAt = const drift.Value.absent(),
            drift.Value<String> permissionRole = const drift.Value.absent(),
            drift.Value<int> associatedTemplate = const drift.Value.absent(),
          }) =>
              ChartSnapshotsCompanion(
            snapshotId: snapshotId,
            name: name,
            configuration: configuration,
            createdAt: createdAt,
            permissionRole: permissionRole,
            associatedTemplate: associatedTemplate,
          ),
          createCompanionCallback: ({
            drift.Value<int> snapshotId = const drift.Value.absent(),
            drift.Value<String?> name = const drift.Value.absent(),
            required String configuration,
            required DateTime createdAt,
            required String permissionRole,
            required int associatedTemplate,
          }) =>
              ChartSnapshotsCompanion.insert(
            snapshotId: snapshotId,
            name: name,
            configuration: configuration,
            createdAt: createdAt,
            permissionRole: permissionRole,
            associatedTemplate: associatedTemplate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ChartSnapshotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({associatedTemplate = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends drift.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (associatedTemplate) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.associatedTemplate,
                    referencedTable: $$ChartSnapshotsTableReferences
                        ._associatedTemplateTable(db),
                    referencedColumn: $$ChartSnapshotsTableReferences
                        ._associatedTemplateTable(db)
                        .templateId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChartSnapshotsTableProcessedTableManager
    = drift.ProcessedTableManager<
        _$AppDatabase,
        $ChartSnapshotsTable,
        ChartSnapshot,
        $$ChartSnapshotsTableFilterComposer,
        $$ChartSnapshotsTableOrderingComposer,
        $$ChartSnapshotsTableAnnotationComposer,
        $$ChartSnapshotsTableCreateCompanionBuilder,
        $$ChartSnapshotsTableUpdateCompanionBuilder,
        (ChartSnapshot, $$ChartSnapshotsTableReferences),
        ChartSnapshot,
        drift.PrefetchHooks Function({bool associatedTemplate})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
  $$SyncLogTableTableManager get syncLog =>
      $$SyncLogTableTableManager(_db, _db.syncLog);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db, _db.vendors);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionEditHistoriesTableTableManager get transactionEditHistories =>
      $$TransactionEditHistoriesTableTableManager(
          _db, _db.transactionEditHistories);
  $$VendorPreferencesTableTableManager get vendorPreferences =>
      $$VendorPreferencesTableTableManager(_db, _db.vendorPreferences);
  $$ParticipantIncomesTableTableManager get participantIncomes =>
      $$ParticipantIncomesTableTableManager(_db, _db.participantIncomes);
  $$TemplateParticipantsTableTableManager get templateParticipants =>
      $$TemplateParticipantsTableTableManager(_db, _db.templateParticipants);
  $$ChartSnapshotsTableTableManager get chartSnapshots =>
      $$ChartSnapshotsTableTableManager(_db, _db.chartSnapshots);
}
