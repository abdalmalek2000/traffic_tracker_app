# Traffic Tracker App 🛡️📡

A powerful, cross-platform Network Traffic Inspector & Security Auditor built with **Flutter** and **Android Native VpnService**.

---

## 🌟 Features (الميزات الرئيسية)

### 1. In-App HTTP Inspector (فاحص طلبات الـ HTTP الداخلي)
- **Real-time API Interception**: Intercepts, inspects, and logs all network requests and responses within the application.
- **Deep Inspection**: View URLs, HTTP Methods (GET, POST, PUT, DELETE, PATCH), Headers, Query Parameters, and Response bodies.
- **cURL Generator**: Copy any intercepted request as a ready-to-run cURL command with a single tap.
- **JSON Formatting**: Automatically parses and prettifies response payloads for clean readability.
- **Filtering & Search**: Filter by status codes (2xx, 3xx, 4xx, 5xx) and search URLs, paths, or payload content.
- **Built-in Test Generator**: Trigger live sample requests (GET, POST JSON, 404, 500, Custom) to test traffic monitoring instantly.

### 2. System-Wide Network Inspector via Android VpnService (مراقب شبكة الجهاز الشامل)
- **No-Root Required**: Leverages `android.net.VpnService` to capture network traffic across all installed Android applications.
- **Domain & SNI Discovery**: Inspects DNS queries (UDP 53) and TLS Client Hello (SNI) on HTTPS connections to identify destinations without breaking SSL/TLS certificates or triggering SSL Pinning errors.
- **PCAP Packet Logging**: Captures raw packets into standard `.pcap` files, ready for deep forensic analysis in **Wireshark**.
- **Per-App Filtering**: Monitor all apps by default, or select specific target apps by name and icon.

---

## 🏗️ Architecture (معمارية MVC النظيفة)

The project follows a clean, easy-to-understand **MVC (Model-View-Controller)** pattern with **GetX** for high-performance reactive state management and navigation:

```
lib/
├── controllers/                   # (Controllers) إدارة الحالة والتفاعل
│   ├── navigation_controller.dart # متحكم شريط التنقل السفلي
│   ├── traffic_controller.dart    # متحكم فحص طلبات الـ HTTP والـ API
│   └── vpn_controller.dart        # متحكم مراقبة شبكة الجهاز والـ VPN
├── models/                        # (Models) نماذج البيانات
│   ├── app_info.dart              # نموذج بيانات التطبيقات المثبتة
│   ├── captured_connection.dart   # نموذج الاتصالات والحزم الملتقطة
│   └── traffic_record.dart        # نموذج معاملات الـ HTTP والـ cURL
├── services/                      # (Services) خدمات الاتصال بالشبكة وأندرويد
│   ├── test_request_service.dart  # مولد طلبات الاختبار
│   ├── traffic_client.dart        # عميل اعتراض طلبات الـ HTTP
│   └── vpn_native_bridge.dart     # جسر التواصل مع كود أندرويد الأصيل
├── views/                         # (Views) واجهات المستخدم
│   ├── main_navigation_view.dart  # الواجهة الحاوية للتنقل
│   ├── traffic/                   # واجهات فحص الـ API
│   │   ├── traffic_list_view.dart
│   │   └── traffic_detail_view.dart
│   ├── vpn/                       # واجهات مراقبة الـ VPN
│   │   ├── vpn_dashboard_view.dart
│   │   └── app_filter_view.dart
│   └── widgets/                   # مكونات قابلة لإعادة الاستخدام
│       └── json_viewer_widget.dart
└── main.dart                      # نقطة البداية وتهيئة GetMaterialApp
```

