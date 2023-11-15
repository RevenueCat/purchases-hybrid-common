# iOS

## Point to a local `Purchases` project

In `ios/PurchasesHybridCommon/Podfile` replace:

```
  pod 'RevenueCat', '4.30.5'
```

with:

```
  pod 'RevenueCat', :path => '~/Development/repos/ios/purchases-ios'
```

Remember to change `'~/Development/repos/ios/purchases-ios'` with your local purchases-ios path.

# Android

## Point to a local `Purchases` project

In the  `android` directory run:
```bash
 ./gradlew enableLocalBuild -PpurchasesPath="~/Development/repos/ios/purchases-android/"
```

Then "Sync Project with Gradle files" in Android Studio
