fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### bump

```sh
[bundle exec] fastlane bump
```

Bump version, edit changelog, and create pull request

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

### update_native_dependencies_to_latest

```sh
[bundle exec] fastlane update_native_dependencies_to_latest
```

Update dependencies to latest GitHub releases

### run_pod_install

```sh
[bundle exec] fastlane run_pod_install
```

Run pod install

----


## iOS

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

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Upload and close a release

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
