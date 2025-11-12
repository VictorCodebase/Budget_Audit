import 'package:flutter/material.dart';
import '../../core/widgets/floating_menu.dart';
import '../../core/theme/app_theme.dart';

class BudgetingView extends StatelessWidget {
  const BudgetingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          const Center(
            child: Text('Budgeting Page Content'),
          ),

          // Floating hamburger overlay
          FloatingMenu(
            destinations: [
              MenuDestination(label: 'Home', icon: Icons.home, route: '/home'),
              MenuDestination(
                  label: 'Budgeting', icon: Icons.wallet, route: '/budgeting'),
              MenuDestination(
                  label: 'Participants',
                  icon: Icons.people,
                  route: '/onboarding'),
            ],
          ),
        ],
      ),
    );
  }
}
