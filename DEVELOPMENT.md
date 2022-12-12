# iOS

## Point to a local Purchases project

In `ios/PurchasesHybridCommon/Podfile` replace:

```
  pod 'RevenueCat', '4.15.2'
```

with:

```
  pod 'RevenueCat', :path => '~/Development/repos/ios/purchases-ios'
```

Remember to change `'~/Development/repos/ios/purchases-ios'` with your local purchases-ios path.