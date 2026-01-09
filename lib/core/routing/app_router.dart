import 'package:budget_audit/core/services/budget_service.dart';
import 'package:budget_audit/core/services/document_service.dart';
import 'package:budget_audit/features/analytics/analytics_view.dart';
import 'package:budget_audit/features/analytics/analytics_viewmodel.dart';
import 'package:budget_audit/features/budgeting/budgeting_view.dart';
import 'package:budget_audit/features/home/home_view.dart';
import 'package:budget_audit/features/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/budgeting/budgeting_viewmodel.dart';
import '../../features/dev/dev_view.dart';
import '../../features/dev/dev_viewmodel.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/onboarding/onboarding_viewmodel.dart';
import '../data/database.dart';
import '../services/dev_service.dart';
import '../services/participant_service.dart';
import '../services/service_locator.dart';
import '../context.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/onboarding':
        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => OnboardingViewModel(sl<ParticipantService>(),
                Provider.of<AppContext>(context, listen: false)),
            child: const OnboardingView(),
          ),
        );

      case '/budgeting':
        return MaterialPageRoute(
          builder: (context) {
            final appContext = Provider.of<AppContext>(context, listen: false);

            if (!appContext.hasValidSession) {
              return const OnboardingView();
            }

            return ChangeNotifierProvider(
              create: (_) => BudgetingViewModel(
                sl<BudgetService>(),
                sl<ParticipantService>(),
                Provider.of<AppContext>(context, listen: false),
              ),
              child: const BudgetingView(),
            );
          },
        );

      case '/home':
        return MaterialPageRoute(
          builder: (context) {
            final appContext = Provider.of<AppContext>(context, listen: false);

            if (!appContext.hasValidSession) {
              return const OnboardingView();
            }

            // return ChangeNotifierProvider(
            //   create: (_) => HomeViewModel(
            //     documentService: sl<DocumentService>(),
            //     participantService: sl<ParticipantService>(),
            //     budgetService: sl<BudgetService>(),
            //     appContext: Provider.of<AppContext>(context, listen: false),
            //   ),
            //   child: const HomeView(),
            // );
            return const HomeView();
          },
        );

      case '/analytics':
        return MaterialPageRoute(
          builder: (context) {
            final appContext = Provider.of<AppContext>(context, listen: false);

            if (!appContext.hasValidSession) {
              return const OnboardingView();
            }

            return ChangeNotifierProvider(
              create: (_) => AnalyticsViewModel(
                budgetService: sl<BudgetService>(),
                appContext: appContext,
              ),
              child: const AnalyticsView(),
            );
          },
        );

      case '/dev':
        return MaterialPageRoute(builder: (context) {
          final appContext = Provider.of<AppContext>(context, listen: false);
          if (appContext.isProduction) { //! route only available in dev env
            debugPrint("In production, redirecting to onboarding");
            return const OnboardingView();
          }
          return ChangeNotifierProvider(
            create: (_) => DevViewModel(
              DevService(
                sl<AppDatabase>(),
                Provider.of<AppContext>(_, listen: false),
              ),
            )..loadTables(),
            child: const DevView(),
          );
        });

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
