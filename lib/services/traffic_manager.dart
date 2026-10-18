import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/models/traffic_record.dart';

enum TrafficFilter {
  all,
  success,
  redirect,
  clientError,
  serverError,
  failed,
}

class TrafficManager extends ChangeNotifier {
  TrafficManager._internal();
  static final TrafficManager instance = TrafficManager._internal();

  final List<TrafficRecord> _records = [];
  bool _isRecording = true;
  String _searchQuery = '';
  TrafficFilter _activeFilter = TrafficFilter.all;
  String? _methodFilter; // e.g. 'GET', 'POST', null for all

  bool get isRecording => _isRecording;
  String get searchQuery => _searchQuery;
  TrafficFilter get activeFilter => _activeFilter;
  String? get methodFilter => _methodFilter;

  List<TrafficRecord> get allRecords => List.unmodifiable(_records);

  /// Filtered records based on active filter, method filter, and search query.
  List<TrafficRecord> get filteredRecords {
    return _records.where((record) {
      // 1. Method filter
      if (_methodFilter != null &&
          record.method.toUpperCase() != _methodFilter!.toUpperCase()) {
        return false;
      }

      // 2. Status category filter
      switch (_activeFilter) {
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

      // 3. Search query (URL, host, path, status, body)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesUrl = record.url.toLowerCase().contains(query);
        final matchesMethod = record.method.toLowerCase().contains(query);
        final matchesStatus = record.statusCode?.toString().contains(query) ?? false;
        final matchesBody = (record.responseBody?.toLowerCase().contains(query) ?? false) ||
            (record.requestBody?.toLowerCase().contains(query) ?? false);
        return matchesUrl || matchesMethod || matchesStatus || matchesBody;
      }

      return true;
    }).toList();
  }

  void addRecord(TrafficRecord record) {
    if (!_isRecording) return;
    _records.insert(0, record); // Most recent first
    notifyListeners();
  }

  void updateRecord(TrafficRecord updated) {
    final index = _records.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _records[index] = updated;
      notifyListeners();
    }
  }

  void clearRecords() {
    _records.clear();
    notifyListeners();
  }

  void toggleRecording() {
    _isRecording = !_isRecording;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveFilter(TrafficFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setMethodFilter(String? method) {
    _methodFilter = method;
    notifyListeners();
  }

  /// Exports current records as JSON string for archiving/exporting.
  String exportAsJson() {
    final list = _records.map((r) => {
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
