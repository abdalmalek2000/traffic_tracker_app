# Flutter Wrapper & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Deferred Components (suppress Play Core warnings when not using deferred components)
-dontwarn com.google.android.play.core.**

# Keep application native classes, VPN service, and JNI/platform channel bridges
-keep class com.am.traffic_tracker_app.** { *; }
-keepclassmembers class com.am.traffic_tracker_app.** { *; }
