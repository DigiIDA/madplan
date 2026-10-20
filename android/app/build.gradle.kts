import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val ksFile = keyProps.getProperty("storeFile") ?: System.getenv("KEYSTORE_FILE")
val ksPassword = keyProps.getProperty("storePassword") ?: System.getenv("KEYSTORE_PASSWORD")
val ksAlias = keyProps.getProperty("keyAlias") ?: System.getenv("KEY_ALIAS")
val ksKeyPassword = keyProps.getProperty("keyPassword") ?: System.getenv("KEY_PASSWORD")
val hasReleaseKey = ksFile != null && rootProject.file(ksFile).exists()

android {
    namespace = "dk.digiida.madplan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "dk.digiida.madplan"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(ksFile!!)
                storePassword = ksPassword
                keyAlias = ksAlias
                keyPassword = ksKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) signingConfigs.getByName("release")
                            else signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
