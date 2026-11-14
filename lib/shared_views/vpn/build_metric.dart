import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/spacing.dart';

/// Single metric display item used in dashboard status cards.
class BuildMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const BuildMetric({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppSpacing.iconMd,
          color: Theme.of(context).colorScheme.primary,
        ),
        AppSpacing.verticalXs,
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
        ),
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}
