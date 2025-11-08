import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/bootstrap/app_initialize.dart';
import 'core/routing/app_router.dart';
import 'core/context.dart';
import 'features/onboarding/onboarding_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppContext()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
      ],
      child: const BudgetAudit(),
    ),
  );
}

class BudgetAudit extends StatelessWidget {
  const BudgetAudit({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter(context);
    return MaterialApp.router(
      title: 'BudgetAudit',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}
