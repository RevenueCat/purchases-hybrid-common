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


@objc(WillsPurchaseParams) public final class WillsPurchaseParams: NSObject, Sendable {

    let package: Package?
    let product: StoreProduct?
    let promotionalOffer: PromotionalOffer?
    let winBackOffer: WinBackOffer?
    let metadata: [String: String]?

    private init(with builder: Builder) {
        self.promotionalOffer = builder.promotionalOffer
        self.metadata = builder.metadata
        self.product = builder.product
        self.package = builder.package
        self.winBackOffer = builder.winBackOffer
    }

    /// The Builder for ```PurchaseParams```.
    @objc(WillsPurchaseParamsBuilder) public class Builder: NSObject {
        private(set) var promotionalOffer: PromotionalOffer?
        private(set) var metadata: [String: String]?
        private(set) var package: Package?
        private(set) var product: StoreProduct?
        private(set) var winBackOffer: WinBackOffer?

        /**
         * Create a new builder with a ``Package``.
         *
         * - Parameter package: The ``Package`` the user intends to purchase.
         */
        @objc public init(package: Package) {
            self.package = package
        }

        /**
         * Create a new builder with a ``StoreProduct``.
         *
         * Use this initializer if you are not using the ``Offerings`` system to purchase a ``StoreProduct``.
         * If you are using the ``Offerings`` system, use ``PurchaseParams/Builder/init(package:)`` instead.
         *
         * - Parameter product: The ``StoreProduct`` the user intends to purchase.
         */
        @objc public init(product: StoreProduct) {
            self.product = product
        }

        /**
         * Set `promotionalOffer`.
         * - Parameter promotionalOffer: The ``PromotionalOffer`` to apply to the purchase.
         */
        @objc public func with(promotionalOffer: PromotionalOffer) -> Self {
            self.promotionalOffer = promotionalOffer
            return self
        }

        #if ENABLE_TRANSACTION_METADATA
        /**
         * Set `metadata`.
         * - Parameter metadata: Key-value pairs of metadata to attatch to the purchase.
         */
        @objc public func with(metadata: [String: String]) -> Self {
            self.metadata = metadata
            return self
        }
        #endif

        /**
         * Sets a win-back offer for the purchase.
         * - Parameter winBackOffer: The ``WinBackOffer`` to apply to the purchase.
         *
         * Fetch a winBackOffer to use with this function with ``Purchases/eligibleWinBackOffers(forProduct:)``
         * or ``Purchases/eligibleWinBackOffers(forProduct:completion)``.
         *
         * Availability: iOS 18.0+, macOS 15.0+, tvOS 18.0+, watchOS 11.0+, visionOS 2.0+
         */
        @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
        @objc public func with(winBackOffer: WinBackOffer) -> Self {
            self.winBackOffer = winBackOffer
            return self
        }

        /// Generate a ``Configuration`` object given the values configured by this builder.
        @objc public func build() -> WillsPurchaseParams {
            return WillsPurchaseParams(with: self)
        }
    }
}

// Empty extension to make the Builder accessible from Objective-C and KMP
@objc
public extension PurchaseParams.Builder { }
