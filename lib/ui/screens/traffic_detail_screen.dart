import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/traffic_record.dart';
import '../widgets/json_viewer.dart';

class TrafficDetailScreen extends StatelessWidget {
  final TrafficRecord record;

  const TrafficDetailScreen({
    super.key,
    required this.record,
  });

  static Color getStatusColor(TrafficStatusCategory category) {
    switch (category) {
      case TrafficStatusCategory.success:
        return const Color(0xFF2ECC71); // Green
      case TrafficStatusCategory.redirect:
        return const Color(0xFF3498DB); // Blue
      case TrafficStatusCategory.clientError:
        return const Color(0xFFE67E22); // Orange
      case TrafficStatusCategory.serverError:
      case TrafficStatusCategory.failed:
        return const Color(0xFFE74C3C); // Red
      case TrafficStatusCategory.pending:
        return const Color(0xFFF1C40F); // Yellow
    }
  }

  static Color getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return const Color(0xFF3B82F6);
      case 'POST':
        return const Color(0xFF10B981);
      case 'PUT':
        return const Color(0xFFF59E0B);
      case 'DELETE':
        return const Color(0xFFEF4444);
      case 'PATCH':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(record.statusCategory);
    final methodColor = getMethodColor(record.method);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: methodColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.method.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (record.statusCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    '${record.statusCode}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.path,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.terminal_rounded),
              tooltip: 'نسخ كود cURL',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: record.toCurlCommand()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نسخ أمر cURL إلى الحافظة'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.info_outline_rounded), text: 'نظرة عامة'),
              Tab(icon: Icon(Icons.upload_rounded), text: 'الطلب (Request)'),
              Tab(icon: Icon(Icons.download_rounded), text: 'الاستجابة (Response)'),
              Tab(icon: Icon(Icons.terminal_rounded), text: 'cURL'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildRequestTab(context),
            _buildResponseTab(context),
            _buildCurlTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          context,
          title: 'الرابط الكامل (Full URL)',
          content: record.url,
          canCopy: true,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRow('المضيف (Host)', record.host),
                const Divider(),
                _buildRow('المسار (Path)', record.path),
                const Divider(),
                _buildRow('طريقة الطلب (Method)', record.method.toUpperCase()),
                const Divider(),
                _buildRow(
                  'كود الحالة (Status)',
                  record.statusCode != null
                      ? '${record.statusCode} (${record.statusMessage ?? ''})'
                      : (record.isPending ? 'قيد التنفيذ...' : 'فشل'),
                ),
                const Divider(),
                _buildRow('الزمن المستغرق (Duration)', record.formattedDuration),
                const Divider(),
                _buildRow('حجم الطلب (Req Size)', record.formattedRequestSize),
                const Divider(),
                _buildRow('حجم الاستجابة (Res Size)', record.formattedResponseSize),
                const Divider(),
                _buildRow('وقت الإرسال (Timestamp)', record.timestamp.toLocal().toString()),
                if (record.error != null) ...[
                  const Divider(),
                  _buildRow('الخطأ (Error)', record.error!, isError: true),
                ],
              ],
            ),
          ),
        ),
        if (record.queryParameters.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'معاملات الاستعلام (Query Parameters)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildHeadersCard(context, record.queryParameters),
        ],
      ],
    );
  }

  Widget _buildRequestTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'رؤوس الطلب (Request Headers)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildHeadersCard(context, record.requestHeaders),
        const SizedBox(height: 16),
        Text(
          'جسم الطلب (Request Body)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        FormattedCodeViewer(
          content: record.prettyRequestBody,
          title: 'Request Payload',
        ),
      ],
    );
  }

  Widget _buildResponseTab(BuildContext context) {
    final resHeaders = record.responseHeaders ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'رؤوس الاستجابة (Response Headers)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildHeadersCard(context, resHeaders),
        const SizedBox(height: 16),
        Text(
          'جسم الاستجابة (Response Body)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        FormattedCodeViewer(
          content: record.prettyResponseBody,
          title: 'Response Payload (${record.formattedResponseSize})',
        ),
      ],
    );
  }

  Widget _buildCurlTab(BuildContext context) {
    final curl = record.toCurlCommand();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'أمر cURL جاهز للتشغيل مباشرة في سطر الأوامر أو استيراده في أدوات الفحص الأمني (Postman, Burp, etc.):',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 12),
        FormattedCodeViewer(
          content: curl,
          title: 'cURL Command',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: curl));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم نسخ أمر cURL بنجاح'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.copy_rounded),
          label: const Text('نسخ أمر cURL بالكامل'),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String content, bool canCopy = false}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (canCopy)
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم النسخ إلى الحافظة'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              content,
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadersCard(BuildContext context, Map<String, String> headers) {
    if (headers.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('لا توجد رؤوس (No Headers)', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: headers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SelectableText(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const Text(' : '),
                  Expanded(
                    flex: 3,
                    child: SelectableText(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isError ? Colors.red : null,
                fontFamily: isError ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
