import 'package:budget_audit/core/theme/app_theme.dart';
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

  /// Optional maximized dimensions
  final double? maxHeight;
  final double? maxWidth;

  /// Spacing between preview widgets when minimized
  final double previewSpacing;

  /// Initial state (minimized or maximized)
  final bool initiallyMinimized;

  /// Padding inside the content area
  final EdgeInsets contentPadding;

  /// Whether to expand the content fully without scrolling (default: false)
  final bool expandContent;

  const ContentBox({
    Key? key,
    required this.content,
    this.previewWidgets = const [],
    this.headerWidgets = const [],
    this.controls = const [],
    this.minimizedHeight = 60.0,
    this.width,
    this.maxWidth,
    this.maxHeight,
    this.previewSpacing = 60.0,
    this.initiallyMinimized = false,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.expandContent = false,
  }) : super(key: key);

  @override
  State<ContentBox> createState() => _ContentBoxState();
}

class _ContentBoxState extends State<ContentBox>
    with SingleTickerProviderStateMixin {
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
      // case ContentBoxAction.delete:
      //   _showDeleteConfirmation(callback);
      //   break;
      //! Delete confirmation shall be on the onus of the parent widget
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

    return Row(
      children: [
        for (int i = 0; i < activeControls.length; i++) ...[
          _buildControlIcon(activeControls[i]),
          if (i < activeControls.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildMinimizedContent() {
    final previewsToShow = widget.previewWidgets.take(4).toList();

    return SizedBox(
      height: widget.minimizedHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if we have enough space for horizontal layout
            // Using 600 as breakpoint for tablet/desktop vs mobile
            final isSmallScreen = constraints.maxWidth < 600;

            if (isSmallScreen) {
              // Stack vertically on smaller screens
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < previewsToShow.length; i++) ...[
                          previewsToShow[i],
                          if (i < previewsToShow.length - 1)
                            const SizedBox(height: 4),
                        ],
                      ],
                    ),
                  ),
                  if (widget.controls.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildControls(),
                  ],
                ],
              );
            } else {
              // Horizontal layout with equal width sections
              return Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        for (int i = 0; i < previewsToShow.length; i++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: i < previewsToShow.length - 1 ? 16.0 : 0,
                              ),
                              child: previewsToShow[i],
                            ),
                          ),
                        // Fill remaining slots if less than 4
                        for (int i = previewsToShow.length; i < 4; i++)
                          const Spacer(),
                      ],
                    ),
                  ),
                  if (widget.controls.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    _buildControls(),
                  ],
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMaximizedContent(BuildContext context) {
    // Determine the max height for the scrollable area
    final double defaultMaxHeight = MediaQuery.of(context).size.height * 0.8;
    final double maxBoxHeight = widget.maxHeight ?? defaultMaxHeight;

    final contentWidget = Padding(
      padding: widget.contentPadding,
      child: widget.content,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header and controls at the same level
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header widgets
              if (widget.headerWidgets.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      for (int i = 0;
                          i < widget.headerWidgets.take(2).length;
                          i++) ...[
                        Flexible(child: widget.headerWidgets[i]),
                        if (i == 0 && widget.headerWidgets.length > 1)
                          const SizedBox(width: 16),
                      ],
                    ],
                  ),
                )
              else
                const Spacer(),
              // Controls
              if (widget.controls.isNotEmpty) _buildControls(),
            ],
          ),
        ),

        // Main content area
        if (widget.expandContent)
          contentWidget
        else
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: maxBoxHeight - 64), // Adjusted for header height
            child: SingleChildScrollView(
              child: contentWidget,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          height: _isMinimized ? widget.minimizedHeight : null,
          constraints: _isMinimized
              ? BoxConstraints(
                  minHeight: widget.minimizedHeight,
                  maxHeight: widget.minimizedHeight,
                )
              : null,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _isMinimized
                ? _buildMinimizedContent()
                : _buildMaximizedContent(context),
          ),
        ),
      ),
    );
  }
}
