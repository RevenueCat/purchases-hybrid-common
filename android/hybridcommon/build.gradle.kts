@Suppress("DSL_SCOPE_VIOLATION") // TODO: Remove once KTIJ-19369 is fixed
plugins {
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.kotlinAndroid)
    alias(libs.plugins.androidJunit5)
    alias(libs.plugins.mavenPublish)
    alias(libs.plugins.detekt)
}

dependencies {
    detektPlugins(libs.detekt.formatting)
}

detekt {
    buildUponDefaultConfig = true
    baseline = file("config/detekt/detekt-baseline.xml")
}

android {
    namespace = "com.revenuecat.purchases.hybridcommon"
    compileSdk = 34

    defaultConfig {
        // TODO: revert this to 19
        minSdk = 24

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
    }
}

dependencies {
    implementation(libs.core.ktx)
    api(libs.purchases)
    api(libs.purchases.ui)
    api(libs.purchases.amazon)
    testImplementation(libs.kotlin.test)
    testImplementation(libs.junit)
    testImplementation(libs.assertj.core)
    testImplementation(libs.mockk)
    testImplementation(libs.junit.jupiter.api)
    testRuntimeOnly(libs.junit.jupiter.engine)
}

val purchasesPath: String by project // Command line argument is always a part of project

// Call passing parameter -PpurchasesPath="$HOME/Development/repos/purchases-android"
task("enableLocalBuild") {
    group = "Tools"
    description = "Enable composite build"
    doLast {
        File(".composite-enable").writeText(purchasesPath)
    }
}

task("disableLocalBuild") {
    group = "Tools"
    description = "Disable composite build"
    doLast {
        val file = File(".composite-enable")
        if (file.exists()) {
            file.delete()
        }
    }
}
