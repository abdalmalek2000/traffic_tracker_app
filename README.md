<p align="center">
  <img src="assets/images/app_logo.png" alt="Traffic Tracker Logo" width="130" height="130" style="border-radius: 24px; box-shadow: 0 8px 24px rgba(0,0,0,0.15);" />
</p>

<h1 align="center">Traffic Tracker</h1>

<p align="center">
  <b>A High-Performance Network Traffic Inspector, Security Auditor & PCAP Capture Engine for Android & Flutter.</b>
</p>

<p align="center">
  <i>فاحص ومراقب حركة مرور الشبكة والأمان المتقدم لتطبيقات أندرويد وفلاتر بدون روت ومع تصدير PCAP مباشر لبرنامج Wireshark</i>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.12%2B-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://developer.android.com"><img src="https://img.shields.io/badge/Platform-Android_API_24%2B-3DDC84?logo=android&logoColor=white" alt="Android"></a>
  <a href="https://kotlinlang.org"><img src="https://img.shields.io/badge/Native-Kotlin_VpnService-7F52FF?logo=kotlin&logoColor=white" alt="Kotlin"></a>
  <a href="https://pub.dev/packages/get"><img src="https://img.shields.io/badge/State_Management-GetX-8A2BE2" alt="GetX"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/abdalmalek2000/traffic_tracker_app/stargazers"><img src="https://img.shields.io/github/stars/abdalmalek2000/traffic_tracker_app?style=social" alt="GitHub Stars"></a>
</p>

<p align="center">
  <b>English</b> • <a href="README.ar.md"><b>العربية</b></a>
</p>

<p align="center">
  <a href="#-about-the-project">About</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-screenshots--preview">Screenshots</a> •
  <a href="#-system-requirements">Requirements</a> •
  <a href="#-installation--setup">Installation</a> •
  <a href="#-how-to-use-usage">Usage</a> •
  <a href="#-security--privacy-architecture">Security</a> •
  <a href="#-third-party-services--attributions">Third-Party</a> •
  <a href="#-faq">FAQ</a> •
  <a href="#-license">License</a>
</p>

---

## 📑 Table of Contents

