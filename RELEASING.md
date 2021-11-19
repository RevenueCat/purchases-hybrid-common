### Releasing a version: 

- Start a git-flow release/x.y.z
- Create a CHANGELOG.latest.md with the changes for the current version (to be used by Fastlane for the github release notes)
- Run `bundle exec fastlane bump_and_update_changelog version:X.Y.Z` (where X.Y.Z is the new version) to update the version number in `android/build.gradle`, `android/gradle.properties` and `PurchasesHybridCommon.podspec`
- Update purchases-android version in `android/build.gradle`
- Update purchases-ios pod version in `PurchasesHybridCommon.podspec` and `ios/PurchasesHybridCommon/Podfile`.
- run `pod lib lint` to ensure that no problems are found with the pod. 
- Open a PR, merge and tag main.
- run `./carthage.sh build --archive --platform iOS`
- Upload to the new release PurchasesHybridCommon.framework.zip
- Create a github release
- run `pod trunk push PurchasesHybridCommon.podspec`
