import 'package:flutter/material.dart';

/// Defines the available control actions for a ContentBox
enum ContentBoxAction {
  delete,
  minimize,
  maximize,
  preview,
  refresh,
}

/// Configuration for a ContentBox control action
class ContentBoxControl {
  final ContentBoxAction action;
  final VoidCallback? onPressed;
  final IconData? customIcon;
  final Color? customColor;

  const ContentBoxControl({
    required this.action,
    this.onPressed,
    this.customIcon,
    this.customColor,
  });
}

/// A versatile container widget that displays content with window-like controls
///
/// Features:
/// - Minimize/Maximize functionality
/// - Preview widgets shown when minimized
/// - Optional header widgets when maximized
/// - Customizable control actions (delete, refresh, preview, etc.)
class ContentBox extends StatefulWidget {
  /// The main content to display when maximized
  final Widget content;

  /// Up to 4 widgets to display when minimized (shown horizontally)
  final List<Widget> previewWidgets;

  /// Optional header widgets (up to 2) shown at the top when maximized
  final List<Widget> headerWidgets;

  /// Control actions available for this box
  final List<ContentBoxControl> controls;

  /// Height when minimized (default: 60dp)
  final double minimizedHeight;

  /// Optional fixed width for the box
  final double? width;

  /// Spacing between preview widgets when minimized
  final double previewSpacing;

  /// Initial state (minimized or maximized)
  final bool initiallyMinimized;

  /// Padding inside the content area
  final EdgeInsets contentPadding;

  const ContentBox({
    Key? key,
    required this.content,
    this.previewWidgets = const [],
    this.headerWidgets = const [],
    this.controls = const [],
    this.minimizedHeight = 60.0,
    this.width,
    this.previewSpacing = 60.0,
    this.initiallyMinimized = false,
    this.contentPadding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  State<ContentBox> createState() => _ContentBoxState();
}

class _ContentBoxState extends State<ContentBox> with SingleTickerProviderStateMixin {
  late bool _isMinimized;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _isMinimized = widget.initiallyMinimized;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (!_isMinimized) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
      if (_isMinimized) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  void _handleAction(ContentBoxAction action, VoidCallback? callback) {
    switch (action) {
      case ContentBoxAction.minimize:
      case ContentBoxAction.maximize:
        _toggleMinimize();
        break;
      case ContentBoxAction.delete:
        _showDeleteConfirmation(callback);
        break;
      default:
        callback?.call();
    }
  }

  void _showDeleteConfirmation(VoidCallback? onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this content?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlIcon(ContentBoxControl control) {
    IconData icon;
    Color color = control.customColor ?? const Color(0xFF6B7280);

    if (control.customIcon != null) {
      icon = control.customIcon!;
    } else {
      switch (control.action) {
        case ContentBoxAction.delete:
          icon = Icons.close;
          color = control.customColor ?? const Color(0xFFEF4444);
          break;
        case ContentBoxAction.minimize:
          icon = Icons.minimize;
          break;
        case ContentBoxAction.maximize:
          icon = Icons.open_in_full;
          break;
        case ContentBoxAction.preview:
          icon = Icons.visibility_outlined;
          break;
        case ContentBoxAction.refresh:
          icon = Icons.refresh;
          break;
      }
    }

    return InkWell(
      onTap: () => _handleAction(control.action, control.onPressed),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildControls() {
    // Determine which action to show based on minimize state
    List<ContentBoxControl> activeControls = widget.controls.map((control) {
      if (control.action == ContentBoxAction.minimize && _isMinimized) {
        return ContentBoxControl(
          action: ContentBoxAction.maximize,
          onPressed: control.onPressed,
        );
      } else if (control.action == ContentBoxAction.maximize && !_isMinimized) {
        return ContentBoxControl(
          action: ContentBoxAction.minimize,
          onPressed: control.onPressed,
        );
      }
      return control;
    }).toList();

    return Positioned(
      top: 12,
      left: 12,
      child: Row(
        children: [
          for (int i = 0; i < activeControls.length; i++) ...[
            _buildControlIcon(activeControls[i]),
            if (i < activeControls.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimizedContent() {
    final previewsToShow = widget.previewWidgets.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          for (int i = 0; i < previewsToShow.length; i++) ...[
            previewsToShow[i],
            if (i < previewsToShow.length - 1)
              SizedBox(width: widget.previewSpacing),
          ],
        ],
      ),
    );
  }

  Widget _buildMaximizedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header widgets
        if (widget.headerWidgets.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                for (int i = 0; i < widget.headerWidgets.take(2).length; i++) ...[
                  Flexible(child: widget.headerWidgets[i]),
                  if (i == 0 && widget.headerWidgets.length > 1)
                    const SizedBox(width: 16),
                ],
              ],
            ),
          )
        else
          const SizedBox(height: 40), // Space for controls

        // Main content
        Expanded(
          child: Padding(
            padding: widget.contentPadding,
            child: widget.content,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, child) {
          return Container(
            height: _isMinimized
                ? widget.minimizedHeight
                : null,
            constraints: _isMinimized
                ? BoxConstraints(
              minHeight: widget.minimizedHeight,
              maxHeight: widget.minimizedHeight,
            )
                : null,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFC7C7C7),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _isMinimized
                      ? _buildMinimizedContent()
                      : _buildMaximizedContent(),
                ),
                if (widget.controls.isNotEmpty) _buildControls(),
              ],
            ),
          );
        },
      ),
    );
  }
}