import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


// Feature views
import '../../features/home/home_view.dart';
import '../../features/onboarding/onboarding_view.dart';

// ViewModels
import '../../features/onboarding/onboarding_viewmodel.dart';
import '../../features/home/home_viewmodel.dart';

/// AppRouter sets up all navigation rules and guards.
/// It uses Provider to determine which page to start from (Onboarding or Home).
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
  GlobalKey<NavigatorState>();

  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/onboarding',
      refreshListenable: Provider.of<OnboardingViewModel>(context, listen: false),
      redirect: (context, state) {
        final onboardingVM = Provider.of<OnboardingViewModel>(
          context,
          listen: false,
        );

        // If onboarding is complete, redirect to home
        final isOnboardingComplete = onboardingVM.isOnboardingComplete;
        final goingToOnboarding = state.fullPath == '/onboarding';

        if (isOnboardingComplete && goingToOnboarding) {
          return '/home';
        } else if (!isOnboardingComplete && !goingToOnboarding) {
          return '/onboarding';
        }
        return null; // no redirect
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => OnboardingViewModel(),
            child: const OnboardingView(),
          ),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomeView(),
          ),
        ),
      ],
    );
  }
}