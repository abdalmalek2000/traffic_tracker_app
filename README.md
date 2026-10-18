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

## 🏗️ Architecture (الهيكلية المعمارية)

```
lib/
├── core/
│   ├── interceptor/       # TrafficHttpClient (BaseClient wrapper)
│   └── models/            # TrafficRecord, CapturedConnection, AppInfo
├── services/
│   ├── test_request_service.dart   # Mock and live request tester
│   ├── traffic_manager.dart        # In-App traffic state & filters
│   └── vpn_service_manager.dart    # Android Native VPN bridge (Method & Event Channels)
└── ui/
    ├── screens/
    │   ├── app_filter_screen.dart       # Target app selector
    │   ├── traffic_detail_screen.dart   # Deep request/response & cURL inspection
    │   ├── traffic_list_screen.dart     # In-App live request feed
    │   └── vpn_dashboard_screen.dart    # System-wide VPN control & PCAP exporter
    └── widgets/
        └── json_viewer.dart             # Syntax-highlighted payload viewer
```

