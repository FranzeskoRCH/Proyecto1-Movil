pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")

// Gradle 9 refuses to configure a project whose directory is not writable.
// On NixOS the Flutter SDK (and therefore the integration_test plugin) lives in
// the read-only store, so build that plugin from a writable copy. On machines
// with a writable SDK this does nothing.
fun relocateReadOnlyPlugin(path: String) {
    val plugin = project(path)
    val source = plugin.projectDir
    if (source.canWrite()) return
    val target = rootDir.resolve(".gradle/readonly-plugins/${path.removePrefix(":")}")
    if (!target.exists()) {
        source.copyRecursively(target, overwrite = false)
    }
    plugin.projectDir = target
}

relocateReadOnlyPlugin(":integration_test")
