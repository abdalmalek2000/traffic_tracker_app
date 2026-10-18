import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/traffic_controller.dart';
import '../../models/traffic_record.dart';
import '../../services/test_request_service.dart';
import 'traffic_detail_view.dart';

/// واجهة فحص ومراقبة طلبات الـ HTTP/HTTPS الداخلية
class TrafficListView extends StatefulWidget {
  const TrafficListView({super.key});

  @override
  State<TrafficListView> createState() => _TrafficListViewState();
}

class _TrafficListViewState extends State<TrafficListView> {
  final TextEditingController _searchController = TextEditingController();
  final TestRequestService _testService = TestRequestService();
  bool _isSendingTest = false;

  TrafficController get controller => TrafficController.to;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSampleRequest(Future<void> Function() action) async {
    setState(() => _isSendingTest = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isSendingTest = false);
      }
    }
  }

  void _showTestRequestsBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إرسال طلبات اختبارية (Test Requests)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر نوع الطلب لاختباره ومراقبة تسجيله فورياً في التطبيق:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: _buildMethodBadge('GET', TrafficDetailView.getMethodColor('GET')),
                title: const Text('طلب GET قياسي (200 OK)'),
                subtitle: const Text('jsonplaceholder.typicode.com/posts/1'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleGet);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: _buildMethodBadge('POST', TrafficDetailView.getMethodColor('POST')),
                title: const Text('طلب POST مع JSON Payload (201 Created)'),
                subtitle: const Text('مع بيانات أمنية ورؤوس توكن تجريبية'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSamplePost);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: _buildMethodBadge('GET', TrafficDetailView.getMethodColor('GET')),
                title: const Text('خطأ عميل 404 Not Found'),
                subtitle: const Text('اختبار التعامل مع المسارات غير الموجودة'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleClientError);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: _buildMethodBadge('GET', TrafficDetailView.getMethodColor('GET')),
                title: const Text('خطأ خادم 500 Internal Server Error'),
                subtitle: const Text('اختبار استجابة أخطاء الخادم'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleServerError);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('إرسال طلب مخصص (Custom URL/Body)'),
                onPressed: () {
                  Get.back();
                  _showCustomRequestDialog();
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCustomRequestDialog() {
    final urlController =
        TextEditingController(text: 'https://jsonplaceholder.typicode.com/todos/1');
    String selectedMethod = 'GET';
    final bodyController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('إرسال طلب مخصص'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    decoration: const InputDecoration(labelText: 'Method'),
                    items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedMethod = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(labelText: 'URL'),
                  ),
                  if (selectedMethod != 'GET') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Request Body (JSON / Text)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final url = urlController.text.trim();
                  if (url.isNotEmpty) {
                    Get.back();
                    _triggerSampleRequest(() => _testService.sendCustomRequest(
                          url: url,
                          method: selectedMethod,
                          body: bodyController.text.isNotEmpty
                              ? bodyController.text
                              : null,
                        ));
                  }
                },
                child: const Text('إرسال ومراقبة'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.radar_rounded, size: 24),
            const SizedBox(width: 8),
            const Text('مراقب الشبكة', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Obx(() {
              final isRec = controller.isRecording.value;
              return Tooltip(
                message: isRec
                    ? 'المراقبة نشطة (إيقاف مؤقت)'
                    : 'المراقبة متوقفة (استئناف)',
                child: IconButton(
                  icon: Icon(
                    isRec
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: isRec ? Colors.green : Colors.grey,
                    size: 26,
                  ),
                  onPressed: () => controller.toggleRecording(),
                ),
              );
            }),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'مسح السجلات',
              onPressed: () {
                controller.clearRecords();
                Get.rawSnackbar(
                  message: 'تم مسح جميع السجلات',
                  duration: const Duration(seconds: 1),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSendingTest ? null : _showTestRequestsBottomSheet,
        icon: _isSendingTest
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send_rounded),
        label: Text(_isSendingTest ? 'جاري الإرسال...' : 'طلب اختباري'),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث في الروابط، الحالة، أو المحتوى...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  onChanged: (val) {
                    controller.setSearchQuery(val);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterChips(),
              ],
            ),
          ),

          // Main List
          Expanded(
            child: Obx(() {
              final records = controller.filteredRecords;

              if (records.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.network_check_rounded,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد طلبات مسجلة حالياً',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'أي طلب شبكة يتم إرساله سيظهر هنا لحظياً مع كافة التفاصيل والـ Headers والـ Payloads.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.tonalIcon(
                          onPressed: _showTestRequestsBottomSheet,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('إرسال طلب اختباري لتجربة المراقبة'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: records.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  thickness: 0.5,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  final item = records[index];
                  return _buildTrafficItemTile(context, item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final active = controller.activeFilter.value;
      final total = controller.records.length;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip(
              label: 'الكل ($total)',
              isSelected: active == TrafficFilter.all,
              onSelected: () => controller.setActiveFilter(TrafficFilter.all),
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '2xx نجاح',
              color: const Color(0xFF2ECC71),
              isSelected: active == TrafficFilter.success,
              onSelected: () => controller.setActiveFilter(TrafficFilter.success),
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '3xx توجيه',
              color: const Color(0xFF3498DB),
              isSelected: active == TrafficFilter.redirect,
              onSelected: () => controller.setActiveFilter(TrafficFilter.redirect),
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '4xx خطأ عميل',
              color: const Color(0xFFE67E22),
              isSelected: active == TrafficFilter.clientError,
              onSelected: () => controller.setActiveFilter(TrafficFilter.clientError),
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '5xx خطأ خادم',
              color: const Color(0xFFE74C3C),
              isSelected: active == TrafficFilter.serverError,
              onSelected: () => controller.setActiveFilter(TrafficFilter.serverError),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChip({
    required String label,
    Color? color,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : null,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.transparent,
      selectedColor: color ?? Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTrafficItemTile(BuildContext context, TrafficRecord item) {
    final statusColor = TrafficDetailView.getStatusColor(item.statusCategory);
    final methodColor = TrafficDetailView.getMethodColor(item.method);

    return InkWell(
      onTap: () {
        Get.to(() => TrafficDetailView(record: item));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: statusColor.withValues(alpha: 0.6), width: 1.2),
              ),
              child: item.isPending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: statusColor),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildMethodBadge(item.method, methodColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.path,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.host,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                const SizedBox(height: 2),
                Text(
                  item.formattedResponseSize,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodBadge(String method, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        method.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
