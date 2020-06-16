### Releasing a version: 

- Make a release branch `release/x.x.x`
- Increase version number in `android/build.gradle`, `android/gradle.properties` and `PurchasesHybridCommon.podspec`
- Update purchases-android version in `android/build.gradle`
- Update purchases-ios pod version in `PurchasesHybridCommon.podspec`, `ios/PurchasesHybridCommon/Podfile`, and `ios/PurchasesHybridCommon/PurchasdsHybridCommon.xcworkspace` (open this last one with Xcode)
- Update `CHANGELOG.md`
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
