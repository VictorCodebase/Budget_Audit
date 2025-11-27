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
  }) : super(key: key);

  @override
  State<InlineEditableText> createState() => _InlineEditableTextState();
}

class _InlineEditableTextState extends State<InlineEditableText> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);

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
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // Save on blur
      _submit();
    }
  }

  void _submit() {
    final newValue = _controller.text.trim();
    if (newValue.isNotEmpty && newValue != widget.text) {
      widget.onSubmitted(newValue);
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
          borderSide: const BorderSide(color: AppTheme.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          borderSide: const BorderSide(color: AppTheme.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          borderSide: const BorderSide(color: AppTheme.primaryPink, width: 1),
        ),
        prefixText: widget.prefixText,
        hintText: widget.hintText,
        fillColor: Colors.white,
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
