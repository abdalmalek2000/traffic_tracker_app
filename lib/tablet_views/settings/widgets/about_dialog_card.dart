  import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:traffic_tracker_app/constants/colors.dart';
import 'package:traffic_tracker_app/constants/icons.dart';
import 'package:traffic_tracker_app/constants/spacing.dart';
import 'package:traffic_tracker_app/tablet_views/settings/widgets/tablet_about_app_dialog.dart';


  // ==========================================
  // ABOUT APPLICATION (Dialog Launcher)
  // ==========================================

Widget buildAboutCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        leading: Icon(AppIcons.info, color: theme.colorScheme.primary),
        title: Text(
          'about_option'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
        ),
        subtitle: Text(
          'about_subtitle'.tr,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
        ),
        trailing: Icon(AppIcons.chevronRight, size: 20, color: AppColors.textMuted(context)),
        onTap: () => TabletAboutAppDialog.show(context),
      ),
    );
  }

