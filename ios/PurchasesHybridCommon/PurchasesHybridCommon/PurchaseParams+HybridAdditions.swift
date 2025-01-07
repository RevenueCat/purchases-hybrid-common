//
//  PurchaseParams+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 1/7/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat


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
}

