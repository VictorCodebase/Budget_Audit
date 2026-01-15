// lib/core/services/service_locator.dart

import 'package:budget_audit/core/context.dart';
import 'package:budget_audit/core/services/preset_service.dart';
import 'package:budget_audit/features/home/home_viewmodel.dart';
import 'package:get_it/get_it.dart';
import '../data/database.dart';
import 'participant_service.dart';
import 'budget_service.dart';
import 'document_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (sl.isRegistered<AppDatabase>()) {
    return;
  }
  final db = AppDatabase();
  sl.registerSingleton<AppDatabase>(db);
  sl.registerLazySingleton(() => ParticipantService(sl<AppDatabase>()));
  sl.registerLazySingleton(() => BudgetService(sl<AppDatabase>()));
  sl.registerLazySingleton(() => DocumentService());
  sl.registerLazySingleton(() => PresetService());
  sl.registerLazySingleton<HomeViewModel>( // We ensure widget state in home is not lost
    () => HomeViewModel(
      documentService: sl<DocumentService>(),
      participantService: sl<ParticipantService>(),
      budgetService: sl<BudgetService>(),
      appContext: sl<AppContext>(),
    ),
  );
}

//
