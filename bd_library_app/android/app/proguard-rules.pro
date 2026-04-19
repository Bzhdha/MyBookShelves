# Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# App entry point
-keep class com.example.bd_library_app.** { *; }

# ML Kit (google_mlkit_text_recognition + mobile_scanner)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# google_mlkit_text_recognition: optional CJK/Devanagari models are compileOnly
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ZXing (mobile_scanner)
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**

# flutter_secure_storage (Android Keystore via reflection)
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepclassmembers class com.it_nomads.fluttersecurestorage.** { *; }

# local_auth (BiometricPrompt)
-keep class io.flutter.plugins.localauth.** { *; }
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# camera
-keep class io.flutter.plugins.camera.** { *; }
-dontwarn io.flutter.plugins.camera.**

# speech_to_text
-keep class com.csdcorp.speech_to_text.** { *; }

# share_plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Keep annotation metadata (needed by several plugins)
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses

# Keep line numbers for crash reports (pairs with --split-debug-info)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
