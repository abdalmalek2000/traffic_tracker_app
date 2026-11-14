import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';

/// Detail key-value card with copy support used in connection inspector.
class VpnDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final bool canCopy;
  final String? copyText;

  const VpnDetailCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.canCopy = false,
    this.copyText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSpacing.iconMd, color: theme.colorScheme.primary),
          AppSpacing.horizontal10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                AppSpacing.verticalXxs,
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  AppSpacing.verticalXxs,
                  SelectableText(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary(context),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              icon: const Icon(AppIcons.copy, size: AppSpacing.iconXs),
              tooltip: 'copy_curl'.tr,
              onPressed: () {
                final txt = copyText ?? value;
                Clipboard.setData(ClipboardData(text: txt));
                Get.rawSnackbar(
                  message: 'copied_to_clipboard'.tr,
                  duration: const Duration(seconds: 1),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
        ],
      ),
    );
  }
}
