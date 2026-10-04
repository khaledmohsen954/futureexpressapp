import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeyPropertiesFile = rootProject.file("key.properties")
val releaseKeyProperties = Properties()
if (releaseKeyPropertiesFile.exists()) {
    releaseKeyPropertiesFile.inputStream().use(releaseKeyProperties::load)
}
val releaseSigningConfigured = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
).all { !releaseKeyProperties.getProperty(it).isNullOrBlank() }

android {
    namespace = "com.future.express.v3"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                storeFile = rootProject.file(releaseKeyProperties.getProperty("storeFile"))
                storePassword = releaseKeyProperties.getProperty("storePassword")
                keyAlias = releaseKeyProperties.getProperty("keyAlias")
                keyPassword = releaseKeyProperties.getProperty("keyPassword")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.future.express.v3"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (releaseSigningConfigured) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

if (!releaseSigningConfigured) {
    tasks.configureEach {
        if (name == "assembleRelease" || name == "bundleRelease") {
            doFirst {
                error(
                    "Release signing is not configured. Create android/key.properties " +
                        "from android/key.properties.example and provide your upload keystore."
                )
            }
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
