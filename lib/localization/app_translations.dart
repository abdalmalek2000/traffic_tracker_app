import 'package:get/get.dart';

/// Centralized localization for the application.
/// Allows adding additional languages (e.g., Arabic, French) effortlessly.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'ar_SA': arAR,
    'ar': arAR,
  };

  static const Map<String, String> enUS = {
    // Navigation
    'app_title': 'Traffic Tracker',
    'tab_api_inspector': 'API Inspector',
    'tab_system_vpn': 'System VPN',

    // In-App HTTP Inspector
    'traffic_tracker': 'Traffic Tracker',
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
    'test_get_title': 'GET Request (200 OK)',
    'test_post_title': 'POST Request with JSON (200 OK)',
    'test_put_title': 'PUT Request (200 OK)',
    'test_delete_title': 'DELETE Request (200 OK)',
    'test_redirect_title': 'Redirect Request (302 Found)',
    'test_404_title': 'Client Error (404 Not Found)',
    'test_500_title': 'Server Error (500 Error)',
    'send_custom_request': 'Send Custom Request',
    'url_label': 'URL',
    'method_label': 'Method',
    'body_label': 'Request Body (JSON / Text)',
    'follow_redirects': 'Follow Redirects',
    'follow_redirects_desc': 'Disable to inspect 3xx redirect status code directly',
    'cancel': 'Cancel',
    'send_and_inspect': 'Send & Inspect',
    'sending': 'Sending...',


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
    'download_pcap': 'Download PCAP',
    'delete_records': 'Delete Records',
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

    // Network Connection Requirement
    'no_internet_title': 'No Network Connection',
    'no_internet_message':
        'Please connect to Wi-Fi or turn on Mobile Data before starting VPN inspection.',

    // Settings
    'settings_title': 'Settings',
    'general_section': 'General Preferences',
    'app_preferences_section': 'Application Preferences',
    'about_section': 'Application Info',
    'language_option': 'Language',
    'language_subtitle': 'Choose application display language',
    'theme_option': 'Appearance & Theme',
    'theme_subtitle': 'Switch between light, dark or system theme',
    'color_scheme_option': 'App Color & Theme Scheme',
    'color_scheme_subtitle': 'Choose between system dynamic color or static palettes',
    'select_color_scheme': 'Select Color Scheme',
    'color_dynamic_system': 'Material You (System Dynamic)',
    'color_dynamic_system_desc': 'Match wallpaper and system theme colors (Android 12+)',
    'static_colors_heading': 'Static Color Palettes',
    'palette_forest_green': 'Forest Green (Default)',
    'palette_crimson_red': 'Crimson Red',
    'palette_ocean_blue': 'Ocean Blue',
    'palette_royal_purple': 'Royal Purple',
    'palette_sunset_orange': 'Sunset Orange',
    'palette_emerald_teal': 'Emerald Teal',
    'battery_optimization_option': 'Battery Optimization',
    'battery_optimization_subtitle':
        'Disable optimization to allow unrestricted background inspection',
    'battery_optimization_active': 'Battery optimization active (restricted)',
    'battery_optimization_ignored': 'Battery optimization ignored (unrestricted)',
    'pcap_location_option': 'PCAP Save Location',
    'pcap_location_subtitle': 'Choose destination folder for captured network traffic',
    'select_pcap_location': 'Select PCAP Save Location',
    'pcap_dir_downloads': 'Downloads Folder',
    'pcap_dir_downloads_desc': 'Default public folder, visible in Files & Downloads app',
    'pcap_dir_documents': 'Documents Folder',
    'pcap_dir_documents_desc': 'Public Documents folder on your device',
    'pcap_dir_app_storage': 'App Storage Folder',
    'pcap_dir_app_storage_desc': 'Dedicated external storage for Traffic Tracker',
    'pcap_dir_custom': 'Custom Folder...',
    'pcap_dir_custom_desc': 'Choose any folder or SD card on device',
    'pcap_saved_success': 'PCAP file saved successfully to @location',
    'pcap_no_data': 'No capture packets recorded yet to save',
    'about_option': 'About App',
    'about_subtitle': 'Application version, details & info',
    'select_language': 'Select Language',
    'select_theme': 'Select Theme Mode',
    'theme_system': 'System Default',
    'theme_light': 'Light Mode',
    'theme_dark': 'Dark Mode',
    'lang_arabic': 'العربية (Arabic)',
    'lang_english': 'English (US)',
    'about_app_title': 'About Traffic Tracker',
    'app_version': 'Version 1.0.0',
    'app_description':
        'A high-performance real-time network and HTTP traffic inspection app, designed by Abdulmalek Moh.',
    'features_heading': 'Key Capabilities',
    'feature_in_app_inspection':
        'In-App HTTP/HTTPS inspection with cURL export & payload viewer',
    'feature_vpn_capture':
        'Device-wide packet monitoring with real-time socket detection',
    'feature_app_filtering': 'Targeted application filtering & isolation',
    'feature_pcap_export':
        'Raw PCAP file capture for Wireshark & security analysis',
  };



  /*
  ##################################################

  ===================== Arabic =====================

  ##################################################
   */

  static const Map<String, String> arAR = {
    // Navigation
    'app_title': 'راصد حركة الشبكة',
    'tab_api_inspector': 'فاحص الـ API',
    'tab_system_vpn': 'مراقب شبكة الجهاز',

    // In-App HTTP Inspector
    'traffic_tracker': 'راصد الشبكة',
    'network_inspector': 'فاحص حركة الشبكة',
    'monitoring_active': 'المراقبة نشطة',
    'monitoring_paused': 'المراقبة متوقفة',
    'clear_records': 'مسح السجلات',
    'records_cleared': 'تم مسح جميع السجلات بنجاح',
    'search_hint_http': 'ابحث عن رابط أو كود حالة...',
    'filter_all': 'الكل',
    'filter_2xx': '2xx ناجح',
    'filter_3xx': '3xx تحويل',
    'filter_4xx': '4xx خطأ عميل',
    'filter_5xx': '5xx خطأ خادم',
    'no_records_title': 'لا توجد طلبات شبكة بعد',
    'no_records_desc':
        'أي طلب شبكة صادر سيظهر هنا فوراً مع تفاصيل الترويسة والبيانات.',
    'test_request_btn': 'إرسال طلب تجريبي',
    'test_requests_title': 'إرسال طلبات تجريبية',
    'test_requests_subtitle': 'اختر طلباً نموذجياً لاختبار الفحص المباشر:',
    'test_get_title': 'طلب GET (رمز 200 ناجح)',
    'test_post_title': 'طلب POST مع بيانات JSON (رمز 200)',
    'test_put_title': 'طلب PUT لتحديث البيانات (رمز 200)',
    'test_delete_title': 'طلب DELETE لحذف مورد (رمز 200)',
    'test_redirect_title': 'طلب تحويل (رمز 302 إعادة توجيه)',
    'test_404_title': 'خطأ عميل (رمز 404 غير موجود)',
    'test_500_title': 'خطأ خادم (رمز 500 خطأ داخلي)',
    'send_custom_request': 'إرسال طلب مخصص',
    'url_label': 'الرابط (URL)',
    'method_label': 'نوع الطلب',
    'body_label': 'محتوى الطلب (JSON / نص)',
    'follow_redirects': 'متابعة إعادة التوجيه تلقائياً',
    'follow_redirects_desc': 'عطّل الخيار لفحص رمز استجابة التحويل 3xx مباشرة',
    'cancel': 'إلغاء',
    'send_and_inspect': 'إرسال وفحص',
    'sending': 'يرسل...',

    // HTTP Request Details
    'overview': 'نظرة عامة',
    'request': 'الطلب',
    'response': 'الاستجابة',
    'curl': 'cURL',
    'full_url': 'الرابط الكامل',
    'host': 'المضيف',
    'path': 'المسار',
    'status': 'الحالة',
    'duration': 'المدة',
    'req_size': 'حجم الطلب',
    'res_size': 'حجم الاستجابة',
    'timestamp': 'الوقت',
    'query_params': 'معاملات الاستعلام',
    'req_headers': 'ترويسات الطلب',
    'res_headers': 'ترويسات الاستجابة',
    'no_headers': 'لا توجد ترويسات',
    'empty_body': 'المحتوى فارغ',
    'copied_to_clipboard': 'تم النسخ إلى الحافظة',
    'copy_curl': 'نسخ أمر cURL بالكامل',
    'curl_instruction':
        'أمر cURL جاهز للتشغيل في الطرفية أو الاستيراد في أدوات مثل Postman:',

    // System VPN Monitor
    'system_vpn_title': 'مراقب شبكة الجهاز',
    'vpn_active': 'الفحص نشط (VPN يعمل)',
    'vpn_stopped': 'الفحص متوقف',
    'all_apps': 'كافة التطبيقات',
    'target_apps_selected': 'تم تحديد @count تطبيقات',
    'packets_captured': 'الحزم',
    'data_volume': 'حجم البيانات',
    'live_connections': 'الاتصالات',
    'start_inspection': 'بدء فحص ومراقبة شبكة الجهاز',
    'stop_inspection': 'إيقاف الفحص',
    'search_vpn_hint': 'ابحث بالنطاق أو IP أو التطبيق أو المنفذ...',
    'mode_target_only': 'تطبيقات محددة فقط',
    'mode_all_traffic': 'حركة مرور كافة التطبيقات',
    'target_mode_active_banner':
        'وضع التحديد نشط: يتم فحص حركة المرور لـ @count تطبيق محدد فقط.',
    'live_feed': 'مباشر',
    'download_pcap': 'تحميل PCAP',
    'delete_records': 'حذف السجلات',
    'pcap_export_title': 'ملف التقاط PCAP',
    'pcap_export_desc':
        'يتم تسجيل جميع حزم الشبكة الخام في ملف PCAP قياسي لتحليلها ببرنامج Wireshark:',
    'copy_file_path': 'نسخ مسار الملف',
    'close': 'إغلاق',
    'no_connections_active':
        'المراقبة نشطة! افتح أي تطبيق في جهازك لتبدأ حزم الشبكة بالظهور مباشرة هنا.',
    'no_connections_idle':
        'اضغط على "بدء فحص ومراقبة شبكة الجهاز" أعلاه للبدء بالتقاط حزم IP و TLS و DNS.',
    'no_connections_search': 'لا توجد اتصالات مطابقة لبحثك "@query".',

    // App Selection & Filter
    'select_target_apps': 'التطبيقات المستهدفة',
    'filter_all_apps': 'الكل',
    'filter_selected_only': 'المحددة فقط',
    'filter_user_apps': 'تطبيقات المستخدم',
    'filter_system_apps': 'تطبيقات النظام',
    'search_apps_hint': 'ابحث باسم التطبيق أو الحزمة...',
    'search_selected_hint': 'ابحث داخل التطبيقات المحددة فقط...',
    'select_all_visible': 'تحديد كافة الظاهرة (@count)',
    'deselect_all_visible': 'إلغاء تحديد الظاهرة',
    'deselect_all_menu': 'إلغاء تحديد كافة التطبيقات',
    'mode_monitoring_all': 'الوضع: التقاط حركة المرور من جميع تطبيقات الجهاز',
    'mode_monitoring_selected': 'الوضع: حصر الالتقاط على @count تطبيق محدد فقط',
    'system_badge': 'نظام',
    'no_apps_found': 'لا توجد تطبيقات مطابقة لبحثك.',
    'no_selected_apps':
        'لم يتم تحديد أي تطبيق بعد.\nانتقل إلى تبويب "الكل" لاختيار التطبيقات المراد فحصها.',
    'live_sync_notice':
        'المراقبة نشطة: تنطبق التغييرات في الاختيار فوراً على تيار الحزم المباشر.',
    'loading_apps': 'جاري فحص وتحميل تطبيقات الجهاز المكتشفة...',

    // Connection Details
    'connection_details': 'تفاصيل الاتصال',
    'destination_host': 'المضيف الوجهة',
    'application': 'التطبيق',
    'package_name': 'اسم الحزمة',
    'remote_address': 'الطرف البعيد',
    'local_address': 'الطرف المحلي',
    'service_type': 'الخدمة / المنفذ',
    'packet_length': 'حجم الحزمة',
    'protocol': 'البروتوكول',
    'copy_ip': 'نسخ الـ IP',
    'copy_domain': 'نسخ النطاق',

    // Network Connection Requirement
    'no_internet_title': 'لا يوجد اتصال بالشبكة',
    'no_internet_message':
        'يرجى التأكد من الاتصال بشبكة Wi-Fi أو تشغيل بيانات الهاتف قبل تفعيل مراقبة الشبكة.',

    // Settings
    'settings_title': 'الإعدادات',
    'general_section': 'التفضيلات العامة',
    'app_preferences_section': 'تفضيلات التطبيق',
    'about_section': 'معلومات التطبيق',
    'language_option': 'اللغة',
    'language_subtitle': 'تحديد لغة واجهة التطبيق',
    'theme_option': 'المظهر والثيم',
    'theme_subtitle': 'التبديل بين الوضع الفاتح، الداكن، أو حسب النظام',
    'color_scheme_option': 'ألوان التطبيق والسمة',
    'color_scheme_subtitle': 'الاختيار بين ألوان النظام الديناميكية أو الألوان الثابتة',
    'select_color_scheme': 'اختيار السمة اللونية',
    'color_dynamic_system': 'ألوان النظام الديناميكية (Material You)',
    'color_dynamic_system_desc': 'استخراج الألوان تلقائياً من خلفية وثيم جهازك (Android 12+)',
    'static_colors_heading': 'الألوان الثابتة',
    'palette_forest_green': 'الأخضر الغابي (الافتراضي)',
    'palette_crimson_red': 'الأحمر القرمزي',
    'palette_ocean_blue': 'الأزرق المحيطي',
    'palette_royal_purple': 'البنفسجي الملكي',
    'palette_sunset_orange': 'البرتقالي الدافئ',
    'palette_emerald_teal': 'الزمردي (Teal)',
    'battery_optimization_option': 'تحسين استهلاك البطارية',
    'battery_optimization_subtitle':
        'إيقاف التحسين للسماح للتطبيق بالعمل في الخلفية دون قيود',
    'battery_optimization_active': 'تحسين البطارية مفعل (مقيد)',
    'battery_optimization_ignored': 'تم تجاوز تحسين البطارية (غير مقيد)',
    'pcap_location_option': 'مكان حفظ ملفات PCAP',
    'pcap_location_subtitle': 'تحديد مجلد تنزيل ملفات التقاط حزم الشبكة',
    'select_pcap_location': 'اختيار مكان حفظ ملفات PCAP',
    'pcap_dir_downloads': 'مجلد التنزيلات (Downloads)',
    'pcap_dir_downloads_desc': 'المجلد الافتراضي، يظهر مباشرة في تطبيق الملفات والتنزيلات',
    'pcap_dir_documents': 'مجلد المستندات (Documents)',
    'pcap_dir_documents_desc': 'مجلد المستندات العام في ذاكرة الجهاز',
    'pcap_dir_app_storage': 'مجلد التطبيق (App Storage)',
    'pcap_dir_app_storage_desc': 'مجلد التخزين الخارجي الخاص بالتطبيق',
    'pcap_dir_custom': 'مجلد مخصص...',
    'pcap_dir_custom_desc': 'تحديد أي مجلد على ذاكرة الهاتف أو كارت الذاكرة',
    'pcap_saved_success': 'تم حفظ ملف PCAP بنجاح في @location',
    'pcap_no_data': 'لا توجد حزم ملتقطة بعد لحفظها',
    'about_option': 'حول التطبيق',
    'about_subtitle': 'إصدار التطبيق ومعلومات المطور والمميزات',
    'select_language': 'اختيار اللغة',
    'select_theme': 'اختيار المظهر',
    'theme_system': 'تلقائي (حسب النظام)',
    'theme_light': 'الوضع الفاتح',
    'theme_dark': 'الوضع الداكن',
    'lang_arabic': 'العربية (Arabic)',
    'lang_english': 'الإنجليزية (English)',
    'about_app_title': 'حول راصد حركة الشبكة',
    'app_version': 'الإصدار 1.0.0',
    'app_description':
        'تطبيق متقدم وعالي الأداء لمراقبة وفحص حركة مرور الشبكة وحزم البيانات لحظياً، تم تصميمه بواسطة عبدالملك محمد',
    'features_heading': 'أهم المميزات والقدرات',
    'feature_in_app_inspection':
        'فحص طلبات HTTP/HTTPS الصادرة مع تصدير cURL وعارض حمولة البيانات',
    'feature_vpn_capture':
        'مراقبة حزم كافة تطبيقات الجهاز مع كشف المقابس الحية',
    'feature_app_filtering': 'حصر الفحص والالتقاط على تطبيقات محددة بدقة',
    'feature_pcap_export':
        'تصدير حزم الشبكة الخام بصيغة PCAP للتحليل عبر Wireshark',
  };
}
