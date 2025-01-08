//
//  PurchaseParams+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Will Taylor on 1/7/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat
import StoreKit

//class PurchaseParamsHybridAdditionsTests: QuickSpec {
//
//    override func spec() {
//        context("PurchasesParams") {
//            expect(PurchaseParams.purchaseParamsWith(product: mockStoreProduct(), winBackOffer: WinBackOffer(discount: StoreProductDiscount)))
//        }
//    }
//
//    private func mockStoreProduct(
//        with locale: Locale = Locale(identifier: "en_US"),
//        description: String = "A product description",
//        productIdentifier: String = "monthly",
//        price: Decimal = Decimal(1.0),
//        title: String = "Monthly Product",
//        introductoryPrice: SKProductDiscount? = nil,
//        discounts: [SKProductDiscount] = [],
//        subscriptionPeriod: SKProductSubscriptionPeriod? = nil
//    ) -> StoreProduct {
//        return StoreProduct(priceLocale: locale,
//                            localizedDescription: description,
//                            discounts: discounts,
//                            productIdentifier: productIdentifier,
//                            introductoryDiscount: nil,
//                            price: price,
//                            productType: .autoRenewableSubscription,
//                            localizedTitle: title,
//                            subscriptionPeriod: subscriptionPeriod,
//                            subscriptionGroupIdentifier: "sub_group",
//                            introductoryPrice: introductoryPrice
//        )
//    }
//}
