import org.jetbrains.compose.desktop.application.dsl.TargetFormat
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidApplication)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
    id("io.sentry.android.gradle") version "5.12.1"
}

kotlin {
    androidTarget {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }

    sourceSets {
        androidMain.dependencies {
            implementation(compose.preview)
            implementation(libs.androidx.activity.compose)
            implementation("io.insert-koin:koin-core:3.5.6")
            implementation("com.github.bumptech.glide:glide:4.16.0")
        }
        commonMain.dependencies {
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)
            implementation(compose.ui)
            implementation(compose.components.resources)
            implementation(compose.components.uiToolingPreview)
            implementation(libs.androidx.lifecycle.viewmodelCompose)
            implementation(libs.androidx.lifecycle.runtimeCompose)
            implementation(projects.shared)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
}

android {
    namespace = "com.movieskmp.compose.movieskmpcompose"
    compileSdk = libs.versions.android.compileSdk.get().toInt()

    defaultConfig {
        applicationId = "com.movieskmp.compose.movieskmpcompose"
        minSdk = libs.versions.android.minSdk.get().toInt()
        targetSdk = libs.versions.android.targetSdk.get().toInt()
        versionCode = 1
        versionName = "1.0"
    }
    packaging {
        resources {
            excludes += setOf(
                "/META-INF/{AL2.0,LGPL2.1}",
                "META-INF/LICENSE*",
                "META-INF/NOTICE*",
                "META-INF/native-image/io.sentry/sentry/native-image.properties"
            )
        }
    }
    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false   // ❌ Disable shrinking for debug builds
            isShrinkResources = false // ❌ Don’t remove unused resources
        }
        getByName("release") {
            isMinifyEnabled = true    // ✅ Enable shrinking, obfuscation, and optimization
            isShrinkResources = true  // ✅ Also shrink unused resources (optional)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    debugImplementation(compose.uiTooling)
}

sentry {
    // Auto-Install Sentry dependencies
    autoInstallation {
        enabled = false
    }

    //Read from the environment variable
    val token = System.getenv("SENTRY_AUTH_TOKEN") ?: ""
    //⚠️ NOTE you need to save it in the environment variable for example: in PowerSheell - setx SENTRY_AUTH_TOKEN "paste_your_token"
    if (token.isNotBlank())
    {
        // The slug of the Sentry organization to use for uploading proguard mappings/source contexts.
        org.set("freelance-6m")
        projectName.set("kotlin-bestapp")
        authToken.set(token)

        debug = false
        includeSourceContext = true
    }
    else
    {
        println("⚠️ SENTRY_AUTH_TOKEN is not set — skipping Sentry upload configuration.")
    }
}