buildscript {
    repositories {
        google() // Ensure this is present
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.1")
        classpath("com.google.gms:google-services:4.4.2") // Latest stable version as of now
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}