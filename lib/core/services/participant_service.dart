import 'package:logging/logging.dart';
import 'package:drift/drift.dart' as drift;

import '../models/models.dart' as models;
import '../models/client_models.dart' as clientModels;
import '../data/databases.dart' as db;
import '../context.dart' as context;

class ParticipantService {
  final db.AppDatabase _database;
  final Logger _logger = Logger("ParticipantService");

  ParticipantService(this._database);

  /// Add a new participant and return its ID
  Future<int> addParticipant(
      clientModels.Participant participant, String pwdhash) async {
    final participantId = await _database.into(_database.participants).insert(
          db.ParticipantsCompanion.insert(
            firstName: participant.firstName,
            lastName: drift.Value(participant.lastName),
            nickName: drift.Value(participant.nickname),
            role: participant.role.value,
            email: participant.email,
            pwdhash: pwdhash,
          ),
        );

    return participantId;
  }

  /// Get a participant by ID
  Future<models.Participant?> getParticipant(int id) async {
    final result = await (_database.select(_database.participants)
          ..where((tbl) => tbl.participantId.equals(id)))
        .getSingleOrNull();

    if (result == null) {
      _logger.warning("Participant with ID $id not found");
      return null;
    }

    return models.Participant(
      participantId: result.participantId,
      firstName: result.firstName,
      lastName: result.lastName,
      nickname: result.nickName,
      role: models.Role.fromString(result.role),
      // Convert string → enum
      email: result.email,
    );
  }

  /// Get all participants
  Future<List<models.Participant>> getAllParticipants() async {
    final rows = await _database.select(_database.participants).get();

    final participants = rows
        .map((row) => models.Participant(
              participantId: row.participantId,
              firstName: row.firstName,
              lastName: row.lastName,
              nickname: row.nickName,
              role: models.Role.fromString(row.role),
              email: row.email,
            ))
        .toList();

    _logger.info("Fetched ${participants.length} participants");
    return participants;
  }

  /// Update a participant’s details
  Future<bool> updateParticipant(models.Participant participant) async {
    final updatedCount = await (_database.update(_database.participants)
          ..where((tbl) => tbl.participantId.equals(participant.participantId)))
        .write(
      db.ParticipantsCompanion(
        firstName: drift.Value(participant.firstName),
        lastName: drift.Value(participant.lastName),
        nickName: drift.Value(participant.nickname),
        role: drift.Value(participant.role.value),
        email: drift.Value(participant.email),
      ),
    );

    final success = updatedCount > 0;
    if (success) {
      _logger.info("Updated participant ${participant.participantId}");
    } else {
      _logger.warning(
          "No participant updated for ID ${participant.participantId}");
    }
    return success;
  }

  /// Delete a participant
  Future<bool> deleteParticipant(models.Participant participant) async {
    final deletedCount = await (_database.delete(_database.participants)
      ..where((tbl) => tbl.participantId.equals(participant.participantId)))
        .go();

    final success = deletedCount > 0;
    if (success) {
      _logger.info("Deleted participant ${participant.participantId}");
    } else {
      _logger.warning("No participant deleted for ID ${participant.participantId}");
    }
    return success;
  }
}
