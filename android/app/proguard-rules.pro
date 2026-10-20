# shared_preferences_android 2.5.x calls its Kotlin API through package:jni but
# ships no consumer rules, so R8 strips/renames what Dart looks up by name and
# the app hangs on the splash screen. Keep exactly those classes.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep interface kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.** { *; }

# google_mlkit_text_recognition references the CJK/Devanagari models as
# compileOnly; we only bundle Latin, so tell R8 the others are absent on purpose.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
