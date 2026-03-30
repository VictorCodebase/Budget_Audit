import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get docsBaseUrl => dotenv.env['DOCS_BASE_URL'] ?? '';

  static String get env => dotenv.env['ENV'] ?? 'PRODUCTION';

  static String get syncfusionKey => dotenv.env['SYNCFUSION_LICENSE'] ?? '';

  static bool get isProduction => env.toUpperCase() == 'PRODUCTION';

  static bool get enableExperiments =>
      dotenv.env['ENABLE_EXPERIMENTS'] == 'true';

  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';
}