- [📌 About the Project](#-about-the-project)
  - [The Problem](#the-problem)
  - [The Solution](#the-solution)
  - [Target Audience](#target-audience)
  - [Core Value Proposition](#core-value-proposition)
- [✨ Key Features](#-key-features)
  - [1. System-Wide Packet Inspection (No Root)](#1-system-wide-packet-inspection-no-root)
  - [2. Targeted Per-App Traffic Isolation](#2-targeted-per-app-traffic-isolation)
  - [3. Deep HTTP/REST API Inspector](#3-deep-httprest-api-inspector)
  - [4. Standard PCAP Dump for Wireshark](#4-standard-pcap-dump-for-wireshark)
  - [5. Material 3 Design, Dynamic Themes & Full RTL](#5-material-3-design-dynamic-themes--full-rtl)
- [📸 Screenshots & Preview](#-screenshots--preview)
- [💻 System Requirements](#-system-requirements)
- [🚀 Installation & Setup](#-installation--setup)
  - [Prerequisites](#prerequisites)
  - [Step-by-Step Installation](#step-by-step-installation)
  - [Building for Production](#building-for-production)
  - [Common Troubleshooting](#common-troubleshooting)
- [📖 How to Use (Usage)](#-how-to-use-usage)
  - [Workflow 1: Device-Wide Network Monitoring](#workflow-1-device-wide-network-monitoring)
  - [Workflow 2: Isolating a Specific App (Target Mode)](#workflow-2-isolating-a-specific-app-target-mode)
  - [Workflow 3: Exporting & Analyzing PCAP in Wireshark](#workflow-3-exporting--analyzing-pcap-in-wireshark)
  - [Workflow 4: Testing & Inspecting Custom HTTP Requests](#workflow-4-testing--inspecting-custom-http-requests)
- [🔬 Architecture & Technical Design](#-architecture--technical-design)
  - [MVC + GetX Reactive Architecture](#mvc--getx-reactive-architecture)
  - [Native Android VpnService Pipeline](#native-android-vpnservice-pipeline)
  - [PCAP Binary Engine](#pcap-binary-engine)
- [🛡️ Security, Privacy & Permission Audit](#️-security-privacy--permission-audit)
  - [100% On-Device & Zero Telemetry Guarantee](#100-on-device--zero-telemetry-guarantee)
  - [Non-Invasive SNI Extraction (No Root CA Injection)](#non-invasive-sni-extraction-no-root-ca-injection)
  - [Android Permissions Breakdown](#android-permissions-breakdown)
  - [Vulnerability Reporting](#vulnerability-reporting)
- [🙏 Third-Party Services & Attributions](#-third-party-services--attributions)
- [👨‍💻 Developer & Credits](#-developer--credits)
- [🤝 Contributing](#-contributing)
- [❓ FAQ](#-faq)
- [📄 License](#-license)
- [📞 Support & Contact](#-support--contact)

---

## 📌 About the Project

**Traffic Tracker** is a professional-grade mobile network diagnostics, forensic packet capture, and security auditing application engineered for Android. Built with a modern **Flutter** frontend and backed by an optimized native **Kotlin `VpnService` engine**, it bridges the gap between complex command-line network tools and high-fidelity mobile user experiences.

### The Problem
Inspecting mobile application network traffic has traditionally presented severe friction:
1. **Rooting Requirement**: Traditional packet capture tools (like `tcpdump`) require rooted Android devices, which breaks enterprise apps, trips Play Integrity/SafetyNet, and introduces security hazards.
2. **SSL Pinning & Root Certificate Complexity**: Intercepting proxies (like Charles Proxy or Burp Suite) require installing custom user CA certificates, configuring Android network security configs (`res/xml/network_security_config.xml`), and bypassing certificate pinning.
3. **Traffic Noise**: Mobile devices generate hundreds of background requests simultaneously from system services, Google Play services, and background synchronization tasks, making it difficult to isolate the exact requests of a specific app under test.

### The Solution
Traffic Tracker bypasses these roadblocks by deploying Android's official virtual network interface (`android.net.VpnService`). Without rooting or injecting foreign root certificates, Traffic Tracker captures IP packets at the local network stack, inspects TLS Handshakes (`SNI`) and DNS queries in real-time, isolates single target applications, and streams transactions directly to a reactive interface and standard `.pcap` capture files.

### Target Audience
* **Mobile Developers (Flutter & Native Android)**: Validate network latency, monitor HTTP status codes, inspect real payloads, and verify caching mechanisms.
* **Cybersecurity Researchers & Penetration Testers**: Audit application endpoints, verify TLS configurations, discover undocumented domain calls, and export raw traffic for Wireshark analysis.
* **QA & Test Automation Engineers**: Replicate API edge cases, track 4xx/5xx errors, and copy instantaneous `cURL` commands for bug reports.
* **Privacy Enthusiasts**: Monitor hidden background telemetry, tracking trackers, and external socket connections initiated by third-party apps.

### Core Value Proposition
* **Zero Root Privileges Required**: Runs entirely on production, non-rooted consumer devices (API 24 to API 34+).
* **Forensic PCAP Integrity**: Captures standard binary Libpcap files immediately openable in **Wireshark**, **Zeek**, or **NetworkMiner**.
* **Zero Telemetry**: All data processing, parsing, and storage remain strictly on-device without remote analytic hooks.

---

## ✨ Key Features

### 1. 🛡️ System-Wide Packet Inspection (No Root)
* **Local Virtual TUN Interface**: Creates a local network interface (`10.0.0.2`, MTU 1500) to safely intercept raw IPv4 packets (TCP, UDP, ICMP) without modifying system partitions.
* **Transparent Packet Forwarding**: Packets are routed back to the internet with minimal latency, ensuring normal network operation while capturing traffic.
* **Real-Time SNI Discovery**: Inspects TLS Client Hello frames (`port 443`) to extract Server Name Indication (SNI) hostnames dynamically without terminating or decrypting encrypted payloads.
* **DNS Query Parsing**: Intercepts UDP port 53 packets to immediately attribute outgoing IP connections to human-readable domain names.
* **Socket Attribution**: Displays protocol type, local address/port, remote endpoint, packet size, and precise nanosecond timestamps.

### 2. 🎯 Granular Per-App Traffic Isolation
* **Target Application Mode**: Filter packet capture to one or more user-selected applications, discarding all extraneous device noise.
* **Automatic App Categorization**: Automatically groups device packages into **User Applications** and **System Applications** with quick-filter chips.
* **Live Dynamic Sync**: Add or remove target applications while the VPN is running; filter changes are applied immediately to the live stream without reconnecting.
* **Search & Bulk Selection**: Quickly search apps by display name or package ID (`com.example.app`) with one-click "Select All Visible" and "Deselect All" options.

### 3. 🔍 Deep HTTP/REST API Inspector
* **In-App HTTP Client Interception**: A custom `TrafficHttpClient` interceptor that captures in-app HTTP/HTTPS calls with request/response headers, status codes, and execution durations.
* **Instant cURL Generator**: Generates clean, ready-to-execute `cURL` commands with full headers and bodies for immediate testing in terminal, Postman, or Insomnia.
* **Interactive JSON Payload Viewer**: Formats and syntax-highlights nested JSON payloads with one-tap copy and search capabilities.
* **Interactive Sandbox & Mock Generator**: Dispatch pre-configured mock requests (`GET 200`, `POST with JSON`, `PUT`, `DELETE`, `302 Redirect`, `404 Not Found`, `500 Server Error`) or craft custom endpoints with custom HTTP methods and payloads.

### 4. 💾 Standard PCAP Dump for Wireshark
* **Libpcap Binary Writer**: Serializes captured network packets into standard `.pcap` files utilizing the canonical magic header (`0xa1b2c3d4`).
* **Flexible Storage Destinations**: Direct export files to Public Downloads, Documents, External App-Specific Storage, or any custom folder via Android Storage Access Framework (SAF).
* **One-Click Share & Export**: Easily retrieve the absolute file path or open capture files in mobile packet analyzers.

### 5. 🎨 Material 3 Design, Dynamic Themes & Full RTL
* **Material You Dynamic Color**: Integrates with Android 12+ wallpaper color extraction for an adaptive visual experience.
* **6 Curated Static Palettes**: Forest Green (Default), Crimson Red, Ocean Blue, Royal Purple, Sunset Orange, and Emerald Teal.
* **Adaptive Theme Modes**: Full support for Light, Dark, and System Default modes with WCAG-compliant contrast ratios.
* **Native Bilingual RTL / LTR Support**: Comprehensive English (US) and Arabic (العربية) localization with adaptive layouts, directional chevrons, and custom **Readex Pro** typography.
* **Android Doze & Battery Optimization Bypass**: Built-in dialog to request battery optimization whitelisting, preventing Android from pausing packet capture in long-running sessions.

---

## 📸 Screenshots & Preview

| 1. VPN Dashboard | 2. Target App Filter | 3. Live Connection Detail |
|:---:|:---:|:---:|
| <!-- Add Screenshot: VPN Dashboard --> | <!-- Add Screenshot: App Filter --> | <!-- Add Screenshot: Connection Detail --> |
| *Real-time packet monitor & status* | *Per-app granular traffic isolation* | *Deep socket & SNI inspection* |

| 4. HTTP Inspector | 5. cURL & JSON Viewer | 6. Themes & Settings |
|:---:|:---:|:---:|
| <!-- Add Screenshot: HTTP Traffic List --> | <!-- Add Screenshot: cURL & JSON Details --> | <!-- Add Screenshot: Settings & Themes --> |
| *Status codes, filters & test sandbox* | *Instant cURL export & payload viewer* | *Material You, palettes & PCAP storage* |

> [!NOTE]
> *To contribute screenshots, place your images in `assets/screenshots/` and update the table above.*

---

## 💻 System Requirements

### Runtime Requirements (End-User)
* **Operating System**: Android 7.0 (API Level 24) or higher.
* **Recommended Android Version**: Android 12+ (API 31–34) for Dynamic Color & optimal VPN performance.
* **Hardware**: ARMv7, ARM64, or x86_64 device with at least 2 GB RAM.
* **Storage**: Minimum 50 MB free space (additional storage required for long PCAP recordings).
* **Connectivity**: Active Wi-Fi or Mobile Data connection (required before initiating VPN tunnels).

### Development Requirements
* **Flutter SDK**: Version `3.12.0` or higher.
* **Dart SDK**: Version `3.0.0` or higher.
* **Java Development Kit (JDK)**: OpenJDK 17.
* **Android SDK**: `compileSdkVersion 34`, `minSdkVersion 24`, `targetSdkVersion 34`.
* **Kotlin**: Version `1.9.0` or higher.

---

## 🚀 Installation & Setup

### Prerequisites
Ensure you have the Flutter SDK installed and configured on your path. Verify your installation by running:
```bash
flutter doctor
```

### Step-by-Step Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/abdalmalek2000/traffic_tracker_app.git
   cd traffic_tracker_app
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Connect your Android device:**
   Enable **USB Debugging** on your device via Developer Options and verify the connection:
   ```bash
   flutter devices
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

### Building for Production

To build optimized release binaries:

* **Release APK:**
  ```bash
  flutter build apk --release
  ```
  *Output: `build/app/outputs/flutter-apk/app-release.apk`*

* **Google Play App Bundle (AAB):**
  ```bash
  flutter build appbundle --release
  ```
  *Output: `build/app/outputs/bundle/release/app-release.aab`*

### Common Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| `VpnService` permission dialog does not appear | Missing system dialog approval | Ensure no other 3rd-party VPN is locked in "Always-on VPN" mode under Android system settings. |
| VPN immediately disconnects upon start | No active network connection | Connect to Wi-Fi or Cellular Data before starting inspection; Android VPN requires an active default network. |
| Background packet capture stops after screen lock | Android Doze / Battery Optimization | Open **Settings > Battery Optimization** inside the app and tap "Disable Optimization". |
| Release build fails with R8 missing rules | R8 Minification warnings | Verify that [`android/app/proguard-rules.pro`](android/app/proguard-rules.pro) includes `-dontwarn com.google.android.play.core.**`. |

---

## 📖 How to Use (Usage)

### Workflow 1: Device-Wide Network Monitoring
1. Launch **Traffic Tracker** and open the **System VPN** tab.
2. Tap **"Start System Traffic Inspection"**.
3. Accept the Android system VPN connection request prompt (`Connection request`).
4. Watch real-time network packets stream into the live feed with protocol, packet size, host domain, and port attribution.
5. Tap any connection row to inspect deep socket parameters, local endpoint, and destination host.

### Workflow 2: Isolating a Specific App (Target Mode)
1. Tap the **"Target Applications"** banner or the edit icon on the VPN dashboard.
2. Search for the app you wish to test (e.g., your development app or web browser).
3. Check the application checkbox.
4. Return to the dashboard. The **Target Mode Active** banner will confirm that only packets from the selected app(s) are being captured.

### Workflow 3: Exporting & Analyzing PCAP in Wireshark
1. With the VPN active or after finishing a capture session, tap the **"Download PCAP"** action.
2. The app compiles the raw captured packets into a standard binary PCAP file and saves it to your configured destination (default: `Downloads`).
3. Connect your device to a computer via USB or share the `.pcap` file.
4. Open the file in **Wireshark** to perform in-depth protocol analysis, TLS handshake reconstruction, or bandwidth profiling.

### Workflow 4: Testing & Inspecting Custom HTTP Requests
1. Navigate to the **API Inspector** tab.
2. Tap the action button to open the **Send Test Requests** bottom sheet.
3. Choose a sample request (`GET`, `POST JSON`, `PUT`, `DELETE`) or tap **"Send Custom Request"** to input your own endpoint URL, headers, and body.
4. Tap the recorded transaction in the list to review:
   - **Overview**: Status code, latency in milliseconds, request/response payload size, and timestamps.
   - **Request**: Request headers and formatted JSON body.
   - **Response**: Response headers and parsed response body.
   - **cURL**: Complete, copyable `cURL` command formatted with escape characters ready for terminal execution.

---

## 🔬 Architecture & Technical Design

### MVC + GetX Reactive Architecture
The Flutter frontend is engineered using a clean, decoupled MVC pattern with GetX for dependency injection and state management:

```
lib/
├── constants/             # Centralized design tokens (colors, spacing, palettes, typography, icons)
├── controllers/           # Reactive business controllers (VpnController, TrafficController, SettingsController)
├── localization/          # Translations (en_us.dart, ar_sa.dart, app_translations.dart)
├── models/                # Typed data models (CapturedConnection, TrafficRecord, AppInfo)
├── services/              # Native bridges & HTTP client interceptors
└── views/                 # Presentation layer with modular widgets (<300 lines per file)
```

### Native Android VpnService Pipeline

```
┌────────────────────────────────────────────────────────┐
│               Android Application Layer                │
│                                                        │
│  [ Flutter UI: GetX Controller & Live Event Stream ]   │
└──────────────────────────▲─────────────────────────────┘
                           │ MethodChannel & EventChannel
┌──────────────────────────▼─────────────────────────────┐
│             Android Native (Kotlin Engine)             │
│                                                        │
│  MainActivity.kt                                       │
│       │                                                │
│       ├── TrafficVpnService.kt (Foreground Service)    │
│       │        │                                       │
│       │        ├── VpnForwarder.kt (Threaded TUN I/O)  │
│       │        │        │                              │
│       │        │        ├── PacketUtils.kt (Parser)    │
│       │        │        │     ├── IP Header (v4)       │
│       │        │        │     ├── TCP / UDP Ports      │
│       │        │        │     ├── DNS Query (Port 53)  │
│       │        │        │     └── TLS SNI (Port 443)   │
│       │        │        │                              │
│       │        │        └── PCAP Serialization Engine  │
│       │        │                                       │
│       │        └── NotificationManager (Live Stats)    │
└────────────────────────────────────────────────────────┘
```

### PCAP Binary Engine
Captured packets are written directly using standard 24-byte Global Libpcap Headers:
* **Magic Number**: `0xa1b2c3d4` (Standard microsecond resolution)
* **Version**: Major `2`, Minor `4`
* **Snapshot Length**: `65535` bytes
* **Link-Layer Type**: `101` (`LINKTYPE_RAW` - Raw IPv4)

Each captured frame includes a 16-byte Packet Header with seconds, microseconds, captured length, and original wire length, ensuring complete compatibility with standard packet analyzers.

---

## 🛡️ Security, Privacy & Permission Audit

### 100% On-Device & Zero Telemetry Guarantee
* **No Remote Telemetry**: Traffic Tracker does not include Google Analytics, Firebase, Sentry, Mixpanel, or any third-party tracking SDKs.
* **Local Processing**: All packet parsing, SNI extraction, and PCAP writes execute exclusively in memory on the local device.
* **Local Storage Only**: Generated `.pcap` files are stored strictly on device storage. No logs or payloads are uploaded to any external server.

### Non-Invasive SNI Extraction (No Root CA Injection)
Unlike traditional HTTP proxy tools, Traffic Tracker **does not perform Man-In-The-Middle (MITM) decryption** on external third-party traffic:
* It reads the unencrypted Server Name Indication (`SNI`) extension sent in the initial plaintext `TLS Client Hello` handshake.
* It does **not** install or require custom root certificates.
* It does **not** break or bypass TLS encryption, keeping your passwords, personal sessions, and HTTPS data secure and encrypted end-to-end.

### Android Permissions Breakdown

| Permission | Technical Justification |
|---|---|
| `android.permission.BIND_VPN_SERVICE` | Required by Android to register and instantiate the local virtual TUN network interface via `VpnService`. |
| `android.permission.INTERNET` | Required to route intercepted packets back out to the internet through the native socket forwarder and execute mock HTTP requests. |
| `android.permission.ACCESS_NETWORK_STATE` | Used to verify active Wi-Fi or cellular connectivity before starting the VPN interface to prevent broken routing states. |
| `android.permission.FOREGROUND_SERVICE` | Keeps the packet processing loop active when the user switches to other applications under test. |
| `android.permission.FOREGROUND_SERVICE_SPECIAL_USE` | Complies with Android 14 (API 34) Foreground Service type policies for specialized network diagnostic utilities. |
| `android.permission.POST_NOTIFICATIONS` | Displays the mandatory persistent notification with live packet counts and a one-tap stop button on Android 13+ (API 33). |
| `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Prompts the user to exclude the app from aggressive Android Doze battery management during packet capture sessions. |
| `android.permission.QUERY_ALL_PACKAGES` | Allows the Target Mode filter to display the names and icons of installed applications for targeted traffic filtering. |

### Vulnerability Reporting
If you identify any security vulnerability, memory leak, or permission flaw, please do **not** open a public issue. Instead, report it privately by emailing the maintainer or utilizing GitHub's **Private Vulnerability Reporting** feature via the repository's Security tab.

---

## 🙏 Third-Party Services & Attributions

We gratefully acknowledge the following third-party services, libraries, and open-source projects:

| Project / Service | Description | License / Terms | Link |
|---|---|---|---|
| **httpbin.org** | Open-source HTTP Request & Response sandbox used strictly for test mock requests in the API Inspector. | Open Source | [httpbin.org](https://httpbin.org/) |
| **HugeIcons** | Iconography used across navigation and action controls. | Free / Commercial License | [hugeicons.com](https://hugeicons.com/) |
| **Readex Pro Font** | Modern, geometric bilingual (Arabic & Latin) typography developed by Google Fonts. | SIL Open Font License 1.1 | [Google Fonts](https://fonts.google.com/specimen/Readex+Pro) |
| **GetX** | Reactive state management, routing, and dependency injection framework for Flutter. | MIT License | [pub.dev/packages/get](https://pub.dev/packages/get) |
| **shared_preferences** | Local persistent key-value storage for app settings and theme preferences. | BSD-3-Clause | [pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences) |
| **http** | Composable HTTP client for Dart used in the In-App Traffic Inspector. | BSD-3-Clause | [pub.dev/packages/http](https://pub.dev/packages/http) |

---

## 👨‍💻 Developer & Credits

Designed, architected, and developed with ❤️ by **Abdulmalek Moh**:

* **GitHub**: [@abdalmalek2000](https://github.com/abdalmalek2000)
* **Repository**: [traffic_tracker_app](https://github.com/abdalmalek2000/traffic_tracker_app)
* **Role**: Lead Software Architect & Mobile Security Developer

---

## 🤝 Contributing

Contributions to **Traffic Tracker** are welcome! To contribute:

1. **Fork the Repository** on GitHub.
2. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**:
   Follow conventional commits:
   ```bash
   git commit -m "feat: add support for IPv6 packet parsing"
   ```
4. **Ensure clean tests and static analysis**:
   ```bash
   flutter analyze
   flutter test
   ```
5. **Push to your branch**:
   ```bash
   git push origin feature/amazing-feature
   ```
6. **Open a Pull Request** describing your changes and technical motivation.

---

## ❓ FAQ

<details>
<summary><b>1. Does Traffic Tracker require Root access?</b></summary>
<br>
No. Traffic Tracker uses Android's official <code>android.net.VpnService</code> API to establish a local virtual network interface. It captures and inspects traffic completely in user space without requiring root permissions.
</details>

<details>
<summary><b>2. Can Traffic Tracker decrypt HTTPS payloads from other applications?</b></summary>
<br>
No. Traffic Tracker does not perform MITM SSL decryption on device-wide traffic. It securely extracts the Server Name Indication (SNI) from the TLS Client Hello frame and DNS records, identifying destination hosts and ports without compromising end-to-end payload encryption. Full payload inspection is available for requests made through the built-in In-App API Inspector.
</details>

<details>
<summary><b>3. How do I analyze the captured packets in Wireshark?</b></summary>
<br>
Tap "Download PCAP" on the VPN dashboard. The app serializes captured packets into a standard <code>.pcap</code> file in your configured destination folder (e.g. <code>Downloads</code>). Transfer the file to your computer and double-click to open it directly in Wireshark.
</details>

<details>
<summary><b>4. Does Traffic Tracker send my traffic to any remote servers?</b></summary>
<br>
No. Traffic Tracker operates 100% locally on your device. The VPN tunnel routes packets through a local TUN socket on <code>127.0.0.1</code> / <code>10.0.0.2</code>. No remote proxy, tracking server, or telemetry backend is used.
</details>

<details>
<summary><b>5. Why does the app request to ignore battery optimizations?</b></summary>
<br>
When monitoring network traffic for another app over an extended period, Android's aggressive Doze mode may kill background services. Whitelisting the app ensures packet capture continues smoothly without packet drops.
</details>

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2026 Abdulmalek Moh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See the full [LICENSE](LICENSE) file for details.

---

## 📞 Support & Contact

* **Issues & Bug Reports**: [GitHub Issues](https://github.com/abdalmalek2000/traffic_tracker_app/issues)
* **Feature Requests**: [GitHub Discussions](https://github.com/abdalmalek2000/traffic_tracker_app/discussions)
* **Author Profile**: [@abdalmalek2000](https://github.com/abdalmalek2000)

<p align="center">
  <b>Traffic Tracker</b> — Engineered with precision for mobile developers and security professionals.
</p>
