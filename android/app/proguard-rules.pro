# shared_preferences_android 2.5.x calls its Kotlin API through package:jni but
# ships no consumer rules, so R8 strips/renames what Dart looks up by name and
# the app hangs on the splash screen. Keep exactly those classes.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep interface kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.** { *; }
