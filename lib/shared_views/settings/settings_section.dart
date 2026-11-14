import 'package:flutter/material.dart';
import '../../../constants/spacing.dart';

/// Reusable section container for settings screens.
/// Wraps grouped setting tiles into an elevated/outlined card with an optional section title.
class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    super.key,
    this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: children.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              indent: 56,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
            itemBuilder: (context, index) => children[index],
          ),
        ),
      ],
    );
  }
}
