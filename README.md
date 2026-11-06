<p align="center">
  <img src="assets/images/app_logo.png" alt="Traffic Tracker Logo" width="130" height="130" style="border-radius: 24px; box-shadow: 0 8px 24px rgba(0,0,0,0.15);" />
</p>

<h1 align="center">Traffic Tracker</h1>

<p align="center">
  <b>A High-Performance Network Traffic Inspector, Security Auditor & PCAP Capture Engine for Android & Flutter.</b>
</p>

<!-- <p align="center">
  <i>فاحص ومراقب حركة مرور الشبكة والأمان المتقدم لتطبيقات أندرويد وفلاتر بدون روت ومع تصدير PCAP مباشر لبرنامج Wireshark</i>
</p> -->

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.12%2B-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://developer.android.com"><img src="https://img.shields.io/badge/Platform-Android_API_24%2B-3DDC84?logo=android&logoColor=white" alt="Android"></a>
  <a href="https://kotlinlang.org"><img src="https://img.shields.io/badge/Native-Kotlin_VpnService-7F52FF?logo=kotlin&logoColor=white" alt="Kotlin"></a>
  <a href="https://pub.dev/packages/get"><img src="https://img.shields.io/badge/State_Management-GetX-8A2BE2" alt="GetX"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/abdalmalek2000/traffic_tracker_app/stargazers"><img src="https://img.shields.io/github/stars/abdalmalek2000/traffic_tracker_app?style=social" alt="GitHub Stars"></a>
</p>

---

## 📌 Overview (نظرة عامة)

**Traffic Tracker** is a developer and security-focused mobile network diagnostics toolkit built with **Flutter** and powered by an **Android Native VpnService** engine (`Kotlin`). 

It provides seamless, **no-root required** packet interception, deep REST API inspection with instantaneous cURL generation, real-time SNI & DNS resolution, targeted per-app traffic isolation, and native **PCAP packet capture** ready for forensic analysis in **Wireshark**.

---

## ✨ Key Features

### 1. 🛡️ System-Wide Network Inspector
* **No Root Required**: Employs Android's native `android.net.VpnService` to capture IP packets (TCP, UDP, ICMP) on a virtual local TUN interface without modifying system partitions.
* **Domain & SNI Discovery**: Inspects TLS Client Hello (`SNI` - Server Name Indication) and DNS queries (`UDP port 53`) to identify destination hostnames and domains without breaking SSL/TLS certificates or tripping SSL Pinning guards.
* **Socket Attribution**: Identifies remote IP addresses, local & remote ports, transport protocols, connection timestamps, and transfer sizes.
* **PCAP Export for Wireshark**: Records captured raw network packets into standard `.pcap` files compatible with **Wireshark**, **Zeek**, and **NetworkMiner**.
* **Flexible Storage Selection**: Easily direct `.pcap` dump files to Public Downloads, Documents, App-specific external storage, or custom device folders.

### 2. 🎯 Granular Per-App Isolation
* **Target Mode**: Restrict network traffic capture to one or more specific installed applications (e.g., test app, browser, social media).
* **Smart App Categorization**: Filter installed applications by **User Apps** vs. **System Apps**.
* **Live Dynamic Sync**: Adding or removing target apps updates the live packet stream immediately without requiring VPN re-establishment.

### 3. 🔍 In-App HTTP / REST API Inspector
* **Real-time API Interception**: Intercepts outgoing and incoming HTTP/HTTPS transactions with latency, headers, queries, and payload metrics.
* **cURL Command Generator**: Generate and copy ready-to-execute `cURL` commands with a single tap for testing in terminal, Postman, or Burp Suite.
* **Interactive JSON Viewer**: Beautifully formats, expands, collapses, and copies JSON request/response payloads.
* **Live Test Generator**: Built-in test sandbox to fire mock requests (`GET 200`, `POST JSON`, `PUT`, `DELETE`, `302 Redirect`, `404 Not Found`, `500 Server Error`, and custom endpoints).

### 4. 🎨 Modern Material 3 & Customization
* **Material You Dynamic Color**: Seamlessly matches your Android 12+ wallpaper palette.
* **6 Custom Static Palettes**: Forest Green (Default), Crimson Red, Ocean Blue, Royal Purple, Sunset Orange, and Emerald Teal.
* **Light / Dark / System Themes**: Flawless contrast across all modes with zero text or container clipping.
* **Bilingual Localization (EN / AR)**: Fully translated Arabic (العربية) and English (US) interfaces with customized **Readex Pro** typography and native RTL layout support.
* **Battery Optimization Management**: One-tap whitelist access to prevent Android Doze from killing long-running packet capture sessions.

---

## 🏛️ Architecture & Clean Design

The project adheres to a clean **MVC (Model-View-Controller)** pattern combined with **GetX** for reactive state handling and a dedicated native bridge:

