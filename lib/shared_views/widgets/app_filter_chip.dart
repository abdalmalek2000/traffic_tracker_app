import 'package:flutter/material.dart';
import '../../constants/colors.dart';

/// Unified dynamic FilterChip component used across the application.
class AppFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;
  final int? count;
  final EdgeInsetsGeometry? padding;

  const AppFilterChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onSelected,
    this.color,
    this.count,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;
    final onChipColor =
        isSelected ? AppColors.getContrastingColor(activeColor) : null;
    final displayText = count != null ? '$label ($count)' : label;

    return FilterChip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 14,
              color: onChipColor ?? theme.colorScheme.onSurfaceVariant,
            )
          : null,
      label: Text(
        displayText,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: onChipColor,
        ),
      ),
      selected: isSelected,
      selectedColor: activeColor,
      checkmarkColor: onChipColor,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.35,
      ),
      side: BorderSide(
        color: isSelected
            ? activeColor
            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        width: 1,
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (_) => onSelected(),
    );
  }
}
