import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../models/app_info.dart';

/// Single app row item with selection checkbox in AppFilterView.
class AppFilterItemTile extends StatelessWidget {
  final AppInfo app;
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;

  const AppFilterItemTile({
    super.key,
    required this.app,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isSelected,
      activeColor: AppColors.statusSuccess,
      onChanged: onChanged,
      secondary: app.iconBytes != null
          ? ClipRRect(
              borderRadius: AppSpacing.borderRadiusMd,
              child: Image.memory(
                app.iconBytes!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(
              AppIcons.android,
              size: 36,
              color: AppColors.statusSuccess,
            ),
      title: Text(
        app.appName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Row(
        children: [
          if (app.isSystemApp)
            Container(
              margin: const EdgeInsetsDirectional.only(
                end: AppSpacing.space6,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 1.5,
              ),
              decoration: BoxDecoration(
                color: AppColors.border(context).withValues(alpha: 0.3),
                borderRadius: AppSpacing.borderRadiusXs,
              ),
              child: Text(
                'system_badge'.tr,
                style: TextStyle(
                  fontSize: 9.5,
                  color: AppColors.textMuted(context),
                ),
              ),
            ),
          Expanded(
            child: Text(
              app.packageName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
