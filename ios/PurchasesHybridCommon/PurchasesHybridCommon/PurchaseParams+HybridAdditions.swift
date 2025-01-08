//
//  PurchaseParams+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 1/7/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat


// RCPurchaseParamsBuilder isn't available in purchases-kmp since it's a nested Swift class, and
// we can't expose it as a typealias since Swift typealiases aren't available in Objective-C.
// Instead, we can create the builders that we need here.
extension PurchaseParams {

    @objc(purchaseParamsWithProduct:winBackOffer:)
    static public func purchaseParamsWith(
        product: StoreProduct,
        winBackOffer: WinBackOffer
    ) -> PurchaseParams {
        if #available(iOS 18.0, *) {
            return PurchaseParams.Builder(product: product).with(winBackOffer: winBackOffer).build()
        } else {
            return PurchaseParams.Builder(product: product).build()
        }
    }

    @objc(purchaseParamsWithPackage:winBackOffer:)
    static public func purchaseParamsWith(
        package: Package,
        winBackOffer: WinBackOffer
    ) -> PurchaseParams {
        if #available(iOS 18.0, *) {
            return PurchaseParams.Builder(package: package).with(winBackOffer: winBackOffer).build()
        } else {
            return PurchaseParams.Builder(package: package).build()
        }
    }
}

@objc
public class WillsBaseClass: NSObject {

    @objc
    public func hello() {
        print("Hello")
    }

    @objc
    public class WillsNestedClass: NSObject {
        @objc
        public func world() {
            print("World")
        }
    }
}
