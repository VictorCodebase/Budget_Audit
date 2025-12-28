import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class InlineEditableText extends StatefulWidget {
  final String text;
  final ValueChanged<String> onSubmitted;
  final TextStyle? style;
  final bool isNew;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? hintText;
  final TextAlign textAlign;
  final bool selectAllOnFocus;
  final TextEditingController? controller;

  const InlineEditableText({
    Key? key,
    required this.text,
    required this.onSubmitted,
    this.style,
    this.isNew = false,
    this.focusNode,
    this.nextFocusNode,
    this.inputFormatters,
    this.keyboardType,
    this.prefixText,
    this.hintText,
    this.textAlign = TextAlign.start,
    this.selectAllOnFocus = false,
    this.controller,
  }) : super(key: key);

  @override
  State<InlineEditableText> createState() => _InlineEditableTextState();
}

class _InlineEditableTextState extends State<InlineEditableText> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.text);
      _isInternalController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }

    _focusNode.addListener(_handleFocusChange);

    if (widget.isNew) {
      // Request focus after the frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(InlineEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text && widget.text != _controller.text) {
      _controller.text = widget.text;
    }
    // Handle controller change if needed (rare but possible)
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      if (widget.selectAllOnFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    } else {
      // Save on blur
      _submit();
    }
  }

  String? _lastSubmittedValue;

  void _submit() {
    final newValue = _controller.text.trim();
    if (newValue.isNotEmpty && newValue != widget.text) {
      if (newValue != _lastSubmittedValue) {
        _lastSubmittedValue = newValue;
        widget.onSubmitted(newValue);
      }
    } else if (newValue.isEmpty) {
      // Revert if empty
      _controller.text = widget.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      style: widget.style ?? AppTheme.bodySmall,
      textAlign: widget.textAlign,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXs,
          vertical: 6,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          borderSide: BorderSide(color: context.colors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          borderSide: BorderSide(color: context.colors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          borderSide: BorderSide(color: context.colors.primary, width: 1),
        ),
        prefixText: widget.prefixText,
        hintText: widget.hintText,
        fillColor: context.colors.surface,
        filled: true,
      ),
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.keyboardType,
      onFieldSubmitted: (value) {
        _submit();
        if (widget.nextFocusNode != null) {
          widget.nextFocusNode!.requestFocus();
        }
      },
      onTapOutside: (event) {
        _focusNode.unfocus();
      },
    );
  }
}
