### Releasing a version: 

- Start a git-flow release/x.y.z
- Create a CHANGELOG.latest.md with the changes for the current version (to be used by Fastlane for the github release notes)
- Run `fastlane bump_and_update_changelog version:X.Y.Z` (where X.Y.Z is the new version) to update the version number in `android/build.gradle`, `android/gradle.properties` and `PurchasesHybridCommon.podspec`
- Update purchases-android version in `android/build.gradle`
- Update purchases-ios pod version in `PurchasesHybridCommon.podspec` and `ios/PurchasesHybridCommon/Podfile`.
- Open a PR, merge and tag master.
- run `carthage build --archive --platform iOS`
- Upload to the new release PurchasesHybridCommon.framework.zip
- Create a github release
- Release Android:
  1. Visit [Sonatype Nexus](https://oss.sonatype.org/)
  1. Click on Staging Repositories on the left side
  1. Scroll down to find the purchase repository
  1. Select and click "Close" from the top menu. Why is it called close?
  1. Once close is complete, repeat but this time selecting "Release"
- run `pod trunk push PurchasesHybridCommon.podspec`
