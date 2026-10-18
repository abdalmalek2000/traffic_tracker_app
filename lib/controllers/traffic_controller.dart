import 'dart:convert';
import 'package:get/get.dart';
import '../models/traffic_record.dart';

enum TrafficFilter {
  all,
  success,
  redirect,
  clientError,
  serverError,
  failed,
}

/// متحكم فحص وإدارة طلبات الـ HTTP/HTTPS الداخلية (In-App Traffic Controller)
class TrafficController extends GetxController {
  static TrafficController get to => Get.find();

  final RxList<TrafficRecord> records = <TrafficRecord>[].obs;
  final RxBool isRecording = true.obs;
  final RxString searchQuery = ''.obs;
  final Rx<TrafficFilter> activeFilter = TrafficFilter.all.obs;
  final RxnString methodFilter = RxnString();

  /// قائمة الطلبات المفلترة بحسب البحث وحالة الاستجابة والـ Method
  List<TrafficRecord> get filteredRecords {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = activeFilter.value;
    final method = methodFilter.value?.toUpperCase();

    return records.where((record) {
      // 1. تصفية بحسب نوع الطلب (GET, POST, ...)
      if (method != null && record.method.toUpperCase() != method) {
        return false;
      }

      // 2. تصفية بحسب فئة الحالة (2xx, 3xx, 4xx, 5xx, failed)
      switch (filter) {
        case TrafficFilter.all:
          break;
        case TrafficFilter.success:
          if (record.statusCategory != TrafficStatusCategory.success) return false;
          break;
        case TrafficFilter.redirect:
          if (record.statusCategory != TrafficStatusCategory.redirect) return false;
          break;
        case TrafficFilter.clientError:
          if (record.statusCategory != TrafficStatusCategory.clientError) return false;
          break;
        case TrafficFilter.serverError:
          if (record.statusCategory != TrafficStatusCategory.serverError) return false;
          break;
        case TrafficFilter.failed:
          if (record.statusCategory != TrafficStatusCategory.failed) return false;
          break;
      }

      // 3. تصفية بحسب نص البحث
      if (query.isNotEmpty) {
        final matchesUrl = record.url.toLowerCase().contains(query);
        final matchesMethod = record.method.toLowerCase().contains(query);
        final matchesStatus =
            record.statusCode?.toString().contains(query) ?? false;
        final matchesBody =
            (record.responseBody?.toLowerCase().contains(query) ?? false) ||
                (record.requestBody?.toLowerCase().contains(query) ?? false);
        return matchesUrl || matchesMethod || matchesStatus || matchesBody;
      }

      return true;
    }).toList();
  }

  void addRecord(TrafficRecord record) {
    if (!isRecording.value) return;
    records.insert(0, record);
  }

  void updateRecord(TrafficRecord updated) {
    final index = records.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      records[index] = updated;
    }
  }

  void clearRecords() {
    records.clear();
  }

  void toggleRecording() {
    isRecording.value = !isRecording.value;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setActiveFilter(TrafficFilter filter) {
    activeFilter.value = filter;
  }

  void setMethodFilter(String? method) {
    methodFilter.value = method;
  }

  /// تصدير سجلات الطلبات بصيغة JSON
  String exportAsJson() {
    final list = records.map((r) => {
      'id': r.id,
      'timestamp': r.timestamp.toIso8601String(),
      'method': r.method,
      'url': r.url,
      'statusCode': r.statusCode,
      'durationMs': r.durationMs,
      'requestHeaders': r.requestHeaders,
      'requestBody': r.requestBody,
      'responseHeaders': r.responseHeaders,
      'responseBody': r.responseBody,
      'error': r.error,
    }).toList();

    return const JsonEncoder.withIndent('  ').convert(list);
  }
}
