pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "purchases-hybrid-common"
include(":api-tests")
include(":hybridcommon")
include(":hybridcommon-ui")

// Galaxy only publishes bc8. Avoid configuring it when publishing legacy bc7 artifacts.
if (settings.extra.properties["ANDROID_VARIANT_TO_PUBLISH"] != "bc7Release") {
    include(":hybridcommon-store-galaxy")
}

// Run enableLocalBuild task to enable building purchases-android from your local copy
if (file(".composite-enable").exists()) {
    val path = file(".composite-enable").readText().trim()
    includeBuild(path)
}
