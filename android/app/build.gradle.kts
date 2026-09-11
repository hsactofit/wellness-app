plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val releaseStoreFilePath = providers.environmentVariable("WELLNESS_ANDROID_KEYSTORE_FILE").orNull
val releaseStorePassword = providers.environmentVariable("WELLNESS_ANDROID_KEYSTORE_PASSWORD").orNull
val releaseKeyAlias = providers.environmentVariable("WELLNESS_ANDROID_KEY_ALIAS").orNull
val releaseKeyPassword = providers.environmentVariable("WELLNESS_ANDROID_KEY_PASSWORD").orNull
val hasReleaseSigning = listOf(
    releaseStoreFilePath,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }

android {
    namespace = "com.actofit.arhamsecure"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.actofit.arhamsecure"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "Medifit Wellness"
        manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
    }

    flavorDimensions += "brand"
    productFlavors {
        create("medifit") {
            dimension = "brand"
            applicationId = "com.actofit.arhamsecure"
            manifestPlaceholders["appLabel"] = "Medifit Wellness"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        }
        create("mednovations") {
            dimension = "brand"
            applicationId = "com.mednovations.wellness"
            manifestPlaceholders["appLabel"] = "Mednovations Wellness"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_mednovations"
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFilePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // The local build helper supplies these values from macOS Keychain.
            // Retain debug signing only for a developer's local release test.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
