### Releasing a version: 

- Start a branch release/x.y.z
- Create a CHANGELOG.latest.md with the changes for the current version (to be used by Fastlane for the github release notes)
- Run `bundle exec fastlane bump_and_update_changelog version:X.Y.Z` (where X.Y.Z is the new version) to update the version number in `android/build.gradle`, `android/gradle.properties` and `PurchasesHybridCommon.podspec`
- Update purchases-android version in `android/build.gradle`
- Update purchases-ios pod version in `PurchasesHybridCommon.podspec` and `ios/PurchasesHybridCommon/Podfile`.
- Open a PR, merge and tag main.
- Android and iOS will start deploying automatically and a new github release will be created.
