import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Shows a modal with frosted glass effect on desktop/web and solid on mobile
///
/// Parameters:
/// - [child]: The widget to display inside the modal
/// - [enableGlassEffect]: Whether to enable the frosted glass effect (auto-detects platform)
/// - [backgroundColor]: Background color for the modal content
/// - [blurAmount]: Amount of blur for the glass effect (default: 10)
/// - [borderRadius]: Border radius for the modal
/// - [padding]: Padding inside the modal
/// - [width]: Optional fixed width for the modal
/// - [height]: Optional fixed height for the modal
/// - [barrierDismissible]: Whether tapping outside dismisses the modal
Future<T?> showModalBox<T>({
  required BuildContext context,
  required Widget child,
  bool? enableGlassEffect,
  Color? backgroundColor,
  double blurAmount = 10.0,
  BorderRadius? borderRadius,
  EdgeInsets? padding,
  double? width,
  double? height,
  bool barrierDismissible = true,
}) {
  // Auto-detect if we should use glass effect
  final bool useGlassEffect = enableGlassEffect ?? _shouldUseGlassEffect();

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: useGlassEffect
        ? Colors.black.withOpacity(0.2)
        : Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return ModalBoxContent(
        child: child,
        useGlassEffect: useGlassEffect,
        backgroundColor: backgroundColor,
        blurAmount: blurAmount,
        borderRadius: borderRadius,
        padding: padding,
        width: width,
        height: height,
      );
    },
  );
}

/// Helper to determine if glass effect should be used
bool _shouldUseGlassEffect() {
  if (kIsWeb) return true; // Use glass effect on web

  try {
    // Use glass effect on desktop platforms
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  } catch (e) {
    // If Platform is not available (web), default to true
    return true;
  }
}

/// The content widget for the modal box
class ModalBoxContent extends StatefulWidget {
  final Widget child;
  final bool useGlassEffect;
  final Color? backgroundColor;
  final double blurAmount;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const ModalBoxContent({
    Key? key,
    required this.child,
    required this.useGlassEffect,
    this.backgroundColor,
    this.blurAmount = 10.0,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<ModalBoxContent> createState() => _ModalBoxContentState();
}

class _ModalBoxContentState extends State<ModalBoxContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  void _close() {
    _controller.reverse().then((_) => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final defaultWidth = size.width * 0.85;
    final defaultHeight = size.height * 0.85;

    final effectiveWidth = widget.width ?? defaultWidth;
    final effectiveHeight = widget.height ?? defaultHeight;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isMinimized ? 300 : effectiveWidth,
            height: _isMinimized ? 60 : effectiveHeight,
            child: widget.useGlassEffect
                ? _buildGlassContainer()
                : _buildSolidContainer(),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer() {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurAmount,
          sigmaY: widget.blurAmount,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor?.withOpacity(0.7) ??
                Colors.white.withOpacity(0.7),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildSolidContainer() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        // Main content
        Padding(
          padding: widget.padding ?? const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32), // Space for controls
              Expanded(
                child: _isMinimized
                    ? const Center(child: Text('Minimized'))
                    : widget.child,
              ),
            ],
          ),
        ),

        // Control buttons
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              _buildControlButton(
                icon: _isMinimized ? Icons.open_in_full : Icons.minimize,
                onPressed: _toggleMinimize,
              ),
              const SizedBox(width: 8),
              _buildControlButton(
                icon: Icons.close,
                onPressed: _close,
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (widget.useGlassEffect
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: (color ?? Colors.grey).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color ?? const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

/// Alternative: A custom route for more control over the modal presentation
class ModalBoxRoute<T> extends PageRoute<T> {
  final Widget child;
  final bool useGlassEffect;
  final Color? backgroundColor;
  final double blurAmount;

  ModalBoxRoute({
    required this.child,
    this.useGlassEffect = true,
    this.backgroundColor,
    this.blurAmount = 10.0,
  });

  @override
  Color? get barrierColor => useGlassEffect
      ? Colors.black.withOpacity(0.2)
      : Colors.black.withOpacity(0.5);

  @override
  String? get barrierLabel => 'Modal';

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return ModalBoxContent(
      child: child,
      useGlassEffect: useGlassEffect,
      backgroundColor: backgroundColor,
      blurAmount: blurAmount,
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: child,
      ),
    );
  }
}