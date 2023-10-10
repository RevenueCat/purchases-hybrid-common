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
