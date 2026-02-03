plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.instantDriver"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "26.3.11579264"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // Corrected for Kotlin DSL
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.instantDriver"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

//    buildTypes {
//        release {
//            // TODO: Add your own signing config for the release build.
//            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }


    signingConfigs {
        create("release") {
            storeFile = file("c:\\Users\\a2z\\Downloads\\soheb-Globally\\INSTANT\\delivery-app-rider-side\\InstantDriver.jks")
            storePassword = "123456"
            keyAlias = "InstantDriver"
            keyPassword = "123456"
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false // Enable minification
            isShrinkResources = false // Enable resource shrinking
//            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }

}

flutter {
    source = "../.."
}



dependencies {
    implementation(kotlin("stdlib")) // Optional: Ensure Kotlin stdlib is included
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // Corrected dependency syntax
}
