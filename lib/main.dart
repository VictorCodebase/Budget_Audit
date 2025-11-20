import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:provider/provider.dart';
import 'core/bootstrap/app_initialize.dart';
import 'core/routing/app_router.dart';
import 'core/context.dart';
import 'core/theme/app_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();

  final appContext = AppContext();
  await appContext.initialize();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appContext),
      ],
      child: BudgetAudit(appContext: appContext),
    ),
  );
}

class BudgetAudit extends StatelessWidget {
  final AppContext appContext;
  const BudgetAudit({super.key, required this.appContext});


  @override
  Widget build(BuildContext context) {
    String initialRoute = '/onboarding';

    if (appContext.hasValidSession) {
      initialRoute = '/budgeting';
    }
    return MaterialApp(
      title: 'BudgetAudit',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
