plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Apply plugin here
}

android {
    compileSdkVersion =33

    defaultConfig {
        applicationId = "com.geex.hectoclash"
        minSdkVersion = 19
        targetSdkVersion = 33
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-database")
}