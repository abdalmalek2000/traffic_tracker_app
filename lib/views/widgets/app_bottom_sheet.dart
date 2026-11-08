import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';

/// Unified modal bottom sheet wrapper, header, and presenter.
class AppBottomSheet {
  /// Displays a modal bottom sheet with unified styling across the system.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }

  /// Displays a modal bottom sheet using GetX without requiring a BuildContext.
  static Future<T?> showWithGet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return Get.bottomSheet<T>(
      child,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
    );
  }
}

/// Unified BottomSheet container with standard rounded corners and theme surface.
class AppBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final double maxHeightFactor;
  final EdgeInsetsGeometry? padding;

  const AppBottomSheetContainer({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.88,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: AppSpacing.radiusCircularXxl,
        ),
      ),
      padding: padding,
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}

/// Standardized drag handle and header bar for all BottomSheets.
class AppBottomSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onClose;
  final Widget? trailing;

  const AppBottomSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onClose,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Centered Drag handle pill
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: AppSpacing.borderRadiusRound,
            ),
          ),
        ),
        // Title and actions row
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSpacing.iconMd, color: theme.colorScheme.primary),
                AppSpacing.horizontalSm,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      AppSpacing.verticalXxs,
                      Text(
                        subtitle!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
              IconButton(
                icon: const Icon(AppIcons.close),
                tooltip: 'close'.tr,
                onPressed: onClose ?? () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
