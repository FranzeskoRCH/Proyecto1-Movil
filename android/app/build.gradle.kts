plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.movil_proyecto"
    compileSdk = flutter.compileSdkVersion
    
    // Automatically detect the NDK version folder provided by Nix
    val androidHome = System.getenv("ANDROID_HOME")
    val nixNdkDir = if (!androidHome.isNullOrEmpty()) file("$androidHome/ndk") else null
    val nixNdkVersion = nixNdkDir?.listFiles()?.firstOrNull { it.isDirectory }?.name

    if (!nixNdkVersion.isNullOrEmpty()) {
        // Uses the exact version directory composed in the Nix store
        ndkVersion = nixNdkVersion
    } else {
        // Falls back to Flutter default on non-Nix environments
        ndkVersion = flutter.ndkVersion
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.movil_proyecto"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Firma de release: lee el keystore de las variables de entorno que
    // inyecta el workflow (.github/workflows/release.yml). Si no hay
    // keystore, cae en la debug key (el build sirve, pero no actualiza
    // instalaciones previas).
    val keystoreFile = System.getenv("ANDROID_KEYSTORE_FILE")
    signingConfigs {
        if (!keystoreFile.isNullOrEmpty()) {
            create("release") {
                storeFile = file(keystoreFile)
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
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