```
lib/
├── constants/                     # Design tokens & app constants
│   ├── api_endpoints.dart         # Mock testing endpoints
│   ├── app_palettes.dart          # 6 curated theme palettes & dynamic color config
│   ├── colors.dart                # Semantic color definitions
│   ├── icons.dart                 # HugeIcons & Cupertino mapping
│   ├── spacing.dart               # Spacing, padding, and border radii
│   └── typography.dart            # Readex Pro text styles & scales
├── controllers/                   # GetX Controllers (State & Logic)
│   ├── navigation_controller.dart # Main bottom bar navigation
│   ├── settings_controller.dart   # Theme, language, PCAP & battery state
│   ├── traffic_controller.dart    # In-app HTTP inspector controller
│   └── vpn_controller.dart        # Native VPN lifecycle, packets, & app selection
├── localization/                  # Internationalization
│   └── app_translations.dart      # English & Arabic strings with RTL support
├── models/                        # Data Entities
│   ├── app_info.dart              # Installed package representation (UID, name, icon)
│   ├── captured_connection.dart   # Captured network packet / connection model
│   └── traffic_record.dart        # In-app HTTP transaction entity & cURL builder
├── services/                      # Services & Platform Bridges
│   ├── battery_optimization_service.dart # Android Doze whitelist manager
│   ├── system_theme_service.dart  # Native system color hooks
│   ├── test_request_service.dart  # Sandbox mock request runner
│   ├── traffic_client.dart        # HTTP client interceptor
│   └── vpn_native_bridge.dart     # MethodChannel & EventChannel interface
├── theme/                         # Theme setup
│   └── app_theme.dart             # Material 3 ColorScheme & ThemeData builders
└── views/                         # UI Screens & Widgets
    ├── main_navigation_view.dart  # Scaffold with adaptive bottom navigation
    ├── settings/                  # Settings screens & bottom sheets
    ├── traffic/                   # HTTP Inspector views & details
    ├── vpn/                       # VPN Dashboard, live feed & app filter
    └── widgets/                   # Reusable components (e.g., JsonViewer)
```

### 🌉 Native Bridge Architecture

```
┌─────────────────────────────────┐
│     Flutter UI (Dart / GetX)    │
└────────────────┬────────────────┘
                 │ MethodChannel ('vpn_control')
                 │ EventChannel  ('vpn_traffic_stream')
┌────────────────▼────────────────┐
│   MainActivity.kt (Kotlin)      │
└────────────────┬────────────────┘
                 │
┌────────────────▼────────────────┐
│ TrafficVpnService.kt (Android)  │
│  ├── VpnForwarder.kt            │  <── Reads from TUN interface
│  ├── PacketUtils.kt             │  <── Parses IP, TCP, UDP, DNS & TLS SNI
│  └── PCAP Writer Engine         │  <── Serializes raw packets to .pcap
└─────────────────────────────────┘
```

---

## 🚀 Getting Started

### 📋 Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.12.0` or later)
* Android SDK (`compileSdk 34`, `minSdk 24`)
* Physical Android Device (recommended for VPN features) or Emulator

### 🛠️ Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/abdalmalek2000/traffic_tracker_app.git
   cd traffic_tracker_app
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter setup:**
   ```bash
   flutter doctor
   ```

4. **Run the app on your Android device:**
   ```bash
   flutter run
   ```

---

## 🔒 Android Permissions (أذونات أندرويد المطلوبة)

To enable packet interception and application listing without root privileges, the following permissions are declared in `AndroidManifest.xml`:

| Permission | Reason |
|---|---|
| `BIND_VPN_SERVICE` | Required to initialize the Android local VPN tunnel interface |
| `INTERNET` | Required for forwarding network packets and executing test requests |
| `ACCESS_NETWORK_STATE` | Detects active network status (Wi-Fi / Mobile Data) before starting |
| `FOREGROUND_SERVICE` | Keeps the packet capture service running reliably in the background |
| `QUERY_ALL_PACKAGES` | Allows listing installed apps for per-app targeted traffic filtering |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Whitelists the app to prevent OS sleep/killing during deep packet capture |

---

## 🔬 How It Works Under The Hood (آلية العمل التقنية)

1. **Local TUN Interface**: When VPN inspection starts, `TrafficVpnService` establishes a virtual network interface (TUN) using Android's `VpnService.Builder`.
2. **Transparent Forwarding**: Captured IPv4 packets are parsed by `PacketUtils.kt`. Non-intercepted traffic is transparently routed back to the internet, keeping network connectivity smooth and uninterrupted.
3. **SNI Extraction**: For HTTPS connections (TCP port 443), the native parser analyzes the TLS Handshake `Client Hello` frame to pull the server hostname from the SNI extension without terminating the TLS session or requiring a custom CA root certificate.
4. **PCAP Serialization**: Raw bytes of each packet are appended to a standard Libpcap binary format (`magic: 0xa1b2c3d4`), making files immediately openable in **Wireshark**.
5. **Reactive Event Stream**: Metadata is pushed over an `EventChannel` to `VpnController`, providing 60 FPS real-time UI updates with minimal memory overhead.

---

## 🛡️ Security & Privacy

* **100% Local & Offline**: All packet inspection, parsing, and PCAP writes take place strictly on the user's device.
* **Zero Telemetry**: No user data, connection logs, or analytics are sent to any remote server.
* **No Root Required**: Operates strictly within standard Android system security boundaries.

---

## 👨‍💻 Author

Developed with ❤️ by **Abdulmalek Moh**:
* **GitHub**: [@abdalmalek2000](https://github.com/abdalmalek2000)
* **Project Repository**: [traffic_tracker_app](https://github.com/abdalmalek2000/traffic_tracker_app)

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.
