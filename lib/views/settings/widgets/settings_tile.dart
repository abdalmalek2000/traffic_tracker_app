import 'package:flutter/material.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';

/// Highly reusable and adaptable tile for settings items.
/// Supports leading icons, titles, subtitles, current value indicators,
/// custom trailing widgets, and tap interactions.
class SettingsTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.showChevron = true,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget? leadingWidget;
    if (icon != null) {
      final effectiveIconColor =
          iconColor ??
          (isDestructive ? theme.colorScheme.error : theme.colorScheme.primary);
      final effectiveBgColor =
          iconBackgroundColor ??
          (isDestructive
              ? theme.colorScheme.error.withValues(alpha: 0.12)
              : effectiveIconColor.withValues(alpha: isDark ? 0.18 : 0.1));

      leadingWidget = Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: AppSpacing.borderRadiusBase,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: AppSpacing.iconMd, color: effectiveIconColor),
      );
    }

    Widget? effectiveTrailing = trailing;
    if (effectiveTrailing == null) {
      final List<Widget> trailingChildren = [];

      if (value != null && value!.isNotEmpty) {
        trailingChildren.add(
          Text(
            value!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      if (showChevron && onTap != null) {
        if (trailingChildren.isNotEmpty) {
          trailingChildren.add(AppSpacing.horizontalXs);
        }
        trailingChildren.add(
          Icon(
            AppIcons.chevronRight,
            size: AppSpacing.iconSm,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        );
      }

      if (trailingChildren.isNotEmpty) {
        effectiveTrailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: trailingChildren,
        );
      }
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            if (leadingWidget != null) ...[
              leadingWidget,
              AppSpacing.horizontalBase,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    AppSpacing.verticalXxs,
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (effectiveTrailing != null) ...[
              AppSpacing.horizontalSm,
              effectiveTrailing,
            ],
          ],
        ),
      ),
    );
  }
}
