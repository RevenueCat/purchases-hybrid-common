This release adopts purchases-android 11.0.0 and drops deprecated paywall presentation overloads on iOS. Hybrid SDKs picking it up need the native floors below and the iOS delegate signature change.

### Android
- Depends on purchases-android 11.0.0. `compileSdk` is 36 on every module; Kotlin 2.2.21 (AGP 8.13.2, minSdk unchanged).

### iOS
- `PaywallProxy` no longer calls `paywallViewController:didFinishPurchasingWithCustomerInfoDictionary:transactionDictionary:` for purchases without a `StoreTransaction` (purchases made through the app's own purchase logic). This matches Android.
- `PaywallViewControllerDelegateWrapper`'s `transactionDictionary` parameter is now non-optional. Implementers declaring `[String: Any]?` get an optionality warning until they drop the `?`.
- Removed the deprecated `presentPaywall(offering:)` overloads. Use `presentPaywall(options:)` or `presentPaywall(offeringIdentifier:...)`.
- Purchasing a package now reports the real error when offerings fail to load (for example a network error) instead of `productNotAvailableForPurchaseError`.
- Not published to CocoaPods: trunk is read-only until after Nov 7, so 20.0.0 is available on iOS through Swift Package Manager only until then.

### TypeScript
- `PurchasesEntitlementInfo.periodType` is typed as `PeriodType` (`"NORMAL" | "INTRO" | "TRIAL" | "PREPAID"`) instead of `string`.

## RevenueCat SDK
### 💥 Breaking Changes
* Report the real error when offerings fail to load during a package purchase (#2013) via Álvaro Brey (@AlvaroBrey)
* Remove deprecated presentPaywall(offering:) overloads (#2012) via Álvaro Brey (@AlvaroBrey)
* [EXTERNAL] Type PurchasesEntitlementInfo.periodType as PeriodType (#1895) via @okcoker (#1919) via Álvaro Brey (@AlvaroBrey)
* build: update Kotlin to 2.2.20 and purchases to 11-snapshot (#1844) via Álvaro Brey (@AlvaroBrey)

## RevenueCatUI SDK
### 💥 Breaking Changes
* Stop calling onPurchaseCompleted on iOS for purchases without a transaction (#1979) via Álvaro Brey (@AlvaroBrey)

### 🔄 Other Changes
* Run iOS CI and native dependency updates through SPM (#2034) via Antonio Pallares (@ajpallares)
* Pause publishing to CocoaPods for 20.0.0 (#2031) via Álvaro Brey (@AlvaroBrey)
* Publish Android 20.0.0-SNAPSHOT from 20.0-dev (#2000) via Álvaro Brey (@AlvaroBrey)
