//
//  CheckpointProxyTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if os(iOS) && !targetEnvironment(macCatalyst)

import XCTest
@testable import PurchasesHybridCommonUI
@_spi(Internal) @testable import RevenueCat
@_spi(InviteOnlyCheckpointsApi) @testable import RevenueCatUI

@MainActor
@available(iOS 15.0, *)
final class CheckpointProxyTests: XCTestCase {

    private struct Start {
        let identifier: String
        let variables: [String: CustomVariableValue]
        let mode: FlowPresentationMode
        let passed: (CheckpointResult) -> Void
    }

    private var starts: [Start] = []
    private var passed: [[String: Any]] = []
    private var errors: [(code: String, message: String)] = []

    override func setUp() {
        super.setUp()
        self.starts = []
        self.passed = []
        self.errors = []
    }

    private func present(
        customVariables: [String: Any]? = nil,
        presentationMode: String? = nil,
        isConfigured: Bool = true
    ) {
        CheckpointProxy.present(
            identifier: "upgrade",
            customVariables: customVariables,
            presentationMode: presentationMode,
            isConfigured: { isConfigured },
            start: { [unowned self] identifier, variables, mode, passed in
                self.starts.append(Start(identifier: identifier, variables: variables, mode: mode, passed: passed))
            },
            onPassed: { [unowned self] in self.passed.append($0) },
            onError: { [unowned self] in self.errors.append(($0, $1)) }
        )
    }

    func testReportsNotConfiguredAndDoesNotStart() {
        self.present(isConfigured: false)

        XCTAssertTrue(self.starts.isEmpty)
        XCTAssertEqual(self.errors.map(\.code), [CheckpointProxy.notConfiguredErrorCode])
    }

    func testStartsWithIdentifierAndDoesNotCallBackUntilPassed() {
        self.present()

        XCTAssertEqual(self.starts.map(\.identifier), ["upgrade"])
        XCTAssertTrue(self.passed.isEmpty)
        XCTAssertTrue(self.errors.isEmpty)
    }

    func testSerializesPassedResult() throws {
        self.present()

        let customer = CustomerInfo(entitlements: EntitlementInfos(entitlements: [:]),
                                    requestDate: Date(timeIntervalSince1970: 0),
                                    firstSeen: Date(timeIntervalSince1970: 0),
                                    originalAppUserId: "user")
        try XCTUnwrap(self.starts.first).passed(CheckpointResult(flow: nil, customer: customer))

        let result = try XCTUnwrap(self.passed.first)
        XCTAssertEqual(self.passed.count, 1)
        XCTAssertTrue(result["flow"] is NSNull)
        XCTAssertNotNil(result["customer"])
    }

    func testSerializesObtainedEntitlementsFromTheCustomersEntitlementMap() throws {
        let pro = EntitlementInfo(
            identifier: "pro",
            isActive: true,
            willRenew: true,
            periodType: .normal,
            latestPurchaseDate: Date(timeIntervalSince1970: 0),
            expirationDate: Date(timeIntervalSince1970: 4_102_444_800),
            store: .appStore,
            productIdentifier: "pro_product",
            isSandbox: true,
            ownershipType: .purchased
        )
        let customer = CustomerInfo(entitlements: EntitlementInfos(entitlements: ["pro": pro]),
                                    requestDate: Date(timeIntervalSince1970: 0),
                                    firstSeen: Date(timeIntervalSince1970: 0),
                                    originalAppUserId: "user")
        let flow = FlowResult(obtainedEntitlements: [ObtainedEntitlement(entitlementInfo: pro)],
                              obtainedProducts: [])

        let result = CheckpointSerialization.dictionary(for: CheckpointResult(flow: flow, customer: customer))

        let obtained = try XCTUnwrap((result["flow"] as? [String: Any])?["obtainedEntitlements"]
                                     as? [[String: Any]])
        let info = try XCTUnwrap(obtained.first?["entitlementInfo"] as? [String: Any])
        XCTAssertEqual(obtained.count, 1)
        XCTAssertEqual(info["identifier"] as? String, "pro")
    }

    func testMapsCustomVariablesKeepingBooleansDistinctFromNumbers() throws {
        self.present(customVariables: [
            "level": NSNumber(value: 1),
            "pro": NSNumber(value: true),
            "name": "a",
            "ignored": [1, 2]
        ])

        let variables = try XCTUnwrap(self.starts.first).variables
        XCTAssertEqual(variables, ["level": .number(1), "pro": .bool(true), "name": .string("a")])
    }

    func testMapsPresentationMode() {
        XCTAssertEqual(CheckpointProxy.mode(for: "MODAL_FULL_SCREEN"), .modalFullScreen)
        XCTAssertEqual(CheckpointProxy.mode(for: "MODAL_SHEET"), .modalSheet)
        XCTAssertEqual(CheckpointProxy.mode(for: "DEFAULT"), .default)
        XCTAssertEqual(CheckpointProxy.mode(for: nil), .default)
    }

}

#endif
