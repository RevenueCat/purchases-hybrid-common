//
//  HybridPurchaseLogicBridgeTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Foundation
import XCTest
import PurchasesHybridCommon
@testable import PurchasesHybridCommonUI
@testable import RevenueCat
@testable import RevenueCatUI

@available(iOS 15.0, *)
class HybridPurchaseLogicBridgeTests: XCTestCase {

    @MainActor
    func testPurchaseWithoutOfferPreservesPackageEvent() async {
        let package = makePackage()
        var receivedEvent: [String: Any]?
        let bridge = HybridPurchaseLogicBridge(onPerformPurchase: { event in
            receivedEvent = event
            Self.resolve(event, result: HybridPurchaseLogicBridge.resultSuccess)
        }, onPerformRestore: nil)

        let purchase: PerformPurchaseWithContext = bridge.makePerformPurchase()
        let result = await purchase(.init(package: package, promotionalOffer: nil))

        XCTAssertEqual(receivedEvent?["packageBeingPurchased"] as? NSDictionary, package.dictionary as NSDictionary)
        XCTAssertNotNil(receivedEvent?["requestId"] as? String)
        XCTAssertNil(receivedEvent?["promotionalOffer"])
        XCTAssertFalse(result.userCancelled)
        XCTAssertNil(result.error)
    }

    @MainActor
    func testPurchaseForwardsSignedPromotionalOffer() async throws {
        let package = makePackage()
        let nonce = UUID()
        let offer = PromotionalOffer(
            discount: TestStoreProductDiscount(
                identifier: "promo", price: 1, localizedPriceString: "$1.00", paymentMode: .payAsYouGo,
                subscriptionPeriod: .init(value: 1, unit: .month), numberOfPeriods: 3, type: .promotional
            ),
            signedData: .init(
                identifier: "promo", keyIdentifier: "key", nonce: nonce, signature: "signature", timestamp: 1234
            )
        )
        var receivedEvent: [String: Any]?
        let bridge = HybridPurchaseLogicBridge(onPerformPurchase: { event in
            receivedEvent = event
            Self.resolve(event, result: HybridPurchaseLogicBridge.resultSuccess)
        }, onPerformRestore: nil)

        let result = await bridge.makePerformPurchase()(.init(package: package, promotionalOffer: offer))

        let event = try XCTUnwrap(receivedEvent)
        XCTAssertEqual(event["packageBeingPurchased"] as? NSDictionary, package.dictionary as NSDictionary)
        XCTAssertEqual(event["promotionalOffer"] as? NSDictionary, [
            "identifier": "promo", "keyIdentifier": "key", "nonce": nonce.uuidString,
            "signature": "signature", "timestamp": 1234
        ] as NSDictionary)
        XCTAssertTrue(JSONSerialization.isValidJSONObject(event))
        XCTAssertFalse(result.userCancelled)
        XCTAssertNil(result.error)
    }

    @MainActor
    func testPurchaseCancellation() async {
        let bridge = HybridPurchaseLogicBridge(onPerformPurchase: { event in
            Self.resolve(event, result: HybridPurchaseLogicBridge.resultCancellation)
        }, onPerformRestore: nil)

        let result = await bridge.makePerformPurchase()(.init(package: makePackage(), promotionalOffer: nil))

        XCTAssertTrue(result.userCancelled)
        XCTAssertNil(result.error)
    }

    @MainActor
    func testPurchaseError() async {
        let bridge = HybridPurchaseLogicBridge(onPerformPurchase: { event in
            Self.resolve(event, result: HybridPurchaseLogicBridge.resultError, errorMessage: "Purchase failed")
        }, onPerformRestore: nil)

        let result = await bridge.makePerformPurchase()(.init(package: makePackage(), promotionalOffer: nil))

        XCTAssertFalse(result.userCancelled)
        XCTAssertEqual(result.error?.localizedDescription, "Purchase failed")
    }

    @MainActor
    func testMissingPurchaseHandlerReturnsError() async {
        let bridge = HybridPurchaseLogicBridge(onPerformPurchase: nil, onPerformRestore: nil)

        let result = await bridge.makePerformPurchase()(.init(package: makePackage(), promotionalOffer: nil))

        XCTAssertFalse(result.userCancelled)
        XCTAssertEqual(result.error?.localizedDescription, "No onPerformPurchase handler registered")
    }

    private func makePackage() -> Package {
        Package(
            identifier: "$rc_monthly", packageType: .monthly,
            storeProduct: TestStoreProduct(
                localizedTitle: "Monthly", price: 9.99, currencyCode: "USD", localizedPriceString: "$9.99",
                productIdentifier: "monthly", productType: .autoRenewableSubscription,
                localizedDescription: "Monthly subscription", locale: Locale(identifier: "en_US")
            ).toStoreProduct(),
            offeringIdentifier: "default", webCheckoutUrl: nil
        )
    }

    private static func resolve(_ event: [String: Any], result: String, errorMessage: String? = nil) {
        guard let requestId = event[HybridPurchaseLogicBridge.eventKeyRequestId] as? String else {
            XCTFail("Missing request ID")
            return
        }
        XCTAssertTrue(Thread.isMainThread)
        HybridPurchaseLogicBridge.resolveResult(requestId: requestId, resultString: result, errorMessage: errorMessage)
    }

}

#endif
