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
- [ ] Remove the temporary `android-deploy-snapshot` workflow job. (SDK-4600)
- [ ] Include the CocoaPods publishing removal and the Git-sourced installation coverage in the integration branch; verify the complete release workflow and core/UI smoke test. (SDK-4600)
- [ ] Keep the post-publication hybrid cleanup tracked in SDK-4608: after PHC 21 publishes, each hybrid must replace development references with released PHC 21 artifacts and remove temporary Maven snapshot repositories before its own integration PR merges.
