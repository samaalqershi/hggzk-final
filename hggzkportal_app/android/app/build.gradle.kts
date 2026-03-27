import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun signingProp(name: String): String = (keystoreProperties.getProperty(name) ?: "").trim()

val releaseStoreFilePath = signingProp("storeFile")
val releaseStorePassword = signingProp("storePassword")
val releaseKeyAlias = signingProp("keyAlias")
val releaseKeyPassword = signingProp("keyPassword")

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.hggzkportal.app"
    compileSdk = 36
    ndkVersion = "29.0.13113456"
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hggzkportal.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters += listOf("arm64-v8a")
        }
        // Provide Google Maps API key via manifest placeholder (set MAPS_API_KEY in gradle.properties or CI secrets)
        manifestPlaceholders["MAPS_API_KEY"] = (project.findProperty("MAPS_API_KEY") as String?) ?: "REPLACE_WITH_YOUR_KEY"
    }

    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    signingConfigs {
        create("release") {
            if (
                keystorePropertiesFile.exists() &&
                releaseStoreFilePath.isNotEmpty() &&
                releaseStorePassword.isNotEmpty() &&
                releaseKeyAlias.isNotEmpty() &&
                releaseKeyPassword.isNotEmpty()
            ) {
                storeFile = file(releaseStoreFilePath)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            val missingConfig = mutableListOf<String>()

            if (!keystorePropertiesFile.exists()) missingConfig += "android/key.properties"
            if (releaseStoreFilePath.isEmpty()) missingConfig += "storeFile"
            if (releaseStorePassword.isEmpty()) missingConfig += "storePassword"
            if (releaseKeyAlias.isEmpty()) missingConfig += "keyAlias"
            if (releaseKeyPassword.isEmpty()) missingConfig += "keyPassword"

            if (missingConfig.isNotEmpty()) {
                throw GradleException(
                    "Release signing is not configured for hggzkportal_app. Missing: ${missingConfig.joinToString(", ")}"
                )
            }

            val releaseStoreFile = file(releaseStoreFilePath)
            if (!releaseStoreFile.exists()) {
                throw GradleException(
                    "Release keystore file not found: ${releaseStoreFile.absolutePath}"
                )
            }

            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            // Avoid stripping JNI in debug to prevent NDK dependency
            isJniDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    // Firebase Analytics (no version when using BoM)
    implementation("com.google.firebase:firebase-analytics")
    // Firebase Dynamic Links (for firebase_dynamic_links plugin)
    implementation("com.google.firebase:firebase-dynamic-links:21.2.0")
}
