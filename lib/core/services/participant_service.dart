import 'package:logging/logging.dart';

import '../models/models.dart' as models;
import '../data/databases.dart' as db;

class ParticipantService {
  final db.AppDatabase _database;
  final Logger _logger = Logger("ParticipantService");

  ParticipantService(this._database);


  Future<models.Participant?> getCurrentParticipant() async {

    _logger.warning("getCurrentParticipant returned a generic response for development only!");
    return models.Participant(
        participantId: 1,
        firstName: "Admin",
        lastName: "VictorCodebase",
        nickname: "_Vor0b0tnick",
        role: models.Role.participant,
        email: "mail@samp.com");
  }

  Future<List<models.Participant>> getAllParticipants() async {

    _logger.warning("getAllParticipants returned a generic response for development only!");
    return [
      models.Participant(
          participantId: 1,
          firstName: "Admin",
          lastName: "VictorCodebase",
          nickname: "_Vor0b0tnick",
          role: models.Role.manager,
          email: "mail@samp.com"),
      models.Participant(
          participantId: 2,
          firstName: "Lorem",
          lastName: "Ipsum",
          nickname: "GenericParticipant001",
          role: models.Role.participant,
          email: "mail01@samp.com"),
      models.Participant(
          participantId: 3,
          firstName: "Lorem",
          lastName: "Ipsum",
          nickname: "GenericEditor001",
          role: models.Role.editor,
          email: "mail@samp02.com")
    ];
  }

  Future<bool> updateParticipant(models.Participant participant) async {

    _logger.warning("updateParticipant returned a generic TRUE response for development only!");
    return true;
  }

  Future<bool> deleteParticipant(models.Participant participant) async {

    _logger.warning("deleteParticipant returned a generic TRUE for development only!");
    return true;
  }
}
