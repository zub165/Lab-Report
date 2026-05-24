# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Gson (used by some plugins)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# Stripe
-keep class com.stripe.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.**
