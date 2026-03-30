import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/context.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for at least 2 seconds, or until app is ready if we move init here.
    // Since init is in main, the app is already "ready" logic-wise.
    // We just show this for branding.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final appContext = Provider.of<AppContext>(context, listen: false);
    if (appContext.hasValidSession) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          context.colors.surface, // Or specific splash background color
      body: Center(
        child: Container(
          constraints:
              const BoxConstraints(maxWidth: 800), // constrain width if needed
          padding: const EdgeInsets.all(32),
          child: Image.asset(
            'assets/images/splash-screen.png',
            fit: BoxFit.contain,
            width: 1316 /
                2, // Scale down the huge original size slightly if needed, or let layout handle it
          ),
        ),
      ),
    );
  }
}
