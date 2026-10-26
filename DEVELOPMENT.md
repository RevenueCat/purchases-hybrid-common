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

## Validate CocoaPods compatibility

```sh
bundle exec fastlane ios pod_lint
```

This checks both PHC podspecs using a temporary checkout of the exact native SDK
tag pinned in the podspecs. It does not require that native version on CocoaPods
trunk. The podspecs remain part of each release for CocoaPods publishing.

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
