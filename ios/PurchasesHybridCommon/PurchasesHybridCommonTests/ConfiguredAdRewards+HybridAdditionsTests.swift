//
//  ConfiguredAdRewards+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
import XCTest
@testable import PurchasesHybridCommon
@testable import RevenueCat

class ConfiguredAdRewardsHybridAdditionsTests: XCTestCase {

    func testNoConfiguredRewardUsesExplicitNullAndEmptyArray() throws {
        let dictionary = ConfiguredAdRewards.noConfiguredReward.rc_dictionary

        XCTAssertEqual(dictionary.count, 2)
        XCTAssertTrue(dictionary["reward"] is NSNull)
        XCTAssertEqual((dictionary["moreRewards"] as? [[String: Any]])?.count, 0)
        XCTAssertTrue(JSONSerialization.isValidJSONObject(dictionary))
    }

    func testMapsPrimaryAndAdditionalRewardsInOrder() throws {
        let currency = try XCTUnwrap(VirtualCurrencyRewardConfiguration(code: "GLD", amount: 100))
        let entitlement = try XCTUnwrap(EntitlementRewardConfiguration(identifier: "premium", duration: 1800))
        let configured = ConfiguredAdRewards(
            reward: .virtualCurrency(currency),
            moreRewards: [.entitlement(entitlement), .unsupportedReward, .virtualCurrency(currency)]
        )

        let dictionary = configured.rc_dictionary
        XCTAssertEqual(dictionary.count, 2)
        XCTAssertEqual(dictionary["reward"] as? NSDictionary, [
            "type": "virtual_currency", "code": "GLD", "amount": 100
        ] as NSDictionary)
        XCTAssertEqual(dictionary["moreRewards"] as? NSArray, [
            ["type": "entitlement", "identifier": "premium", "durationSeconds": 1800.0],
            ["type": "unsupported_reward"],
            ["type": "virtual_currency", "code": "GLD", "amount": 100],
        ] as NSArray)
        XCTAssertTrue(JSONSerialization.isValidJSONObject(dictionary))
    }

    func testEntitlementDurationUsesSecondsWithoutTruncation() throws {
        let entitlement = try XCTUnwrap(EntitlementRewardConfiguration(identifier: "premium", duration: 1.5))
        let dictionary = AdRewardConfiguration.entitlement(entitlement).rc_dictionary

        XCTAssertEqual(dictionary.count, 3)
        XCTAssertEqual(dictionary["durationSeconds"] as? Double, 1.5)
        XCTAssertNil(dictionary["expiresAt"])
    }

    func testUnsupportedPrimaryRewardRemainsAConfiguredReward() {
        let configured = ConfiguredAdRewards(reward: .unsupportedReward, moreRewards: [])

        XCTAssertEqual(configured.rc_dictionary["reward"] as? NSDictionary,
                       ["type": "unsupported_reward"] as NSDictionary)
    }

    @available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
    func testAccessorPreservesExactAdUnitIDAndUnavailableResult() {
        let completed = self.expectation(description: "unavailable")
        DispatchQueue.global().async {
            CommonFunctionality.fetchAdRewards(adUnitId: " Ad-Unit-ID ", completion: { result, error in
                XCTAssertTrue(Thread.isMainThread)
                XCTAssertNil(result)
                XCTAssertNil(error)
                completed.fulfill()
            }, fetch: { adUnitId in
                XCTAssertEqual(adUnitId, " Ad-Unit-ID ")
                return nil
            })
        }

        self.waitForExpectations(timeout: 2)
    }

    @available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
    func testAccessorMapsNoConfiguredRewardAndDoesNotCachePreviousResult() {
        let first = self.expectation(description: "configured")
        CommonFunctionality.fetchAdRewards(adUnitId: "unit", completion: { result, error in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertTrue(result?["reward"] is NSNull)
            XCTAssertNil(error)
            first.fulfill()
        }, fetch: { _ in .noConfiguredReward })
        self.waitForExpectations(timeout: 2)

        let second = self.expectation(description: "unavailable after configured")
        CommonFunctionality.fetchAdRewards(adUnitId: "unit", completion: { result, error in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNil(result)
            XCTAssertNil(error)
            second.fulfill()
        }, fetch: { _ in nil })
        self.waitForExpectations(timeout: 2)
    }

}
