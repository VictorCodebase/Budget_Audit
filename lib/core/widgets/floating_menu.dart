import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingMenu extends StatefulWidget {
  final List<MenuDestination> destinations;

  const FloatingMenu({super.key, required this.destinations});

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glassmorphic Menu Panel
        Positioned(
          top: 60,
          left: 20,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: IgnorePointer(
              ignoring: !_isOpen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 220,
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  color: Colors.white.withOpacity(0.12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.destinations.map((dest) {
                        return ListTile(
                          leading: Icon(dest.icon, color: AppTheme.textPrimary),
                          title: Text(dest.label,
                              style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textPrimary)),
                          onTap: () {
                            Navigator.pushNamed(context, dest.route);
                            _toggleMenu();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Floating Circular Hamburger Button
        Positioned(
          top: 20,
          left: 20,
          child: GestureDetector(
            onTap: _toggleMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(2, 4),
                  )
                ],
              ),
              child: Icon(
                _isOpen ? Icons.close : Icons.menu,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

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
