### Releasing a version: 

- Update purchases-android version in `build.gradle`
- Compile android aar: `cd android`, `./gradlew assembleRelease`. The .aar output will be in `common/build/outputs/aar/common-release.aar`
- Update CHANGELOG.md
- Make a tag and push
- Create a github release
