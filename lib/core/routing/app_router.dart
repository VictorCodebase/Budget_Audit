import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/participant_service.dart';
import '../../core/context.dart';
import '../../features/home/home_view.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/onboarding/onboarding_viewmodel.dart';
import '../../features/home/home_viewmodel.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(BuildContext context) {
    final appContext = Provider.of<AppContext>(context, listen: false);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/loading',
      routes: [
        GoRoute(
          path: '/loading',
          builder: (_, __) => FutureBuilder(
            future: _checkParticipant(context, appContext),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              // Once future resolves, GoRouter redirect will handle navigation
              return const SizedBox.shrink();
            },
          ),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => OnboardingViewModel(),
            child: const OnboardingView(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomeView(),
          ),
        ),
      ],
      redirect: (context, state) async {
        final hasParticipant = appContext.currentParticipant != null;
        if (!hasParticipant && state.fullPath != '/onboarding') {
          return '/onboarding';
        } else if (hasParticipant && state.fullPath == '/onboarding') {
          return '/home';
        }
        return null;
      },
    );
  }

  static Future<void> _checkParticipant(
      BuildContext context, AppContext appContext) async {
    final participantService = sl<ParticipantService>();
    final participant = await participantService.getCurrentParticipant();
    if (participant != null) {
      appContext.setParticipant(participant);
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }
}
