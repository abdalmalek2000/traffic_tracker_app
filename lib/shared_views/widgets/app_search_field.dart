import 'package:flutter/material.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';

/// Unified dynamic Search TextField component across the application.
class AppSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? padding;

  const AppSearchField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
    this.padding,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = widget.controller.text.isNotEmpty;

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(AppIcons.search, size: AppSpacing.iconMd),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(AppIcons.clear, size: AppSpacing.iconSm),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                    setState(() {});
                  },
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusBase,
            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusBase,
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusBase,
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
