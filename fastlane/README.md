fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### bump_and_update_changelog

```sh
[bundle exec] fastlane bump_and_update_changelog
```

Increment build number and update changelog

### github_release_current

```sh
[bundle exec] fastlane github_release_current
```

Make GitHub release for current version

### github_release

```sh
[bundle exec] fastlane github_release
```

Make GitHub release for specific version

### open_pr_upgrading_dependencies

```sh
[bundle exec] fastlane open_pr_upgrading_dependencies
```

Update dependencies to latest GitHub releases and opens a PR

### update_native_dependencies_to_latest

```sh
[bundle exec] fastlane update_native_dependencies_to_latest
```

Update dependencies to latest GitHub releases

### update_ios_native_versions

```sh
[bundle exec] fastlane update_ios_native_versions
```

Update purchases-ios dependency version

### update_android_native_versions

```sh
[bundle exec] fastlane update_android_native_versions
```

Update purchases-android dependency version

### run_pod_install

```sh
[bundle exec] fastlane run_pod_install
```

Run pod install

----


## iOS

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Increment build number

### ios release

```sh
[bundle exec] fastlane ios release
```

Release to CocoaPods, create Carthage archive, and create GitHub release

### ios replace_api_key_integration_tests

```sh
[bundle exec] fastlane ios replace_api_key_integration_tests
```

replace API KEY for integration tests

----


## Android

### android bump

```sh
[bundle exec] fastlane android bump
```

Increment build number

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Upload and close a release

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
