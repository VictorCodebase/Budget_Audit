import 'package:budget_audit/core/services/budget_service.dart';
import 'package:budget_audit/core/services/document_service.dart';
import 'package:budget_audit/core/services/preset_service.dart';
import 'package:budget_audit/features/analytics/analytics_view.dart';
import 'package:budget_audit/features/analytics/analytics_viewmodel.dart';
import 'package:budget_audit/features/budgeting/budgeting_view.dart';
import 'package:budget_audit/features/home/home_view.dart';
import 'package:budget_audit/features/home/home_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/account_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/category_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/participant_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/template_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/vendor_management_viewmodel.dart';
import 'package:budget_audit/features/settings/settings_view.dart';
import 'package:budget_audit/features/settings/settings_viewmodel.dart';
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
                sl<PresetService>(),
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
                participantService: sl<ParticipantService>(),
                appContext: appContext,
              ),
              child: const AnalyticsView(),
            );
          },
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (context) {
            final appContext = Provider.of<AppContext>(context, listen: false);

            if (!appContext.hasValidSession) {
              return const OnboardingView();
            }

            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => SettingsViewModel(
                    appContext,
                    sl<ParticipantService>(),
                    sl<BudgetService>(),
                  )..initialize(),
                ),
                ChangeNotifierProvider(
                  create: (_) => ParticipantManagementViewModel(
                    sl<ParticipantService>(),
                    appContext,
                  )..initialize(),
                ),
                ChangeNotifierProvider(
                  create: (_) => TemplateManagementViewModel(
                    sl<BudgetService>(),
                    sl<ParticipantService>(),
                    appContext,
                  )..initialize(),
                ),
                ChangeNotifierProvider(
                  create: (_) => CategoryManagementViewModel(
                    sl<BudgetService>(),
                    sl<ParticipantService>(),
                    appContext,
                  )..initialize(),
                ),
                ChangeNotifierProvider(
                  create: (_) => AccountManagementViewModel(
                    sl<BudgetService>(),
                    sl<ParticipantService>(),
                    appContext,
                  )..initialize(),
                ),
                ChangeNotifierProvider(
                  create: (_) => VendorManagementViewModel(
                    sl<BudgetService>(),
                    sl<ParticipantService>(),
                    appContext,
                  )..initialize(),
                ),
              ],
              child: const SettingsView(),
            );
          },
        );

      case '/dev':
        return MaterialPageRoute(builder: (context) {
          final appContext = Provider.of<AppContext>(context, listen: false);
          if (appContext.isProduction) {
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
