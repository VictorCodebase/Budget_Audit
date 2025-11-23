import 'package:logging/logging.dart';
import 'package:drift/drift.dart' as drift;

import '../models/models.dart' as models;
import '../models/client_models.dart' as clientModels;
import '../data/database.dart' as db;
import '../utils/password_utils.dart';

class ParticipantService {
  final db.AppDatabase _database;
  final Logger _logger = Logger("ParticipantService");

  ParticipantService(this._database);

  /// Add a new participant and return its ID
  Future<int> addParticipant(
      clientModels.Participant participant, String pwd) async {
    try {
      final mailLower = participant.email.toLowerCase();
      final pwdHash = PasswordUtils.hashPassword(pwd);
      final participantId = await _database.into(_database.participants).insert(
        db.ParticipantsCompanion.insert(
          firstName: participant.firstName,
          lastName: drift.Value(participant.lastName),
          nickName: drift.Value(participant.nickname),
          role: participant.role.value,
          email: mailLower,
          pwdhash: pwdHash,
        ),
      );

      _logger.info("Added participant ${participant.email} (ID: $participantId)");
      return participantId;
    } catch (e, stack) {
      _logger.severe("Failed to add participant ${participant.email}", e, stack);
      rethrow; // Let the caller handle it
    }
  }
  /// verify user account
  Future<bool> verifyParticipant(String email, String password) async {
    final String mailLower = email.toLowerCase();
    try{
      final participant = await (_database.select(_database.participants)
      ..where((tbl) => tbl.email.equals(mailLower)))
          .getSingleOrNull();

      if (participant == null) {
        _logger.warning("Participant with email $email not found");
        return false;
      }

      return PasswordUtils.verifyPassword(password, participant.pwdhash);
    } catch (e, stack) {
      _logger.severe("Error verifying participant with email $mailLower");
      rethrow;
    }
  }


  /// Get a participant by ID
  Future<models.Participant?> getParticipant(int id) async {
    try {
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
        email: result.email,
      );
    } catch (e, stack) {
      _logger.severe("Error fetching participant with ID $id", e, stack);
      rethrow;
    }
  }

  /// Get all participants
  Future<List<models.Participant>> getAllParticipants() async {
    try {
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
    } catch (e, stack) {
      _logger.severe("Failed to fetch all participants", e, stack);
      rethrow;
    }
  }

  /// Update a participant’s details
  Future<bool> updateParticipant(models.Participant participant, {String? newPassword}) async {
    try {
      final emailLower = participant.email.toLowerCase();
      final hashedPassword = newPassword != null
          ? PasswordUtils.hashPassword(newPassword)
          : null;

      final updatedCount = await (_database.update(_database.participants)
        ..where((tbl) => tbl.participantId.equals(participant.participantId)))
          .write(
        db.ParticipantsCompanion(
          firstName: drift.Value(participant.firstName),
          lastName: drift.Value(participant.lastName),
          nickName: drift.Value(participant.nickname),
          role: drift.Value(participant.role.value),
          email: drift.Value(emailLower),
          pwdhash: hashedPassword != null ? drift.Value(hashedPassword) : const drift.Value.absent(),
        ),
      );

      final success = updatedCount > 0;
      if (success) {
        _logger.info("Updated participant ${participant.participantId}");
      } else {
        _logger.warning("No participant updated for ID ${participant.participantId}");
      }
      return success;
    } catch (e, stack) {
      _logger.severe("Error updating participant ${participant.participantId}", e, stack);
      rethrow;
    }
  }


  /// Delete a participant
  Future<bool> deleteParticipant(models.Participant participant) async {
    try {
      _logger.info("Deleting the participant $participant");
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
    } catch (e, stack) {
      _logger.severe("Error deleting participant ${participant.participantId}", e, stack);
      rethrow;
    }
  }
}
