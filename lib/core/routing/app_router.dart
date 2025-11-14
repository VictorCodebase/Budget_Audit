
import 'package:budget_audit/core/services/budget_service.dart';
import 'package:budget_audit/features/budgeting/budgeting_view.dart';
import 'package:budget_audit/features/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/budgeting/budgeting_viewmodel.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/onboarding/onboarding_viewmodel.dart';
import '../services/participant_service.dart';
import '../services/service_locator.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/onboarding':
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => OnboardingViewModel(
              sl<ParticipantService>(),
            ),
            child: const OnboardingView(),
          ),
        );

      case '/budgeting':

        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => BudgetingViewModel( // TODO: remember to change this to budgeting view model. i sorry you struggled before remembering this comment :(
              sl<BudgetService>(),
              sl<ParticipantService>(),
            ),
            child: const BudgetingView(),
          ),
        );

      case '/home':
      // TODO: Implement home page
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => OnboardingViewModel( // TODO: remember to change this to budgeting view model. i sorry you struggled before remembering this comment :(
              sl<ParticipantService>(),
            ),
            child: const HomeView(),
          ),
        );

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
