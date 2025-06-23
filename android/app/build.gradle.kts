    plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase 추가
}

    android {
        namespace = "com.example.nono"
        compileSdk = 35
        ndkVersion = "29.0.13113456"

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
            isCoreLibraryDesugaringEnabled = true
        }


        kotlinOptions {
            jvmTarget = "11"
        }

        defaultConfig {
            applicationId = "com.example.nono"
            minSdk = 24
            targetSdk = 33
            versionCode = 1
            versionName = "1.0"
        }

        buildTypes {
            release {
                isMinifyEnabled = false
                isShrinkResources = false
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    flutter {
        source = "../.."
    }

    dependencies {
        implementation("com.google.firebase:firebase-auth:22.1.1")
        implementation("com.google.firebase:firebase-core:21.1.1")
        implementation("com.google.firebase:firebase-storage:20.3.0")

        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5") // 추가
    }

