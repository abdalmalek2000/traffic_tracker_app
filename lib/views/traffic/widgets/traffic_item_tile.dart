import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../models/traffic_record.dart';
import '../traffic_detail_view.dart';

/// Single item tile in the traffic list showing status code, method, host, path, size, and duration.
class TrafficItemTile extends StatelessWidget {
  final TrafficRecord item;

  const TrafficItemTile({
    super.key,
    required this.item,
  });

  static Widget buildMethodBadge(String method, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppSpacing.borderRadiusXs,
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          color: AppColors.getContrastingColor(color),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getStatusCategoryColor(
      item.statusCode,
      isPending: item.isPending,
    );
    final methodColor = TrafficDetailView.getMethodColor(item.method);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 360;

    return InkWell(
      onTap: () => Get.to(() => TrafficDetailView(record: item)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? AppSpacing.space8 : AppSpacing.space14,
          vertical: isNarrow ? AppSpacing.space10 : AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status code container or loading spinner
            Container(
              width: isNarrow ? 38 : AppSpacing.minTouchTarget,
              height: isNarrow ? 38 : AppSpacing.minTouchTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: AppSpacing.borderRadiusBase,
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: item.isPending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: statusColor,
                      ),
                    )
                  : Text(
                      item.statusCode?.toString() ?? 'ERR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
            ),
            isNarrow ? AppSpacing.horizontalSm : AppSpacing.horizontalMd,

            // Method, Path, and Host
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildMethodBadge(item.method, methodColor),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Text(
                          item.path,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    item.host,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            isNarrow ? AppSpacing.horizontalXs : AppSpacing.horizontalSm,

            // Duration & size
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.formattedDuration,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSpacing.verticalXxs,
                Text(
                  item.formattedResponseSize,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
            AppSpacing.horizontalXs,
            Icon(
              AppIcons.chevronRight,
              size: AppSpacing.iconSm,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}
