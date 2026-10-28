//
//  CheckpointProxyTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if os(iOS) && !targetEnvironment(macCatalyst)

import XCTest
@testable import PurchasesHybridCommonUI
@_spi(InviteOnlyCheckpointsApi) import RevenueCatUI

@MainActor
@available(iOS 15.0, *)
final class CheckpointProxyTests: XCTestCase {

    private struct Start {
        let identifier: String
        let variables: [String: CustomVariableValue]
        let mode: FlowPresentationMode
        let passed: ([String: Any]) -> Void
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

    func testForwardsPassedResult() throws {
        self.present()

        try XCTUnwrap(self.starts.first).passed(["customer": [:], "flow": NSNull()])

        XCTAssertEqual(self.passed.count, 1)
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
