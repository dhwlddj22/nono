    plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase 추가
}

android {
    namespace = "com.example.nono"
    compileSdk = 34 // Flutter Gradle에서 자동 지정하지 않는 경우, 직접 명시

    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11" // JavaVersion.VERSION_11.toString() 대신 문자열로 명시
    }

    defaultConfig {
        applicationId = "com.example.nono"
        minSdk = 23 // Flutter 기본 minSdkVersion이 21 이상인지 확인
        targetSdk = 33 // 최신 버전 사용 (Flutter 최신 버전 기준)
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug") // 만약 오류가 나면 debug 대신 release 확인
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.firebase:firebase-auth:22.1.1") // Firebase Auth 추가
    implementation("com.google.firebase:firebase-core:21.1.1") // Firebase Core 추가
}
