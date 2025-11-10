
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      // TODO: Implement budgeting page
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Budgeting Page - Coming Soon'),
            ),
          ),
        );

      case '/home':
      // TODO: Implement home page
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Home Page - Coming Soon'),
            ),
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
