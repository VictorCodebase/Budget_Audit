// lib/core/services/service_locator.dart

import 'package:get_it/get_it.dart';
import '../data/database.dart';
import 'participant_service.dart';
import 'budget_service.dart';
import 'document_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final db = AppDatabase();

  sl.registerSingleton<AppDatabase>(db);
  sl.registerLazySingleton(() => ParticipantService(sl<AppDatabase>()));
  sl.registerLazySingleton(() => BudgetService(sl<AppDatabase>()));
  sl.registerLazySingleton(() => DocumentService());
}

//