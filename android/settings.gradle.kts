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

// Run enableLocalBuild task to enable building purchases-android from your local copy
if (file(".composite-enable").exists()) {
    val path = file(".composite-enable").readText().trim()
    includeBuild(path)
}
