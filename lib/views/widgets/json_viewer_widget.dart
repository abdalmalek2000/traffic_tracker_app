import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';

/// ويدجت منسق لعرض أكواد JSON والـ Payloads مع زر نسخ سريع
class JsonViewerWidget extends StatelessWidget {
  final String content;
  final String? title;

  const JsonViewerWidget({
    super.key,
    required this.content,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (content.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingAllXl,
          child: Text(
            'لا توجد بيانات (Empty Body)',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: AppSpacing.paddingVSm,
      decoration: BoxDecoration(
        color: isDark ? AppColors.jsonBackgroundDark : AppColors.jsonBackgroundLight,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space14,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.jsonHeaderDark : AppColors.jsonHeaderLight,
              borderRadius: const BorderRadius.vertical(
                top: AppSpacing.radiusCircularLg,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title ?? 'Payload',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.copy, size: AppSpacing.iconXs),
                  tooltip: 'نسخ المحتوى',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    Get.snackbar(
                      'تم النسخ',
                      'تم نسخ النص إلى الحافظة بنجاح',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space14),
            child: SelectableText(
              content,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                color: theme.colorScheme.onSurface,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
