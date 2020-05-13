### Releasing a version: 

- Make a branch `bump/x.x.x`
- Update purchases-android version in `android/common/build.gradle`
- Update CHANGELOG.md
- Open a PR, merge and tag master.
- Compile android aar: `cd android`, `./gradlew assembleRelease`. The .aar output will be in `common/build/outputs/aar/common-release.aar`
- Create a github release, upload .aar to the release
