import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/bootstrap/app_initialize.dart';
import 'core/routing/app_router.dart';
import 'core/context.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp(); // This should call setupLocator() inside

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppContext()),
      ],
      child: const BudgetAudit(),
    ),
  );
}

class BudgetAudit extends StatelessWidget {
  const BudgetAudit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetAudit',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/onboarding',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
