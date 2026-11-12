# iOS

Open `ios/PurchasesHybridCommon/PurchasesHybridCommon.xcworkspace`. The test targets
use the local PHC Swift package, with RevenueCat, RevenueCatUI, Quick, Nimble, and
SnapshotTesting also resolved through Swift Package Manager.
Run the `PurchasesHybridCommon` scheme for unit tests and the Objective-C API build,
or `PurchasesHybridCommonIntegrationTests` for the StoreKit integration tests.

Resolve dependencies from the repository root with:

```sh
bundle exec fastlane resolve_ios_packages
```

Quick 5.0.1 requires Nimble 9.x through SwiftPM; the test project pins Nimble 9.2.1.

## Point to a local purchases-ios checkout

In Xcode, add your purchases-ios checkout with **File > Add Package Dependencies >
Add Local** to override the remote package while developing. Remove the local
override before committing.

## CocoaPods installation validation

The `check-pods` CI job retains podspec validation and runs a minimal core/UI app
through CocoaPods. All four RevenueCat and PHC pods come from Git, so the test
does not require their specifications to be published to trunk. It checks an API
call through PHC and verifies that the resource bundles are included.

Run it from the repository root:

```sh
bundle exec fastlane ios test_cocoapods_installation
```

The test uses the current Git commit and reads native dependency versions from
the podspecs. Commit local PHC changes first. To test a commit that has not been
pushed, set `PHC_COCOAPODS_GIT_URL` to `file:///absolute/path/to/purchases-hybrid-common`.
Use `PHC_COCOAPODS_TEST_DESTINATION` to select an available simulator.

# Android

## Point to a local `Purchases` project

In the  `android` directory run:
```bash
 ./gradlew enableLocalBuild -PpurchasesPath="~/Development/repos/ios/purchases-android/"
```

Then "Sync Project with Gradle files" in Android Studio

# Typescript

## Update the Typescript API Report
In the `/typescript` directory:

```bash
yarn build && yarn extract-api
```

## TODO: before merging 21.0-dev into main

- [ ] Replace `21.0.0-SNAPSHOT` with the release version across every source in Fastlane's `files_with_version_number` and `files_with_version_number_without_prerelease_modifiers` mappings. Keep the Apple bundle short versions free of prerelease suffixes. (SDK-4600)
- [ ] Include the CocoaPods publishing removal and the Git-sourced installation coverage in the integration branch; verify the complete release workflow and core/UI smoke test. (SDK-4600)
- [ ] Keep the post-publication hybrid cleanup tracked in SDK-4608: after PHC 21 publishes, each hybrid must replace development references with released PHC 21 artifacts before its own integration PR merges.
