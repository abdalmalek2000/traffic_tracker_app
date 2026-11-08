import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../models/captured_connection.dart';
import '../connection_detail_view.dart';

/// Connection tile displaying protocol badge, app/host information, packet size, and time.
class BuildConnectionTile extends StatelessWidget {
  final CapturedConnection item;

  const BuildConnectionTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final protocolColor = AppColors.getProtocolColor(item.protocol);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 360;

    return InkWell(
      onTap: () => ConnectionDetailView.show(item),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? AppSpacing.space8 : AppSpacing.base,
          vertical: isNarrow ? AppSpacing.space8 : AppSpacing.space10,
        ),
        child: Row(
          children: [
            // Protocol Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: protocolColor,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                item.protocol,
                style: TextStyle(
                  color: AppColors.getContrastingColor(protocolColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
            isNarrow ? AppSpacing.horizontalSm : AppSpacing.horizontalMd,

            // App Name Badge, Primary Host, and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.appName != null) ...[
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            margin: const EdgeInsetsDirectional.only(
                              end: AppSpacing.space6,
                            ),
                            decoration: BoxDecoration(
                              color: item.isSystemOrUnattributed
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : AppColors.protocolHttp.withValues(
                                      alpha: 0.15,
                                    ),
                              borderRadius: AppSpacing.borderRadiusXs,
                            ),
                            child: Text(
                              item.appName!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: item.isSystemOrUnattributed
                                    ? theme.colorScheme.onSurfaceVariant
                                    : AppColors.protocolHttp,
                              ),
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.primaryTitle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    item.readableSubtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            isNarrow ? AppSpacing.horizontalXs : AppSpacing.horizontalSm,

            // Packet size & formatted time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.formattedSize,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.formattedTime,
                  style: TextStyle(
                    fontSize: 10.5,
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
