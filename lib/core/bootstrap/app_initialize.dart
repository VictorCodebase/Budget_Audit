import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:logging/logging.dart';

import '../services/service_locator.dart';

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
}
