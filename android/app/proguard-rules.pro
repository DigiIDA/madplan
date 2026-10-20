# shared_preferences_android 2.5.x calls its Kotlin API through JNI but ships
# no consumer rules, so R8 strips/renames it and the app hangs on the splash.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep interface kotlin.coroutines.Continuation { *; }
