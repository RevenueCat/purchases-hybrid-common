@Suppress("DSL_SCOPE_VIOLATION") // TODO: Remove once KTIJ-19369 is fixed
plugins {
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.kotlinAndroid)
    alias(libs.plugins.mavenPublish)
    alias(libs.plugins.detekt)
}

dependencies {
    detektPlugins(libs.detekt.formatting)
}

detekt {
    buildUponDefaultConfig = true
    autoCorrect = true
}

android {
    namespace = "com.revenuecat.purchases.hybridcommon.galaxy"
    compileSdk = 34

    flavorDimensions += "billingclient"

    productFlavors {
        create("bc8") {
            dimension = "billingclient"
            isDefault = true
        }
        create("bc7") {
            dimension = "billingclient"
        }
    }

    defaultConfig {
        minSdk = 23

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
        languageVersion = libs.versions.kotlinLanguage.get()
        apiVersion = libs.versions.kotlinLanguage.get()
    }
}

dependencies {
    api(project(":hybridcommon"))
    "bc8Api"(libs.purchases.galaxy.bc8)
    "bc7Api"(libs.purchases.galaxy.bc7)
}
