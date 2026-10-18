import 'package:get/get.dart';

/// Centralized localization for the application.
/// Allows adding additional languages (e.g., Arabic, French) effortlessly.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
      };

  static const Map<String, String> enUS = {
    // Navigation
    'app_title': 'Traffic Tracker',
    'tab_api_inspector': 'API Inspector',
    'tab_system_vpn': 'System VPN',

    // In-App HTTP Inspector
    'network_inspector': 'Network Inspector',
    'monitoring_active': 'Inspection Active',
    'monitoring_paused': 'Inspection Paused',
    'clear_records': 'Clear Records',
    'records_cleared': 'All records cleared',
    'search_hint_http': 'Search URL, status, or payload...',
    'filter_all': 'All',
    'filter_2xx': '2xx Success',
    'filter_3xx': '3xx Redirect',
    'filter_4xx': '4xx Client Error',
    'filter_5xx': '5xx Server Error',
    'no_records_title': 'No Network Requests Yet',
    'no_records_desc':
        'Any outgoing network request will appear here in real-time with headers, status, and payload details.',
    'test_request_btn': 'Send Test Request',
    'test_requests_title': 'Send Test Requests',
    'test_requests_subtitle':
        'Choose a sample request to test live inspection in real-time:',
    'send_custom_request': 'Send Custom Request',
    'url_label': 'URL',
    'method_label': 'Method',
    'body_label': 'Request Body (JSON / Text)',
    'cancel': 'Cancel',
    'send_and_inspect': 'Send & Inspect',

    // HTTP Request Details
    'overview': 'Overview',
    'request': 'Request',
    'response': 'Response',
    'curl': 'cURL',
    'full_url': 'Full URL',
    'host': 'Host',
    'path': 'Path',
    'status': 'Status',
    'duration': 'Duration',
    'req_size': 'Request Size',
    'res_size': 'Response Size',
    'timestamp': 'Timestamp',
    'query_params': 'Query Parameters',
    'req_headers': 'Request Headers',
    'res_headers': 'Response Headers',
    'no_headers': 'No Headers',
    'empty_body': 'Empty Body',
    'copied_to_clipboard': 'Copied to clipboard',
    'copy_curl': 'Copy Full cURL Command',
    'curl_instruction':
        'Ready-to-run cURL command for testing in terminal or importing into security tools (Postman, Burp, etc.):',

    // System VPN Monitor
    'system_vpn_title': 'System Traffic Monitor',
    'vpn_active': 'Inspection Active (VPN Running)',
    'vpn_stopped': 'Inspection Stopped',
    'all_apps': 'All Apps',
    'target_apps_selected': '@count Apps Selected',
    'packets_captured': 'Packets',
    'data_volume': 'Data Volume',
    'live_connections': 'Connections',
    'start_inspection': 'Start System Traffic Inspection',
    'stop_inspection': 'Stop Inspection',
    'search_vpn_hint': 'Search domain, IP, app name, or port...',
    'mode_target_only': 'Target Apps Only',
    'mode_all_traffic': 'All Apps Traffic',
    'target_mode_active_banner':
        'Target Mode Active: Inspecting only traffic from @count selected app(s).',
    'live_feed': 'LIVE',
    'pcap_export_title': 'PCAP Capture File',
    'pcap_export_desc':
        'All captured raw network packets are recorded into a standard PCAP file for Wireshark inspection:',
    'copy_file_path': 'Copy File Path',
    'close': 'Close',
    'no_connections_active':
        'Inspection is active! Open any app on your device to see network packets appear live here.',
    'no_connections_idle':
        'Tap "Start System Traffic Inspection" above to begin capturing IP, TLS, and DNS packets across apps.',
    'no_connections_search': 'No connections matched your search "@query".',

    // App Selection & Filter
    'select_target_apps': 'Target Applications',
    'filter_all_apps': 'All',
    'filter_selected_only': 'Selected Only',
    'filter_user_apps': 'User Apps',
    'filter_system_apps': 'System Apps',
    'search_apps_hint': 'Search by app name or package...',
    'search_selected_hint': 'Search inside selected apps only...',
    'select_all_visible': 'Select All Visible (@count)',
    'deselect_all_visible': 'Deselect Visible',
    'deselect_all_menu': 'Deselect All Applications',
    'mode_monitoring_all': 'Mode: Capturing traffic from all device apps',
    'mode_monitoring_selected':
        'Mode: Restricting capture to @count selected app(s)',
    'system_badge': 'System',
    'no_apps_found': 'No applications match your search.',
    'no_selected_apps':
        'No apps selected yet.\nSwitch to "All" tab to select the applications you want to inspect.',
    'live_sync_notice':
        'Inspection Active: Selection changes are applied immediately to the live packet stream.',
    'loading_apps': 'Scanning and loading installed applications...',

    // Connection Details
    'connection_details': 'Connection Details',
    'destination_host': 'Destination Host',
    'application': 'Application',
    'package_name': 'Package Name',
    'remote_address': 'Remote Endpoint',
    'local_address': 'Local Endpoint',
    'service_type': 'Service / Port',
    'packet_length': 'Packet Size',
    'protocol': 'Protocol',
    'copy_ip': 'Copy IP',
    'copy_domain': 'Copy Domain',
  };
}
