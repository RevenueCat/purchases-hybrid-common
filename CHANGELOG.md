## 1.3.1

- Fix crash when Android periods come as "365"
   https://github.com/RevenueCat/purchases-hybrid-common/pull/49
- Bumped iOS to 3.5.1 ([Changelog here](https://github.com/RevenueCat/purchases-ios/releases))

## 1.3.0

- Bumped Android to 3.3.0 ([Changelog here](https://github.com/RevenueCat/purchases-android/releases))
    https://github.com/RevenueCat/purchases-hybrid-common/pull/46
- Added parsing of original_purchase_date in Android
    https://github.com/RevenueCat/purchases-hybrid-common/pull/46
- Bumped iOS to 3.5.0 ([Changelog here](https://github.com/RevenueCat/purchases-ios/releases))

## 1.2.0

- Bumped iOS to 3.4.0 ([Changelog here](https://github.com/RevenueCat/purchases-ios/releases))
  Bumped Android to 3.2.0 ([Changelog here](https://github.com/RevenueCat/purchases-android/releases))
    https://github.com/RevenueCat/purchases-hybrid-common/pull/42
- Added managementURL
    https://github.com/RevenueCat/purchases-hybrid-common/pull/41
- Adds project name; updates to android plugin 4.0.0; changes api with implementation
    https://github.com/RevenueCat/purchases-hybrid-common/pull/44
- Added setProxyURLString
    https://github.com/RevenueCat/purchases-hybrid-common/pull/43

## 1.1.2

- Added originalPurchaseDate to RCPurchaserInfo dict
    https://github.com/RevenueCat/purchases-hybrid-common/pull/36

## 1.1.1

- Adds this library to Maven
    https://github.com/RevenueCat/purchases-hybrid-common/pull/31
- Fixes discountWithIdentifier always returns null
    https://github.com/RevenueCat/purchases-hybrid-common/pull/35
- Adds configure function to Android that lets pass a PlatformInfo
    https://github.com/RevenueCat/purchases-hybrid-common/pull/32
- Adds method to pass in a suite name to revenuecat
    https://github.com/RevenueCat/purchases-hybrid-common/pull/33

## 1.1.0

-  Unified Android code into a single module
	https://github.com/RevenueCat/purchases-hybrid-common/pull/25
- Added podspec
	https://github.com/RevenueCat/purchases-hybrid-common/pull/26
- Set up Android tests using spek
	https://github.com/RevenueCat/purchases-hybrid-common/pull/27
- Moved dependency management away from git submodules and into Cocoapods
	https://github.com/RevenueCat/purchases-hybrid-common/pull/29

## 1.0.14

- New iOS headers for platformFlavor and platformFlavorVersion
    https://github.com/RevenueCat/purchases-hybrid-common/pull/23
- CircleCI tests integration
    https://github.com/RevenueCat/purchases-hybrid-common/pull/20
    https://github.com/RevenueCat/purchases-hybrid-common/pull/21
    https://github.com/RevenueCat/purchases-hybrid-common/pull/22
- Add xcproject and tests target
    https://github.com/RevenueCat/purchases-hybrid-common/pull/18

## 1.0.13

- Small refactor on how periods are converted to map on Android https://github.com/RevenueCat/purchases-hybrid-common/pull/17

## 1.0.12

- Improves Unity compatibility https://github.com/RevenueCat/purchases-hybrid-common/pull/15

## 1.0.11

- Converts all NSNull attributes to string or nil

## 1.0.10

- Fix crash when setting NSNull in setAttributes

## 1.0.9

- Added subscription offers support

## 1.0.8

- Fixes a call in Subscriber Attributes when setting a push token as string

## 1.0.7

- Adds compatibility with Subscriber Attributes and invalidate purchaser info cache.

## 1.0.6

- Updates completion block for checkTrialOrIntroductoryPriceEligibility

## 1.0.5

- Fixes issue with older versions of Kotlin
