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
    baseline = file("config/detekt/detekt-baseline.xml")
    autoCorrect = true
}

android {
    namespace = "com.revenuecat.purchases.hybridcommon.ui"
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
        minSdk = 24

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
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
    implementation(libs.fragment.ktx)
    implementation(project(":hybridcommon"))
    "bc8Api"(libs.purchases.bc8)
    "bc8Api"(libs.purchases.ui.bc8)
    "bc7Api"(libs.purchases.bc7)
    "bc7Api"(libs.purchases.ui.bc7)
    testImplementation(libs.junit)
}
