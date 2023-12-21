// Top-level build file where you can add configuration options common to all sub-projects/modules.
@Suppress("DSL_SCOPE_VIOLATION") // TODO: Remove once KTIJ-19369 is fixed
plugins {
    alias(libs.plugins.kotlinAndroid) apply false
    alias(libs.plugins.androidLibrary) apply false
    alias(libs.plugins.mavenPublish) apply false
    alias(libs.plugins.detekt) apply false
}

val purchasesPath: String by project // Command line argument is always a part of project

// Call passing parameter -PpurchasesPath="$HOME/Development/repos/purchases-android"
task("enableLocalBuild") {
    group = "Tools"
    description = "Enable composite build"
    doLast {
        File(".composite-enable").writeText(purchasesPath.trim())
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


true // Needed to make the Suppress annotation work for the plugins block
