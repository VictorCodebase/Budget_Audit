import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:logging/logging.dart';

import '../services/service_locator.dart';
import 'package:flutter/foundation.dart';


final Logger _logger = Logger("AppInitializer");

Future<void> initializeApp() async {
  await dotenv.load(fileName: ".env");
  await setupServiceLocator();

  final key = dotenv.env['SYNCFUSION_LICENSE'];
  if (key != null && key.isNotEmpty) {
    SyncfusionLicense.registerLicense(key);
  } else {
    _logger.warning("⚠️ Syncfusion license not found in .env");
  }

  await _setupLogging();
}


Future <void> _setupLogging() async {
  Logger.root.level = Level.ALL; // Capture all logs
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      // This prints to the Android Studio / VS Code console
      // in debug mode
      print(
          '[${record.level.name}] ${record.time}: ${record
              .loggerName} → ${record.message}');
      if (record.error != null) {
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        print(record.stackTrace);
      }
    }
  });
}