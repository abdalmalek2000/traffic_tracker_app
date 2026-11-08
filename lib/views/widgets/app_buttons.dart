import 'package:flutter/material.dart';
import '../../constants/spacing.dart';

/// Unified Dynamic Primary Button for key actions across the application.
class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.height = AppSpacing.buttonHeight,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primary;
    final fg = foregroundColor ?? theme.colorScheme.onPrimary;

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSpacing.iconSm, color: fg),
                AppSpacing.horizontalSm,
              ],
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: fg,
                  ),
                ),
              ),
            ],
          );

    final style = FilledButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      minimumSize: isFullWidth ? Size(double.infinity, height) : Size(0, height),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? AppSpacing.borderRadiusLg,
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: FilledButton(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: buttonContent,
      ),
    );
  }
}

/// Unified Dynamic Secondary Button with semi-transparent background and centered text.
/// (ذو الخلفية شبه الشفافة مع نص في المنتصف)
class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? color;
  final double height;
  final BorderRadius? borderRadius;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.color,
    this.height = AppSpacing.buttonHeight,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = color ?? theme.colorScheme.primary;
    final bg = baseColor.withValues(alpha: 0.12);
    final fg = baseColor;

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSpacing.iconSm, color: fg),
                AppSpacing.horizontalSm,
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ],
          );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: bg,
        borderRadius: borderRadius ?? AppSpacing.borderRadiusLg,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Center(child: buttonContent),
          ),
        ),
      ),
    );
  }
}
