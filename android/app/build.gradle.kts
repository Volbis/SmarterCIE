plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")

    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.smartmeter_app"
    compileSdk = 35  // Retour à API 34 pour meilleure compatibilité
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.smartmeter_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core:1.12.0")
    implementation("androidx.work:work-runtime:2.9.0")
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")

     // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

}

flutter {
    source = "../.."
}