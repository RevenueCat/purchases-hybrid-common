//
//  CommonFunctionality+AttributesForCurrentUserTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import XCTest
import Nimble
@_spi(Internal) @testable import PurchasesHybridCommon
@_spi(Internal) @testable import RevenueCat

final class CommonFunctionalityAttributesForCurrentUserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Attribution is a concrete class, so these use a real, freshly configured SDK.
        _ = Purchases.configure(apiKey: "api key",
                                appUserID: nil,
                                purchasesAreCompletedBy: "REVENUECAT",
                                userDefaultsSuiteName: UUID().uuidString,
                                platformFlavor: "hybrid-platform",
                                platformFlavorVersion: "1.2.3",
                                dangerousSettings: nil,
                                verificationMode: nil,
                                useExternalPurchaseCustomLinks: false,
                                enableExternalPurchasesInSimulator: true,
                                iamEnabled: false,
                                keychainAccessGroup: nil)
    }

    func testReturnsAttributesSortedByKey() {
        CommonFunctionality.setAttributes(["zeta": "1", "alpha": "2", "mid": "3"])

        expect(self.customKeys()) == ["alpha", "mid", "zeta"]
    }

    func testMapsEachAttribute() throws {
        CommonFunctionality.setAttributes(["favorite_color": "blue"])

        let attribute = try XCTUnwrap(
            CommonFunctionality.getAttributesForCurrentUser().first { $0["key"] as? String == "favorite_color" }
        )
        let isoDate = try XCTUnwrap(attribute["lastUpdatedDate"] as? String)
        let millis = try XCTUnwrap(attribute["lastUpdatedDateMillis"] as? Double)
        let parsedDate = try XCTUnwrap(ISO8601DateFormatter().date(from: isoDate))

        expect(attribute["value"] as? String) == "blue"
        expect(parsedDate.timeIntervalSince1970).to(beCloseTo(millis / 1000, within: 1))
        expect(parsedDate.timeIntervalSinceNow).to(beCloseTo(0, within: 60))
    }

    func testExcludesDeletedAttributes() {
        CommonFunctionality.setAttributes(["kept": "1", "deleted": "2"])
        CommonFunctionality.setAttributes(["deleted": NSNull()])

        expect(self.customKeys()) == ["kept"]
    }

    // The SDK may set reserved `$` attributes itself on configure.
    private func customKeys() -> [String] {
        return CommonFunctionality.getAttributesForCurrentUser()
            .compactMap { $0["key"] as? String }
            .filter { !$0.hasPrefix("$") }
    }

}
