## 8.0.0
### Breaking Changes
* Fix entitlement verification name typo (#574) via Toni Rico (@tonidero)
### Bugfixes
* Fix breaking change in objc in 7.4.0 (#572) via Toni Rico (@tonidero)
### Dependency Updates
* [AUTOMATIC] Android 7.2.3 => 7.2.4 (#573) via RevenueCat Git Bot (@RCGitBot)

## 7.4.0
### New Features
* `Trusted Entitlements`: Add `verification` field to EntitlementInfo and EntitlementInfos (#569) via Toni Rico (@tonidero)
* `Trusted Entitlements`: add support for setting `VerificationMode` (#451) via NachoSoto (@NachoSoto)
### Dependency Updates
* Bump fastlane from 2.216.0 to 2.217.0 (#566) via dependabot[bot] (@dependabot[bot])
* Bump danger from 9.3.2 to 9.4.0 (#565) via dependabot[bot] (@dependabot[bot])

## 7.3.3
### Dependency Updates
* [AUTOMATIC] iOS 4.30.4 => 4.30.5 (#562) via RevenueCat Git Bot (@RCGitBot)
* [AUTOMATIC] Android 7.2.2 => 7.2.3 (#560) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Improve circleci deploy automation (#559) via Toni Rico (@tonidero)
* Fix deploy android circleci job (#558) via Toni Rico (@tonidero)

## 7.3.2
### Dependency Updates
* [AUTOMATIC] Android 7.2.1 => 7.2.2 (#556) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* `Android`: bump gradle version (#552) via NachoSoto (@NachoSoto)

## 7.3.1
### Dependency Updates
* [AUTOMATIC] iOS 4.30.2 => 4.30.4 Android 7.2.0 => 7.2.1 (#550) via RevenueCat Git Bot (@RCGitBot)

## 7.3.0
### Dependency Updates
* [AUTOMATIC] iOS 4.29.0 => 4.30.2 Android 7.0.1 => 7.2.0 (#546) via RevenueCat Git Bot (@RCGitBot)
* Bump fastlane-plugin-revenuecat_internal from `a297205` to `0ddee10` (#541) via dependabot[bot] (@dependabot[bot])

## 7.2.0
### Dependency Updates
* [AUTOMATIC] iOS 4.28.1 => 4.29.0 (#539) via RevenueCat Git Bot (@RCGitBot)
* Bump cocoapods from 1.14.0 to 1.14.2 (#537) via dependabot[bot] (@dependabot[bot])
### Other Changes
* Use RevenueCat orb for bundle install cache (#536) via Josh Holtz (@joshdholtz)

## 7.1.1
### Dependency Updates
* [AUTOMATIC] iOS 4.28.0 => 4.28.1 (#532) via RevenueCat Git Bot (@RCGitBot)
* Bump cocoapods from 1.13.0 to 1.14.0 (#533) via dependabot[bot] (@dependabot[bot])

## 7.1.0
### New Features
* Add `product_plan_identifier` to `EntitlementInfo` in iOS (#528) via Toni Rico (@tonidero)
### Dependency Updates
* [AUTOMATIC] iOS 4.27.2 => 4.28.0 Android 7.0.0 => 7.0.1 (#526) via RevenueCat Git Bot (@RCGitBot)
* [AUTOMATIC] iOS 4.27.0 => 4.27.2 (#524) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Improve breaking changes changelog for 7.0 (#523) via Toni Rico (@tonidero)

## 7.0.0
### Breaking Changes
* Add in app messages API support (#510) via Toni Rico (@tonidero)
  * This may cause in-app billing messages to start showing automatically in Android (this was already the behavior in iOS). To disable this behavior, change the `shouldShowInAppMessagesAutomatically` property during SDK configuration
* Temporarily remode DEFERRED proration mode in preparation for upgrade to Billing Client 6 (#506) via Mark Villacampa (@MarkVillacampa)
  * If you use DEFERRED proration mode, you should not upgrade to this version of the SDK yet, you should wait until support is re-added in a future version.
* Update android to 7.0 (#520) via Toni Rico (@tonidero)
  * This new version of the Android SDK uses Google's Billing Client 6. In case you're using observer mode and are using BC6, you need to upgrade to this version of the SDK.
  * This version moves our minSdk in android from API 14 to 19.
### Dependency Updates
* [AUTOMATIC] iOS 4.26.1 => 4.27.0 (#519) via RevenueCat Git Bot (@RCGitBot)
* Bump cocoapods from 1.12.1 to 1.13.0 (#505) via dependabot[bot] (@dependabot[bot])
* Bump fastlane from 2.215.1 to 2.216.0 (#503) via dependabot[bot] (@dependabot[bot])
* Bump danger from 9.3.1 to 9.3.2 (#502) via dependabot[bot] (@dependabot[bot])
### Other Changes
* `CI`: run iOS 17 tests (#521) via NachoSoto (@NachoSoto)
* URL(string:): add clarifying comment (#511) via Andy Boedo (@aboedo)
* Add documentation for productType field in StoreProduct in typescript (#515) via Toni Rico (@tonidero)

## 6.3.0
### New Features
* Add product type to typescript types (#507) via Cesar de la Vega (@vegaro)
### Bugfixes
* Add `product_plan_identifier` to `EntitlementInfo` model (#512) via Toni Rico (@tonidero)
### Dependency Updates
* [AUTOMATIC] iOS 4.26.0 => 4.26.1 Android 6.9.4 => 6.9.5 (#504) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* fix proxyURL not crashing if invalid url is passed (#508) via Andy Boedo (@aboedo)

## 6.2.0
### Dependency Updates
* Bump fastlane from 2.214.0 to 2.215.1 (#500) via dependabot[bot] (@dependabot[bot])
* [AUTOMATIC] iOS 4.25.10 => 4.26.0 (#498) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Trigger automatic PHC updates in Capacitor plugin (#497) via Toni Rico (@tonidero)

## 6.1.3
### Dependency Updates
* [AUTOMATIC] iOS 4.25.9 => 4.25.10 (#495) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Support deploying separate ESNext typescript package (#494) via Toni Rico (@tonidero)

## 6.1.2
### Dependency Updates
* [AUTOMATIC] iOS 4.25.8 => 4.25.9 (#492) via RevenueCat Git Bot (@RCGitBot)

## 6.1.1
### Dependency Updates
* [AUTOMATIC] iOS 4.25.7 => 4.25.8 Android 6.9.3 => 6.9.4 (#489) via RevenueCat Git Bot (@RCGitBot)

## 6.1.0
### New Features
* Expose `CommonFunctionality.encode(customerInfo:)` (#487) via NachoSoto (@NachoSoto)

## 6.0.0
### Breaking Changes
* Changed iOS `HybridAdditions` to `internal` (#485) via NachoSoto (@NachoSoto)
### Dependency Updates
* Bump fastlane-plugin-revenuecat_internal from `b2108fb` to `a297205` (#483) via dependabot[bot] (@dependabot[bot])
## 5.6.4
### Dependency Updates
* [AUTOMATIC] iOS 4.25.6 => 4.25.7 Android 6.9.2 => 6.9.3 (#481) via RevenueCat Git Bot (@RCGitBot)
* Bump activesupport from 7.0.4.3 to 7.0.7.2 (#479) via dependabot[bot] (@dependabot[bot])

## 5.6.3
### Dependency Updates
* [AUTOMATIC] Android 6.9.1 => 6.9.2 (#477) via RevenueCat Git Bot (@RCGitBot)

## 5.6.2
### Dependency Updates
* [AUTOMATIC] iOS 4.25.4 => 4.25.6 (#475) via RevenueCat Git Bot (@RCGitBot)

## 5.6.1
### Dependency Updates
* [AUTOMATIC] iOS 4.25.2 => 4.25.4 Android 6.9.0 => 6.9.1 (#473) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* re-enable job to update PHC in unity (#472) via Mark Villacampa (@MarkVillacampa)
* Improvements typescript interfaces (#471) via Toni Rico (@tonidero)

## 5.6.0
### Dependency Updates
* [AUTOMATIC] Android 6.8.0 => 6.9.0 (#469) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Add API tests to typescript interfaces (#459) via Toni Rico (@tonidero)
* Move typescript interfaces to PHC (#455) via Toni Rico (@tonidero)

## 5.5.0
### Dependency Updates
* [AUTOMATIC] iOS 4.25.1 => 4.25.2 Android 6.7.0 => 6.8.0 (#466) via RevenueCat Git Bot (@RCGitBot)

## 5.4.1
### Dependency Updates
* [AUTOMATIC] iOS 4.25.0 => 4.25.1 (#464) via RevenueCat Git Bot (@RCGitBot)

## 5.4.0
### Dependency Updates
* [AUTOMATIC] iOS 4.24.1 => 4.25.0 Android 6.5.2 => 6.7.0 (#460) via RevenueCat Git Bot (@RCGitBot)
* Bump fastlane from 2.213.0 to 2.214.0 (#461) via dependabot[bot] (@dependabot[bot])

## 5.3.0
### Dependency Updates
* [AUTOMATIC] iOS 4.23.1 => 4.24.1 (#457) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Remove latestDependencies variant (#445) via Cesar de la Vega (@vegaro)

## 5.2.4
### Bugfixes
* Fix free trial and intro price to derive from defaultOption (#449) via Josh Holtz (@joshdholtz)
### Other Changes
* `.composite-enable`: fixed file reference (#450) via NachoSoto (@NachoSoto)
* CI: wait until pods have been pushed to trigger dependent updates (#448) via Mark Villacampa (@MarkVillacampa)

## 5.2.3
### Bugfixes
* Android: retrieve free trial period from the free phase (#446) via Mark Villacampa (@MarkVillacampa)
### Dependency Updates
* Bump fastlane-plugin-revenuecat_internal from `13773d2` to `b2108fb` (#443) via dependabot[bot] (@dependabot[bot])

## 5.2.2
### Dependency Updates
* [AUTOMATIC] Android 6.5.1 => 6.5.2 (#440) via RevenueCat Git Bot (@RCGitBot)

## 5.2.1
### Dependency Updates
* [AUTOMATIC] iOS 4.23.0 => 4.23.1 (#438) via RevenueCat Git Bot (@RCGitBot)

## 5.2.0
### Dependency Updates
* [AUTOMATIC] iOS 4.22.0 => 4.23.0 Android 6.5.0 => 6.5.1 (#435) via RevenueCat Git Bot (@RCGitBot)

## 5.1.0
### Dependency Updates
* [AUTOMATIC] iOS 4.21.0 => 4.22.0 Android 6.4.0 => 6.5.0 (#433) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Add Detekt linter to android codebase (#431) via Toni Rico (@tonidero)

## 5.0.0
**RevenueCat Purchases Hybrid Common v5** is here!! 😻

This latest release updates the Android SDK dependency from v5 to [v6](https://github.com/RevenueCat/purchases-android/releases/tag/6.0.0) to use BillingClient 5. This version of BillingClient brings an entire new subscription model which has resulted in large changes across the entire SDK.

### Migration Guides
- See [Android Native - 5.x to 6.x Migration](https://www.revenuecat.com/docs/android-native-5x-to-6x-migration) for a more thorough explanation of the new Google subscription model announced with BillingClient 5 and how to take advantage of it in V6. This guide includes tips on product setup with the new model.

### New `SubscriptionOption` concept

#### Purchasing
In v4, a Google Play Android `Package` or `StoreProduct` represented a single purchaseable entity, and free trials or intro offers would automatically be applied to the purchase if the user was eligible.

Now, in Hybrid Common v5, an Google Play Android `Package` or `StoreProduct` represents a duration of a subscription and contains all the ways to purchase that duration -- any offers and its base plan. Each of these purchase options are `SubscriptionOption`s.
When passing a `Package` to `purchasePackage()` or `StoreProduct` to `purchaseStoreProduct()`, the SDK will use the following logic to choose which `SubscriptionOption` to purchase:
- Filters out offers with "rc-ignore-offer" tag
- Uses `SubscriptionOption` with the longest free trial or cheapest first phase
    - Only offers the user is eligible will be applied
- Falls back to base plan

For more control, purchase subscription options with the new `purchaseSubscriptionOption()` method.

#### Models

`StoreProduct` now has a few new properties use for Google Play Android:
- `defaultOption`
  - A subscription option that will automatically be applie when purchasing a `Package` or `StoreProduct`
- `subscriptionOptions`
  - A list of subscription options (could be null)

##### Subscription Option

Below is an example of what a subscription option:

```js
{
    "id": "basePlan",
    "storeProductId": "subId:basePlanId",
    "productId": "subId",
    "pricingPhases": [
        {
            "price": 0,
            "priceString": "FREE",
            "period": "P1M",
            "cycles": 1
        },
        {
            "price": 4.99,
            "priceString": "$4.99",
            "period": "P1M",
            "cycles": 0
        }
    ],
    "tags": ["free-offers"],
    "isBasePlan": false,
    "billingPeriod": {
        "periodUnit": "MONTH",
        "periodNumberOfUnits": 0
    },
    "isPrepaid": false,
    "fullPricePhase": {
        "price": 4.99,
        "priceString": "$4.99",
        "period": "P1M",
        "cycles": 0
    },
    "freePhase" {
        "price": 0,
        "priceString": "FREE",
        "period": "P1M",
        "cycles": 1
    },
    "introPhase": null
}
```

### Observer Mode

Observer mode is still supported in v5. Other than updating the SDK version, there are no changes required.

### Offline Entitlements

✨ With this new feature, even if our main and backup servers are down, the SDK can continue to process purchases. This is enabled transparently to the user, and when the servers come back online, the SDK automatically syncs the information so it can be visible in the dashboard.

### Offering Metadata

✨ Metadata allows attaching arbitrary information as key/value pairs to your Offering to control how to display your products inside your app. The metadata you configure in an Offering is available from the RevenueCat SDK. For example, you could use it to remotely configure strings on your paywall, or even URLs of images shown on the paywall.

See the [metadata documentation](https://www.revenuecat.com/docs/offering-metadata) for more info!

## 5.0.0-rc.1
### New Features
* Add offering metadata (#419) via Josh Holtz (@joshdholtz)

## 5.0.0-beta.6
### Breaking Changes
* Reverted breaking change for `productType` on `StoreProduct` mapper (#386) via Josh Holtz (@joshdholtz)
### New Features
* Add `productCategory` support in `getProductInfo()` and `purchaseProduct()` (#387) via Josh Holtz (@joshdholtz)

## 5.0.0-beta.5
### Breaking Changes
* iOS rename `productCategory` to `product type` and `productType` to `productSubtype` (#377) via Josh Holtz (@joshdholtz)
* Android rename `productCategory` to `productType` and `productType` to `productSubtype` (#376) via Josh Holtz (@joshdholtz)
### Other Changes
* Use new mapped product type values for `purchaseProduct()` and `getProductInfo()` (#384) via Josh Holtz (@joshdholtz)

## 5.0.0-beta.4
### Bugfixes
* Add platform check,`OfferPaymentMode`, and `presentedOfferingIdentifier` (#371) via Josh Holtz (@joshdholtz)

## 5.0.0-beta.3
### Breaking Changes
* [BC5] Use Int for Google proration mode to make mapping logic to GoogleProrationMode reusable (#368) via Josh Holtz (@joshdholtz)
### New Features
* [BC5] Add `iso8601` to `Period` for subscription option pricing phases (#369) via Josh Holtz (@joshdholtz)

## 5.0.0-beta.2
### Breaking Changes
* [BC5] Rename `Period` fields to `unit` and `value` (#365) via Josh Holtz (@joshdholtz)
### Bug Fixes
* [BC5] Fix `purchaseProduct` to work with `productIdentifiers` with base plans (#366) via Josh Holtz (@joshdholtz)

## 5.0.0-beta.1
The first beta of **RevenueCat Purchases Hybrid Common v5** is here!! 😻

This latest release updates the Android SDK dependency from v5 to [v6](https://github.com/RevenueCat/purchases-android/releases/tag/6.0.0) to use BillingClient 5. This version of BillingClient brings an entire new subscription model which has resulted in large changes across the entire SDK.

### Migration Guides
- See [Android Native - 5.x to 6.x Migration](https://www.revenuecat.com/docs/android-native-5x-to-6x-migration) for a
  more thorough explanation of the new Google subscription model announced with BillingClient 5 and how to take
  advantage of it in V6. This guide includes tips on product setup with the new model.

### New `SubscriptionOption` concept

#### Purchasing
In v4, a Google Play Android `Package` or `StoreProduct` represented a single purchaseable entity, and free trials or intro
offers would automatically be applied to the purchase if the user was eligible.

Now, in Hybrid Common v5, an Google Play Android `Package` or `StoreProduct` represents a duration of a subscription and contains all the ways to
purchase that duration -- any offers and its base plan. Each of these purchase options are `SubscriptionOption`s.
When passing a `Package` to `purchasePackage()` or `StoreProduct` to `purchaseStoreProduct()`, the SDK will use the following logic to choose which
`SubscriptionOption` to purchase:
- Filters out offers with "rc-ignore-offer" tag
- Uses `SubscriptionOption` with the longest free trial or cheapest first phase
    - Only offers the user is eligible will be applied
- Falls back to base plan

For more control, purchase subscription options with the new `purchaseSubscriptionOption()` method.

#### Models

`StoreProduct` now has a few new properties use for Google Play Android:
- `defaultOption`
  - A subscription option that will automatically be applie when purchasing a `Package` or `StoreProduct`
- `subscriptionOptions`
  - A list of subscription options (could be null)

##### Subscription Option

Below is an example of what a subscription option:

```js
{
    "id": "basePlan",
    "storeProductId": "subId:basePlanId",
    "productId": "subId",
    "pricingPhases": [
        {
            "price": 0,
            "priceString": "FREE",
            "period": "P1M",
            "cycles": 1
        },
        {
            "price": 4.99,
            "priceString": "$4.99",
            "period": "P1M",
            "cycles": 0
        }
    ],
    "tags": ["free-offers"],
    "isBasePlan": false,
    "billingPeriod": {
        "periodUnit": "MONTH",
        "periodNumberOfUnits": 0
    },
    "fullPricePhase": {
        "price": 4.99,
        "priceString": "$4.99",
        "period": "P1M",
        "cycles": 0
    },
    "freePhase" {
        "price": 0,
        "priceString": "FREE",
        "period": "P1M",
        "cycles": 1
    },
    "introPhase": null
}
```

### Observer Mode

Observer mode is still supported in v5. Other than updating the SDK version, there are no changes required.

## 4.18.0
### Dependency Updates
* [AUTOMATIC] iOS 4.20.0 => 4.21.0 (#420) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Makes pushing to Cocoapods its own job (#417) via Cesar de la Vega (@vegaro)

## 4.17.0
### New Features
* Add metadata to offering for iOS (#415) via Josh Holtz (@joshdholtz)
* Remove `watchOS` as a supported platform (#411) via NachoSoto (@NachoSoto)
### Dependency Updates
* [AUTOMATIC] iOS 4.19.0 => 4.20.0 (#409) via RevenueCat Git Bot (@RCGitBot)
* Bump fastlane from 2.212.2 to 2.213.0 (#407) via dependabot[bot] (@dependabot[bot])
### Other Changes
* `CI`: changed Xcode 13 job to 13.4 (#410) via NachoSoto (@NachoSoto)
* Xcode 14.3: fixed warning (#405) via NachoSoto (@NachoSoto)

## 4.16.0
### Dependency Updates
* [AUTOMATIC] iOS 4.18.0 => 4.19.0 (#404) via RevenueCat Git Bot (@RCGitBot)
* Bump fastlane-plugin-revenuecat_internal from `fe45299` to `13773d2` (#402) via dependabot[bot] (@dependabot[bot])

## 4.15.0
### Dependency Updates
* [AUTOMATIC] iOS 4.17.11 => 4.18.0 (#400) via RevenueCat Git Bot (@RCGitBot)
* Bump fastlane-plugin-revenuecat_internal from `8482a43` to `fe4529988aa6dd9ec1d507950416091302e6f56e` (#392) via dependabot[bot] (@dependabot[bot])
* Bump danger from 9.2.0 to 9.3.0 (#397) via dependabot[bot] (@dependabot[bot])

## 4.14.3
### Dependency Updates
* [AUTOMATIC] iOS 4.17.10 => 4.17.11 (#394) via RevenueCat Git Bot (@RCGitBot)
* Bump cocoapods from 1.12.0 to 1.12.1 (#393) via dependabot[bot] (@dependabot[bot])
* Bump fastlane from 2.212.1 to 2.212.2 (#391) via dependabot[bot] (@dependabot[bot])
* [AUTOMATIC] iOS 4.17.9 => 4.17.10 (#389) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Bump fastlane-plugin-revenuecat_internal from `9255366` to `8482a43` (#375) via dependabot[bot] (@dependabot[bot])

## 4.14.2
### Dependency Updates
* [AUTOMATIC] iOS 4.17.8 => 4.17.9 (#379) via RevenueCat Git Bot (@RCGitBot)
* Bump activesupport from 7.0.4.2 to 7.0.4.3 (#360) via dependabot[bot] (@dependabot[bot])
### Other Changes
* `CommonFunctionality.beginRefundRequest`: available on Catalyst (#374) via NachoSoto (@NachoSoto)

## 4.14.1
### Dependency Updates
* [AUTOMATIC] iOS 4.17.7 => 4.17.8 (#361) via RevenueCat Git Bot (@RCGitBot)

## 4.14.0
### Dependency Updates
* [AUTOMATIC] Android 5.8.0 => 5.8.2 (#353) via RevenueCat Git Bot (@RCGitBot)
* [AUTOMATIC] Android 5.7.1 => 5.8.0 (#351) via RevenueCat Git Bot (@RCGitBot)
* Bump cocoapods from 1.11.3 to 1.12.0 (#344) via dependabot[bot] (@dependabot[bot])

## 4.13.5
### Bugfixes
* `EntitlementInfo`: fixed `unsubscribeDetectedAt` typo (#345) via NachoSoto (@NachoSoto)
### Other Changes
* `CommonFunctionality.setLogHandler`: fixed docstring warning (#346) via NachoSoto (@NachoSoto)
* Bump fastlane from 2.212.0 to 2.212.1 (#343) via dependabot[bot] (@dependabot[bot])

## 4.13.4
### Dependency Updates
* [AUTOMATIC] iOS 4.17.6 => 4.17.7 (#341) via RevenueCat Git Bot (@RCGitBot)

## 4.13.3
### Bugfixes
* Send unsupported error for versions of iOS incompatible with discounts instead of nil (#338) via Cesar de la Vega (@vegaro)

## 4.13.2
### Dependency Updates
* [AUTOMATIC] iOS 4.17.5 => 4.17.6 (#333) via RevenueCat Git Bot (@RCGitBot)
* Bump fastlane-plugin-versioning_android from 0.1.0 to 0.1.1 (#332) via dependabot[bot] (@dependabot[bot])
* Bump fastlane from 2.211.0 to 2.212.0 (#334) via dependabot[bot] (@dependabot[bot])

## 4.13.1
### Dependency Updates
* [AUTOMATIC] iOS 4.17.4 => 4.17.5 Android 5.7.0 => 5.7.1 (#330) via RevenueCat Git Bot (@RCGitBot)

## 4.13.0
### New Features
* Add `setLogHandlerWithOnResult` (#328) via Cesar de la Vega (@vegaro)
### Dependency Updates
* Bump fastlane-plugin-revenuecat_internal from `738f255` to `9255366` (#323) via dependabot[bot] (@dependabot[bot])

## 4.12.1
### Dependency Updates
* [AUTOMATIC] iOS 4.17.3 => 4.17.4 (#322) via RevenueCat Git Bot (@RCGitBot)
* Bump git from 1.12.0 to 1.13.1 (#318) via dependabot[bot] (@dependabot[bot])
* Bump danger from 8.6.1 to 9.2.0 (#320) via dependabot[bot] (@dependabot[bot])
* Bump fastlane-plugin-revenuecat_internal from `92650e4` to `738f255` (#319) via dependabot[bot] (@dependabot[bot])
* Bump fastlane from 2.210.1 to 2.211.0 (#321) via dependabot[bot] (@dependabot[bot])
* Bump activesupport from 6.1.6.1 to 6.1.7.2 (#317) via dependabot[bot] (@dependabot[bot])
### Other Changes
* Fix for dependabot issue parsing Gemfile (#316) via Cesar de la Vega (@vegaro)
* Update dependabot.yml package system (#314) via Cesar de la Vega (@vegaro)
* Create dependabot.yml to automatically update Gemfile (#312) via Cesar de la Vega (@vegaro)

## 4.12.0
### New Features
* Adds setLogHandler (#307) via Cesar de la Vega (@vegaro)

## 4.11.0
### New Features
* Android: added `CommonKt.setLogLevel` (#301) via NachoSoto (@NachoSoto)
### Dependency Updates
* [AUTOMATIC] iOS 4.17.2 => 4.17.3 Android 5.6.7 => 5.7.0 (#305) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* `DEVELOPMENT.md`: added section for pointing to local `purchases-android` (#303) via NachoSoto (@NachoSoto)
* Upgrade AGP to 7.4.0 (#302) via Cesar de la Vega (@vegaro)

## 4.10.0
### New Features
* Added `CommonFunctionality.setLogLevel` (#297) via NachoSoto (@NachoSoto)

## 4.9.0
### Dependency Updates
* [AUTOMATIC] iOS 4.16.0 => 4.17.2 Android 5.6.6 => 5.6.7 (#298) via RevenueCat Git Bot (@RCGitBot)
### Other Changes
* Update Gemfile.lock (#296) via Cesar de la Vega (@vegaro)

## 4.8.0
### New Features
* Add `beginRefundRequest` APIs in iOS (#290) via Toni Rico (@tonidero)
### Other Changes
* `CommonFunctionality.sharedInstance`: changed type to `PurchasesType & PurchasesSwiftType` (#294) via NachoSoto (@NachoSoto)
* Update secring (#293) via Cesar de la Vega (@vegaro)

## 4.7.0
### New Features
* Adds subscriptionPeriod (#286) via Cesar de la Vega (@vegaro)
### Other Changes
* Add StoreProduct mapper iOS tests (#285) via Cesar de la Vega (@vegaro)

## 4.6.0
### Other Changes
* [AUTOMATIC] iOS 4.15.5 => 4.16.0 (#289) via RevenueCat Git Bot (@RCGitBot)
* Fix warnings when running pod install (#288) via Cesar de la Vega (@vegaro)
* Add StoreProduct Android Tests  (#284) via Cesar de la Vega (@vegaro)
* Update fastlane-plugin-revenuecat_internal to latest version (#287) via Cesar de la Vega (@vegaro)
* Renames SKProduct and SKProductDiscount HybridAdditions files (#283) via Cesar de la Vega (@vegaro)

## 4.5.4
### Other Changes
* [AUTOMATIC] iOS 4.15.4 => 4.15.5 (#281) via RevenueCat Git Bot (@RCGitBot)

## 4.5.3
### Other Changes
* [AUTOMATIC] iOS 4.15.3 => 4.15.4 (#278) via RevenueCat Git Bot (@RCGitBot)
* `Integration Tests`: enabled receipt fetch retry mechanism (#279) via NachoSoto (@NachoSoto)

## 4.5.2
### Other Changes
* [AUTOMATIC] iOS 4.15.2 => 4.15.3 Android 5.6.5 => 5.6.6 (#276) via RevenueCat Git Bot (@RCGitBot)

## 4.5.1
### Other Changes
* [AUTOMATIC] iOS 4.15.0 => 4.15.2 (#274) via RevenueCat Git Bot (@RCGitBot)

## 4.5.0
### Other Changes
* [AUTOMATIC] iOS 4.14.3 => 4.15.0 (#272) via RevenueCat Git Bot (@RCGitBot)

## 4.4.4
### Other Changes
* [AUTOMATIC] iOS 4.14.2 => 4.14.3 (#270) via RevenueCat Git Bot (@RCGitBot)

## 4.4.3
### Other Changes
* [AUTOMATIC] Android 5.6.4 => 5.6.5 (#268) via RevenueCat Git Bot (@RCGitBot)

## 4.4.2
### Other Changes
* [AUTOMATIC] iOS 4.14.1 => 4.14.2 (#266) via RevenueCat Git Bot (@RCGitBot)

## 4.4.1
### Other Changes
* [AUTOMATIC] iOS 4.14.0 => 4.14.1 Android 5.6.3 => 5.6.4 (#264) via RevenueCat Git Bot (@RCGitBot)

## 4.4.0
### Other Changes
* [AUTOMATIC] iOS 4.13.4 => 4.14.0 (#262) via RevenueCat Git Bot (@RCGitBot)
* CI: added `Xcode 13.2` job (#256) via NachoSoto (@NachoSoto)
* Update fastlane-plugin-revenuecat_internal (#261) via Cesar de la Vega (@vegaro)

## 4.3.6
### Other Changes
* [AUTOMATIC] iOS 4.13.2 => 4.13.4 (#259) via RevenueCat Git Bot (@RCGitBot)
* Adds missing repositories to trigger-dependent-updates workflow (#248) via Cesar de la Vega (@vegaro)

## 4.3.5
### Other Changes
* Updated `SnapshotTesting` to `1.10.0` (#231) via NachoSoto (@NachoSoto)
* CI: using `Xcode 14.1` (#232) via NachoSoto (@NachoSoto)

## 4.3.4
### Other Changes
* [AUTOMATIC] Android 5.6.2 => 5.6.3 (#254) via RevenueCat Git Bot (@RCGitBot)

## 4.3.3
### Bugfixes
* re-add error message if SDK hasn't been configured (#253) via Andy Boedo (@aboedo)

## 4.3.2
### Other Changes
* [AUTOMATIC] iOS 4.13.1 => 4.13.2 Android 5.6.1 => 5.6.2 (#250) via RevenueCat Git Bot (@RCGitBot)
* Improvements on automatic upgrading iOS and Android version depending type of change (#249) via Cesar de la Vega (@vegaro)

## 4.3.1
### Other Changes
* Upgrade iOS to 4.13.1 and Android to 5.6.1 (#246) via RevenueCat Git Bot (@RCGitBot)
* Update maven-publish-plugin (#245) via Cesar de la Vega (@vegaro)
* Adds parameters to run bump and dependency updates manually instead of approval jobs (#243) via Cesar de la Vega (@vegaro)
* `IntegrationTests`: don't initialize `Purchases` until `SKTestSession` has been re-created (#244) via NachoSoto (@NachoSoto)

## 4.3.0
### Other Changes
* Upgrade iOS to 4.13.0 and Android to 5.6.1 (#235) via RevenueCat Git Bot (@RCGitBot)
* Remove step from automatic-release to trigger Flutter update. Use its own job instead (#240) via Cesar de la Vega (@vegaro)
* Trigger purchases-flutter dependency upgrade when release is made (#238) via Cesar de la Vega (@vegaro)
* Remove upload of the PurchasesHybridCommon.framework (#239) via Cesar de la Vega (@vegaro)
* Update Dangerfile to use repository (#237) via Cesar de la Vega (@vegaro)
* Store PurchasesHybridCommon.framework.zip artifact (#236) via Cesar de la Vega (@vegaro)

## 4.2.2
### Bugfixes
* `CommonFunctionality`: fixed unknown error creation (#233) via NachoSoto (@NachoSoto)
### Other Changes
* `Integration Tests`: added test for `promotionalOffer` (#228) via NachoSoto (@NachoSoto)

## 4.2.1
### Bugfixes
* `purchase(productIdentifier:)` fixed SK2 implementation (#226) via NachoSoto (@NachoSoto)
### Other Changes
* Upgrade iOS to 4.11.0 (#224) via RevenueCat Git Bot (@RCGitBot)
* Adds hold jobs to manual trigger automatic dependency updates (#223) via Cesar de la Vega (@vegaro)

## 4.2.0
### New Features
* Add in missing attribution functions (#219) via Joshua Liebowitz (@taquitos)

## 4.1.5
### Other Changes
* Upgrade iOS to 4.10.2 and Android to 5.5.0 (#220) via RevenueCat Git Bot (@RCGitBot)
* Fix CircleCI caches (#217) via Cesar de la Vega (@vegaro)
* Skip next version if there are no public changes (#218) via Cesar de la Vega (@vegaro)

## 4.1.4
### API Changes
* Rename revenueCatId and productId to transactionIdentifier and productIdentifier. Old values still exist but are deprecated (#211) via Toni Rico (@tonidero)

### Other Changes
* Update common fastlane plugin (#215) via Cesar de la Vega (@vegaro)
* Replace build with dependencies on automatic upgrade PRs (#213) via Cesar de la Vega (@vegaro)
* `IntegrationTests`: actually fail test if tests aren't configured (#210) via NachoSoto (@NachoSoto)

## 4.1.3
### Other Changes
* `automaticAppleSearchAdsAttributionCollection`: changed implementation to call method directly (#199) via NachoSoto (@NachoSoto)
* Release train (#202) via Cesar de la Vega (@vegaro)
* Adds Danger (#204) via Cesar de la Vega (@vegaro)
* Upgrade iOS to 4.10.2 (#207) (@NachoSoto)

## 4.1.2
### Other Changes
* Upgrade iOS to 4.10.1 (#201) via RevenueCat Git Bot (@RCGitBot)

## 4.1.1
* Added missing availability check for catalyst (#197) via aboedo (@aboedo)
* Adds .bundle and vendor to gitignore (#196) via Cesar de la Vega (@vegaro)
* Schedule automatic PR to update native dependencies (#179) via Cesar de la Vega (@vegaro)

## 4.1.0
* Update iOS 4.10.0 (and add AdServices) (#194) via Josh Holtz (@joshdholtz)

## 4.0.2

- Redeploy updates from 4.0.1 - bad deploy.

## 4.0.1

- Updated `purchases-android` to [5.4.1](https://github.com/RevenueCat/purchases-android/releases/tag/5.4.1)

## 4.0.0

- Fixed snake_case and camelCase serialization inconsistency in `StoreProduct` (https://github.com/RevenueCat/purchases-hybrid-common/pull/187):
    - Renamed `price_string` to `priceString`
    - Renamed `currency_code` to `currencyCode`
    - Renamed `intro_price` to `introPrice`
    - Renamed `product_category` to `productCategory`
    - Renamed `product_type` to `productType`
- Updated `purchases-ios` to [4.9.1](https://github.com/RevenueCat/purchases-ios/releases/tag/4.9.1)

## 3.3.0

- Update purchases-android to 5.3.0 (https://github.com/RevenueCat/purchases-android/releases/tag/5.3.0)

## 3.2.4

- Update Podspec version

## 3.2.3

- Bump RevenueCat `purchases-ios` to 4.9.0
- Bump RevenueCat `purchases-android` to 5.2.1 (https://github.com/RevenueCat/purchases-hybrid-common/pull/172)

## 3.2.2

- Bump RevenueCat purchases-ios dependency (https://github.com/RevenueCat/purchases-hybrid-common/pull/166)

## 3.2.1

- Bump RevenueCat purchases-ios dependency (https://github.com/RevenueCat/purchases-hybrid-common/pull/163)
- Fix checkTrialOrIntroDiscountEligibility returning the incorrect eligibility status (https://github.com/RevenueCat/purchases-hybrid-common/pull/159)

## 3.2.0

- Fix purchasing of a product not initiating the purchase in iOS (https://github.com/RevenueCat/purchases-hybrid-common/pull/146/)
- Changed `intro_price` field in the StoreProduct map to contain the Introductory Price JSON object. `introPrice` has been removed. Removal of `intro_price_cycles`, `intro_price_period`, `intro_price_period_number_of_units`, `intro_price_period_unit`, `intro_price_string` in the iOS map. (https://github.com/RevenueCat/purchases-hybrid-common/pull/147/)

## 3.1.0

- Added Amazon case to the store value in the EntitlementInfo map in both the iOS and Android https://github.com/RevenueCat/purchases-hybrid-common/pull/142/
- Bumped `purchases-ios` to `4.4.1` https://github.com/RevenueCat/purchases-hybrid-common/pull/142

## 3.0.0

- Bumped `purchases-ios` to `4.3.0` https://github.com/RevenueCat/purchases-hybrid-common/pull/137
- Bumped `purchases-android` to `5.1.0`
- Removed `createAlias`, `identify`, `logOut`
- Renamed `PurchaserInfo` to `CustomerInfo`
- Renamed `restoreTransactions` -> `restorePurchases`
- Renamed `paymentDiscountForProductIdentifier` ->  `promotionalOffer(for:)`
- Replaced extensions of StoreKit types with extensions of RevenueCat types
- Added Objective-C API testers
- Updated Java requirement to Java 8 https://github.com/RevenueCat/purchases-hybrid-common/pull/118
- Added Unity IAP flavor https://github.com/RevenueCat/purchases-hybrid-common/pull/126
- Updated min iOS deployment target to 11.0

## 2.0.1

- Fixed an issue where checkTrialOrIntroductoryPriceEligibility might refresh the receipt if it's not present on device,
causing a log in prompt for App Store credentials.
- Bumped `purchases-ios` to `3.14.1`
    https://github.com/RevenueCat/purchases-hybrid-common/pull/109

## 2.0.0

### Breaking changes
- Updated `configureWithAPIKey:` method to accept a DangerousSettings object

### Other
- Bump purchases-ios to 3.14.0 [Changelog here](https://github.com/RevenueCat/purchases-ios/releases/tag/3.14.0)

## 1.11.2

- Fixes an inconsistency between `null` `introPrice` mapping in iOS and Android
    https://github.com/RevenueCat/purchases-hybrid-common/pull/106
- Bump `purchases-android` to `4.6.1` ([Changelog here](https://github.com/RevenueCat/purchases-android/releases/4.6.1))
- Bump purchases-ios to 3.13.2. [Changelog here](https://github.com/RevenueCat/purchases-ios/releases/tag/3.13.2)

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
