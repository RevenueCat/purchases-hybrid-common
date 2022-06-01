# iOS

## Point to a local Purchases project

In `ios/PurchasesHybridCommon/Podfile` replace:

```
  pod 'RevenueCat', '4.4.0'
```

with:

```
  pod 'Purchases', :path => '~/Development/repos/ios/purchases-ios'
  pod 'PurchasesCoreSwift', :path => '~/Development/repos/ios/purchases-ios'
```

Remember to change `'~/Development/repos/ios/purchases-ios'` with your local purchases-ios path.