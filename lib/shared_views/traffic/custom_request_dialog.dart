import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/api_endpoints.dart';
import '../../../constants/colors.dart';
import '../../../constants/spacing.dart';
import '../../../services/test_request_service.dart';

/// Dialog allowing user to configure and dispatch a custom HTTP request.
class CustomRequestDialog extends StatefulWidget {
  final Future<void> Function(Future<void> Function() action) onTriggerRequest;

  const CustomRequestDialog({
    super.key,
    required this.onTriggerRequest,
  });

  static void show({
    required Future<void> Function(Future<void> Function() action) onTriggerRequest,
  }) {
    Get.dialog(
      CustomRequestDialog(onTriggerRequest: onTriggerRequest),
    );
  }

  @override
  State<CustomRequestDialog> createState() => _CustomRequestDialogState();
}

class _CustomRequestDialogState extends State<CustomRequestDialog> {
  final TestRequestService _testService = TestRequestService();
  String _selectedMethod = 'GET';
  bool _followRedirects = true;
  late final TextEditingController _urlController;
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiEndpoints.httpbinGet);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onMethodChanged(String? val) {
    if (val == null) return;
    setState(() {
      final prevMethodUrl = ApiEndpoints.getUrlForMethod(_selectedMethod);
      if (_urlController.text.trim() == prevMethodUrl) {
        _urlController.text = ApiEndpoints.getUrlForMethod(val);
      }
      _selectedMethod = val;
    });
  }

  void _submit() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      Get.back();
      widget.onTriggerRequest(
        () => _testService.sendCustomRequest(
          url: url,
          method: _selectedMethod,
          body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
          followRedirects: _followRedirects,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('send_custom_request'.tr),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusXl,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedMethod,
              decoration: InputDecoration(labelText: 'method_label'.tr),
              items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: _onMethodChanged,
            ),
            AppSpacing.vertical10,
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'url_label'.tr),
            ),
            if (_selectedMethod != 'GET') ...[
              AppSpacing.vertical10,
              TextField(
                controller: _bodyController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'body_label'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            AppSpacing.verticalSm,
            CheckboxListTile(
              value: _followRedirects,
              title: Text(
                'follow_redirects'.tr,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'follow_redirects_desc'.tr,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) {
                setState(() => _followRedirects = val ?? true);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('cancel'.tr),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text('send_and_inspect'.tr),
        ),
      ],
    );
  }
}
