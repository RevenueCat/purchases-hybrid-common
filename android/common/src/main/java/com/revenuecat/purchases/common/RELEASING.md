### Releasing a version: 

- Update purchases-android version in `build.gradle`
- Update CHANGELOG.md
- Make a tag and push
- Compile android aar: `cd android`, `./gradlew assembleRelease`. The .aar output will be in `common/build/outputs/aar/common-release.aar`
- Create a github release, upload .aar to the release
