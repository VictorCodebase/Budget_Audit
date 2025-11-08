import 'package:get_it/get_it.dart';
import '../data/databases.dart';
import 'participant_service.dart';
import 'budget_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final db = AppDatabase();

  sl.registerSingleton<AppDatabase>(db);
  sl.registerLazySingleton(() => ParticipantService(sl<AppDatabase>()));
  sl.registerLazySingleton(() => BudgetService(sl<AppDatabase>()));
}
