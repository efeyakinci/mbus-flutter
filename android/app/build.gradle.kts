import java.util.Properties

val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

val keystoreProps = Properties().apply {
    val f = rootProject.file("key.properties")
    require(f.exists()) { "Missing key.properties at ${f.absolutePath}" }
    f.inputStream().use { load(it) }
}

val googlemapsApiKey: String = localProps.getProperty("googlemaps.apiKey")

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.efeakinci.mbus"
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
        applicationId = "com.efeakinci.mbus"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["googlemaps.apiKey"] = googlemapsApiKey
}

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProps.getProperty("storeFile")
                ?: error("'storeFile' is missing in key.properties")
            val storePasswordValue = keystoreProps.getProperty("storePassword")
                ?: error("'storePassword' is missing in key.properties")
            val keyAliasValue = keystoreProps.getProperty("keyAlias")
                ?: error("'keyAlias' is missing in key.properties")
            val keyPasswordValue = keystoreProps.getProperty("keyPassword")
                ?: error("'keyPassword' is missing in key.properties")

            storeFile = file(storeFilePath)
            storePassword = storePasswordValue
            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
