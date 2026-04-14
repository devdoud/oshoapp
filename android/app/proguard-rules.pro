# Flutter-specific ProGuard rules
# Preserve Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Firebase and Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep all enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Preserve Camera plugin
-keep class io.flutter.plugins.camera.** { *; }

# Preserve ML Kit
-keep class com.google.mlkit.** { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve Lottie
-keep class com.airbnb.lottie.** { *; }

# Preserve GetX
-keep class com.google.gson.** { *; }
-keep class com.google.gson.stream.** { *; }

# Preserve serializable classes
-keep class * implements java.io.Serializable { *; }

# Disable warnings
-dontwarn android.**
-dontwarn com.google.**
-dontwarn io.flutter.**

# Keep line numbers for crash reports
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

# Stripe push provisioning warnings
-dontwarn com.stripe.android.pushProvisioning.**
