import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/traffic_controller.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_filter_chip.dart';

/// Horizontal filter chips bar for HTTP traffic status codes.
class TrafficFilterBar extends StatelessWidget {
  final TrafficController controller;

  const TrafficFilterBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.activeFilter.value;
      final total = controller.records.length;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            AppSpacing.horizontalMd,
            AppFilterChip(
              label: 'filter_all'.tr,
              count: total,
              isSelected: active == TrafficFilter.all,
              onSelected: () => controller.setActiveFilter(TrafficFilter.all),
            ),
            AppSpacing.horizontal6,
            AppFilterChip(
              label: 'filter_2xx'.tr,
              color: AppColors.statusSuccess,
              isSelected: active == TrafficFilter.success,
              onSelected: () => controller.setActiveFilter(TrafficFilter.success),
            ),
            AppSpacing.horizontal6,
            AppFilterChip(
              label: 'filter_3xx'.tr,
              color: AppColors.statusRedirect,
              isSelected: active == TrafficFilter.redirect,
              onSelected: () => controller.setActiveFilter(TrafficFilter.redirect),
            ),
            AppSpacing.horizontal6,
            AppFilterChip(
              label: 'filter_4xx'.tr,
              color: AppColors.statusClientError,
              isSelected: active == TrafficFilter.clientError,
              onSelected: () => controller.setActiveFilter(TrafficFilter.clientError),
            ),
            AppSpacing.horizontal6,
            AppFilterChip(
              label: 'filter_5xx'.tr,
              color: AppColors.statusServerError,
              isSelected: active == TrafficFilter.serverError,
              onSelected: () => controller.setActiveFilter(TrafficFilter.serverError),
            ),
            AppSpacing.horizontalMd,
          ],
        ),
      );
    });
  }
}
