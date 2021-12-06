## 1.11.1

- Adds compatibility for `ownershipType` for Android
    https://github.com/RevenueCat/purchases-hybrid-common/pull/103
- Bump purchases-android to 4.6.0. [Changelog here](https://github.com/RevenueCat/purchases-android/releases/tag/4.6.0)
- Bump purchases-ios to 3.13.1. [Changelog here](https://github.com/RevenueCat/purchases-ios/releases/tag/3.13.1)

## 1.11.0

Add ownershipType to EntitlementInfo
	- https://github.com/RevenueCat/purchases-hybrid-common/pull/101

## 1.10.1

- Bump `purchases-android` to `4.5.0` ([Changelog here](https://github.com/RevenueCat/purchases-android/releases/4.5.0))

### 1.10.0

- Bump `purchases-ios` to `3.13.0` ([Changelog here](https://github.com/RevenueCat/purchases-ios/releases/3.13.0))
- Bump `purchases-android` to `4.4.0` ([Changelog here](https://github.com/RevenueCat/purchases-android/releases/4.4.0))
- Added support for Airship integration via `setAirshipChannelID`
     https://github.com/RevenueCat/purchases-hybrid-common/pull/96

### 1.9.3

- Bump `purchases-ios` to `3.12.8`
    [3.12.7 Changelog here](https://github.com/RevenueCat/purchases-ios/releases/tag/3.12.7)
    [3.12.8 Changelog here](https://github.com/RevenueCat/purchases-ios/releases/tag/3.12.8)

### 1.9.2

- Bump `purchases-android` to `4.3.3`
    [4.3.3 Changelog here](https://github.com/RevenueCat/purchases-android/releases/tag/4.3.3)
    [4.3.2 Changelog here](https://github.com/RevenueCat/purchases-android/releases/tag/4.3.2)
- Bump `purchases-ios` to `3.12.6`
    [3.12.6 Changelog here](https://github.com/RevenueCat/purchases-ios/releases/tag/3.12.6)
    [3.12.5 Changelog here](https://github.com/RevenueCat/purchases-ios/releases/tag/3.12.5)
    [3.12.4 Changelog here](https://github.com/RevenueCat/purchases-ios/releases/tag/3.12.4)

### 1.9.1

- Fix issue with `productIdentifier` being a list in the `purchaseProduct` and `purchasePackage` functions
    https://github.com/RevenueCat/purchases-hybrid-common/pull/90
- Updated `purchases-android` to 4.3.1
    https://github.com/RevenueCat/purchases-android/releases/tag/4.3.1

### 1.9.0

- Adds `getPaymentDiscount` in Android, which returns an error
    https://github.com/RevenueCat/purchases-hybrid-common/pull/88

### 1.8.2

- Bumps `purchases-ios` to `3.12.3` ([Changelog here](https://github.com/RevenueCat/purchases-ios/releases/3.12.3))
     https://github.com/RevenueCat/purchases-hybrid-common/pull/87

### 1.8.1

- Fixed a bug where the wrong error code would be returned when mapping to JSON in Android
    https://github.com/RevenueCat/purchases-hybrid-common/pull/85

### 1.8.0

#### Identity V3

##### New methods
- Introduces `logIn`, a new way of identifying users, which also returns whether a new user has been registered in the system. 
`logIn` uses a new backend endpoint. 
- Introduces `logOut`, a replacement for `reset`. 

##### Deprecations
- deprecates `createAlias` in favor of `logIn`
- deprecates `identify` in favor of `logIn`
- deprecates `reset` in favor of `logOut`
- deprecates `allowSharingStoreAccount` in favor of dashboard-side configuration

#### Dependency updates
- Bumps `purchases-ios` to `3.12.2` ([Changelog here](https://github.com/RevenueCat/purchases-ios/releases/3.12.2))
- Bumps `purchases-android` to `4.3.0` ([Changelog here](https://github.com/RevenueCat/purchases-android/releases/4.3.0))
    https://github.com/RevenueCat/purchases-hybrid-common/pull/84

#### Bug Fixes
- Added `readableErrorCode` to `UserInfo` when creating `ErrorContainer`, so all errors have `readableErrorCode`
    https://github.com/RevenueCat/purchases-hybrid-common/pull/82
- Made `underlyingErrorMessage` an empty string if it's missing in iOS
    https://github.com/RevenueCat/purchases-hybrid-common/pull/71

### 1.7.1

- Fixed dependency specificiation in Podspec to purchases-ios@3.11.1
    https://github.com/RevenueCat/purchases-hybrid-common/pull/81

### 1.7.0

- Adds a new method, `canMakePayments`, that provides a way to check if the current user is allowed to make purchases on the device. 
    https://github.com/RevenueCat/purchases-hybrid-common/pull/77
- Fixes a crash when calling `syncPurchases` with no completion block on iOS
    https://github.com/RevenueCat/purchases-hybrid-common/pull/78
- Bumps `purchases-android` to `4.2.1` ([Changelog here](https://github.com/RevenueCat/purchases-android/releases/4.2.1))
    https://github.com/RevenueCat/purchases-hybrid-common/pull/77

### 1.6.3

- Bumps `purchases-ios` to `3.11.1` ([Changelog here](https://github.com/RevenueCat/purchases-ios/releases/3.11.1))
     https://github.com/RevenueCat/purchases-hybrid-common/pull/76

### 1.6.2

- Bumps `purchases-ios` to `3.10.7` ([Changelog here](https://github.com/RevenueCat/purchases-ios/releases/3.10.7))
- Bumps `purchases-android` to `4.0.5` ([Changelog here](https://github.com/RevenueCat/purchases-android/releases/4.0.5))
    https://github.com/RevenueCat/purchases-hybrid-common/pull/69

### 1.6.1

- Adds missing availability check for `simulatesAskToBuyInSandbox`
    https://github.com/RevenueCat/purchases-hybrid-common/pull/66

### 1.6.0

- [iOS] Adds a new property `simulateAsksToBuyInSandbox`, that allows developers to test deferred purchases easily.
- Bumps `purchases-ios` to `3.10.6`
- Bumps `purchases-android` to `4.0.4`
    https://github.com/RevenueCat/purchases-hybrid-common/pull/65

### 1.5.1

- Fixes a bug where times in millis were actually returned in seconds in Android
    https://github.com/RevenueCat/purchases-hybrid-common/pull/63

### 1.5.0

- Bumps `purchases-ios` to 3.9.2, `purchases-android` to 4.0.1
    https://github.com/RevenueCat/purchases-hybrid-common/pull/61
- Adds `syncPurchases` for iOS
- Adds `presentCodeRedemptionSheet` for iOS
- Fixes a bug where times in millis were actually returned in seconds
    https://github.com/RevenueCat/purchases-hybrid-common/pull/62
- Fixes build warnings
    https://github.com/RevenueCat/purchases-hybrid-common/pull/60

### 1.4.5

- Bumps iOS to 3.7.5, makes cocoapods compile statically, adds dummy Swift file
    https://github.com/RevenueCat/purchases-hybrid-common/pull/58

### 1.4.4

- Updates Android to 3.5.2
    https://github.com/RevenueCat/purchases-hybrid-common/pull/57

### 1.4.3

- Fixes build issues in some hybrid SDKs by compiling pods statically
    https://github.com/RevenueCat/purchases-hybrid-common/pull/56

### 1.4.2

- Fixes a typo in the `Transaction` mapper in Android.
    https://github.com/RevenueCat/purchases-hybrid-common/pull/55

### 1.4.1

- Fixes an issue where `setFBAnonymousID` would set the `appsflyerID` instead. 
- Cleans up deprecations
    https://github.com/RevenueCat/purchases-hybrid-common/pull/53/
- updated Xcode version to use in CI to 12.0
- updated bundler and fastlane
    https://github.com/RevenueCat/purchases-hybrid-common/pull/54


## 1.4.0

- Adds nonSubscriptionPurchases to RCPurchaserInfo
- Adds attribution v2
- Updates iOS to 3.7.1
- Updates Android to 3.5.0
  https://github.com/RevenueCat/purchases-hybrid-common/pull/51


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
