import 'package:flutter/material.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../constants/typography.dart';

/// Highly reusable and adaptable tile for settings items.
/// Supports leading icons, titles, subtitles, current value indicators,
/// custom trailing widgets, dynamic responsive text scaling, and tap interactions.
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

    // Trailing icon/widget (fixed width slot for consistent alignment across all rows)
    Widget? trailingIconWidget;
    if (trailing != null) {
      trailingIconWidget = trailing;
    } else if (showChevron && onTap != null) {
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      trailingIconWidget = Icon(
        isRtl ? AppIcons.chevronLeft : AppIcons.chevronRight,
        size: AppSpacing.iconSm,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      );
    }

    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Leading Icon (Fixed size)
            if (leadingWidget != null) ...[
              leadingWidget,
              AppSpacing.horizontalBase,
            ],

            // Content Area:
            // When value exists: splits 2/3 for Title/Subtitle and 1/3 for Value
            if (hasValue) ...[
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: AppTypography.responsiveFontSize(
                          context,
                          14.0,
                        ),
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.responsiveFontSize(
                            context,
                            11.0,
                          ),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                flex: 1,
                child: Text(
                  value!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: AppTypography.responsiveFontSize(context, 12.0),
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ] else ...[
              // When no value exists: Title & Subtitle occupies full text space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: AppTypography.responsiveFontSize(
                          context,
                          14.0,
                        ),
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.responsiveFontSize(
                            context,
                            11.0,
                          ),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Fixed Trailing Icon Slot (Ensures all trailing icons align uniformly at the edge)
            if (trailingIconWidget != null) ...[
              AppSpacing.horizontalSm,
              SizedBox(
                width: 16,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailingIconWidget,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
