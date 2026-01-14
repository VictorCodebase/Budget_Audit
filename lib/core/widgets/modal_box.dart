import 'dart:ui';
import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Shows a modal box with platform-adaptive styling
///
/// On mobile: Full-screen solid modal with minimize capability
/// On desktop/web: Translucent floating box with glass morphism
Future<T?> showModalBox<T>({
  required BuildContext context,
  required Widget child,
  double? width,
  double? height,
  bool barrierDismissible = true,
}) {
  final isDesktop = _isDesktopPlatform(context);

  if (isDesktop) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Modal',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      // Add useRootNavigator to prevent navigation conflicts
      useRootNavigator: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        // Wrap in MouseRegion to absorb mouse events during transition
        return MouseRegion(
          cursor: SystemMouseCursors.basic,
          child: _DesktopModalBox(
            child: child,
            width: width,
            height: height,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Prevent pointer events during animation
        return IgnorePointer(
          ignoring: animation.status == AnimationStatus.forward ||
              animation.status == AnimationStatus.reverse,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ).drive(Tween<double>(begin: 0.9, end: 1.0)),
              child: child,
            ),
          ),
        );
      },
    );
  } else {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: true,
      builder: (context) => _MobileModalBox(
        child: child,
        height: height,
      ),
    );
  }
}

/// Determines if the current platform is desktop
bool _isDesktopPlatform(BuildContext context) {
  if (kIsWeb) {
    // On web, check screen width
    final width = MediaQuery.of(context).size.width;
    return width >= 768; // Tablet breakpoint
  }

  // For native platforms
  try {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  } catch (e) {
    return false;
  }
}

/// Desktop modal with glass morphism effect
class _DesktopModalBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const _DesktopModalBox({
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final modalWidth = width ?? screenSize.width * 0.6;
    final modalHeight = height ?? screenSize.height * 0.7;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: modalWidth.clamp(300.0, screenSize.width * 0.9),
          height: modalHeight.clamp(200.0, screenSize.height * 0.9),
          constraints: BoxConstraints(
            maxWidth: screenSize.width * 0.9,
            maxHeight: screenSize.height * 0.9,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.surfaceVariant,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            iconSize: 20,
                            color: context.colors.textPrimary,
                            splashRadius: 20,
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile modal with minimize capability
class _MobileModalBox extends StatefulWidget {
  final Widget child;
  final double? height;

  const _MobileModalBox({
    required this.child,
    this.height,
  });

  @override
  State<_MobileModalBox> createState() => _MobileModalBoxState();
}

class _MobileModalBoxState extends State<_MobileModalBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = Tween<double>(begin: 1.0, end: 0.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
      if (_isMinimized) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = widget.height ?? screenHeight * 0.85;

    return AnimatedBuilder(
      animation: _heightFactor,
      builder: (context, child) {
        return Container(
          height: modalHeight * _heightFactor.value,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with drag handle and minimize button
              GestureDetector(
                onTap: _toggleMinimize,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Minimize button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _toggleMinimize,
                            icon: Icon(
                              _isMinimized
                                  ? Icons.expand_less
                                  : Icons.minimize,
                            ),
                            iconSize: 24,
                            color: Colors.black54,
                            splashRadius: 24,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Content (only show when not minimized)
              if (!_isMinimized)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: widget.child,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}