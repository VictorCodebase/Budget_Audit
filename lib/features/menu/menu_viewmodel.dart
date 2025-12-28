import 'package:flutter/material.dart';

import '../../core/context.dart';

class MenuDestination {
  final String label;
  final IconData icon;
  final String route;

  MenuDestination({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class MenuViewModel extends ChangeNotifier {
  bool _isOpen = false;
  final AppContext _appContext;

  MenuViewModel(this._appContext) {
    _appContext.addListener(_onAppContextChanged);
  }

  void _onAppContextChanged() {
    notifyListeners();
  }

  List<MenuDestination> get availableDestinations {
    // Re-run the filtering logic every time this is accessed and the VM notifies listeners.
    final allDestinations = [
      MenuDestination(label: 'Home', icon: Icons.home_outlined, route: '/home'),
      MenuDestination(
          label: 'Budgeting',
          icon: Icons.account_balance_wallet_outlined,
          route: '/budgeting'),
      MenuDestination(
          label: 'Analytics',
          icon: Icons.analytics_outlined,
          route: '/analytics'),
      MenuDestination(
          label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
      MenuDestination(
          label: 'Dev Tools',
          icon: Icons.developer_mode_outlined,
          route: '/dev'),
      MenuDestination(
          label: 'Sign Out', icon: Icons.logout_outlined, route: '/onboarding'),
    ];

    return allDestinations.where((dest) {
      switch (dest.route) {
        case '/budgeting':
        case '/analytics':
          // Only available if the user is logged in
          return _appContext.hasValidSession;
        case '/dev':
          // Only available if NOT in production
          return _appContext.isProduction ==
              true; //TODO: remember to change this to actually check env for app state
        case '/home':
          // Only show home after a valid session is established
          return _appContext.hasValidSession;
        case '/onboarding':
          // Only show "Sign Out" if logged in
          return _appContext.hasValidSession;
        default:
          return true;
      }
    }).toList();
  }

  @override
  void dispose() {
    _appContext.removeListener(_onAppContextChanged);
    super.dispose();
  }

  bool get isOpen => _isOpen;

  void menuToggled() {
    _isOpen = !_isOpen;
    debugPrint("Development env is: ${_appContext.isProduction}");
  }

  /// Handles the business logic for the selected menu destination.
  ///
  /// Returns `true` if a full navigation reset (like sign-out) is required,
  /// or `false` if only a regular push navigation is needed.
  bool handleDestinationSelected(String route) {
    if (route == '/onboarding') {
      // 1. Business Logic (Sign Out)
      debugPrint('User signed out.'); // Log the sign-out event
      _appContext.clear(); // Clear the user session/context state

      // 2. Instruct the UI on how to navigate (full reset needed)
      return true;
    }

    // 2. Instruct the UI on how to navigate (regular push needed)
    return false;
  }
}
