import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';

/// Card displaying headers or query parameters key-value pairs with copy support.
class TrafficHeadersCard extends StatelessWidget {
  final Map<String, dynamic> headers;

  const TrafficHeadersCard({
    super.key,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (headers.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: AppSpacing.paddingCard,
          child: Center(
            child: Text(
              'none'.tr,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: headers.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final key = headers.keys.elementAt(index);
          final value = headers[key].toString();

          return ListTile(
            dense: true,
            title: SelectableText(
              key,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(AppIcons.copy, size: AppSpacing.iconXs),
              tooltip: 'copy_curl'.tr,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '$key: $value'));
                Get.rawSnackbar(
                  message: 'copied_to_clipboard'.tr,
                  duration: const Duration(seconds: 1),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
