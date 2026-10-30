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
@_spi(Internal) @_spi(InviteOnlyCheckpointsApi) @testable import RevenueCatUI

@MainActor
@available(iOS 15.0, *)
final class CheckpointProxyTests: XCTestCase {

    // MARK: - No-factory path state

    private struct Start {
        let identifier: String
        let variables: [String: CustomVariableValue]
        let mode: FlowPresentationMode
        let passed: (CheckpointResult) -> Void
    }

    private var starts: [Start] = []
    private var passed: [[String: Any]] = []
    private var errors: [(code: String, message: String)] = []

    // MARK: - Factory path state

    private struct FactoryStart {
        let identifier: String
        let variables: [String: CustomVariableValue]
        let mode: FlowPresentationMode
        let factory: ErrorDialogFactory?
        let passed: (CheckpointResult) -> Void
    }

    private var factoryStarts: [FactoryStart] = []
    private var requestedErrors: [(requestId: String, error: [String: Any])] = []
    private var resolvedOutcomes: [ErrorDialogFactoryOutcome] = []

    // MARK: - Setup / teardown

    override func setUp() {
        super.setUp()
        self.starts = []
        self.passed = []
        self.errors = []
        self.factoryStarts = []
        self.requestedErrors = []
        self.resolvedOutcomes = []
    }

    override func tearDown() {
        // Cancel any pending factory requests to avoid static state leaking between tests.
        CheckpointProxy.cancelErrorDialogs(callId: nil)
        super.tearDown()
    }

    // MARK: - No-factory path helpers

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

    // MARK: - Factory path helpers

    private func presentWithFactory(
        callId: String = "call-1",
        identifier: String = "upgrade",
        customVariables: [String: Any]? = nil,
        presentationMode: String? = nil,
        isConfigured: Bool = true
    ) {
        CheckpointProxy.present(
            identifier: identifier,
            callId: callId,
            customVariables: customVariables,
            presentationMode: presentationMode,
            isConfigured: { isConfigured },
            start: { [unowned self] identifier, variables, mode, factory, passed in
                self.factoryStarts.append(FactoryStart(
                    identifier: identifier,
                    variables: variables,
                    mode: mode,
                    factory: factory,
                    passed: passed
                ))
            },
            onErrorDialogRequested: { [unowned self] requestId, error in
                self.requestedErrors.append((requestId: requestId, error: error))
            },
            onPassed: { [unowned self] in self.passed.append($0) },
            onError: { [unowned self] in self.errors.append(($0, $1)) }
        )
    }

    /// Returns a new `ErrorDialogFactoryCompletion` whose resolved outcome is appended to `resolvedOutcomes`.
    private func makeCompletion() -> ErrorDialogFactoryCompletion {
        ErrorDialogFactoryCompletion { [unowned self] outcome in
            self.resolvedOutcomes.append(outcome)
        }
    }

    private func makeParams(
        kind: CheckpointFailureKind = .flowCouldNotBeShown,
        errorCode: Int = 42
    ) -> ErrorPresentationParams {
        ErrorPresentationParams(
            checkpointIdentifier: "upgrade",
            error: NSError(domain: "TestDomain", code: errorCode,
                           userInfo: [NSLocalizedDescriptionKey: "something went wrong"]),
            customVariables: [:],
            kind: kind
        )
    }

    private func makeCustomer() -> CustomerInfo {
        CustomerInfo(entitlements: EntitlementInfos(entitlements: [:]),
                     requestDate: Date(timeIntervalSince1970: 0),
                     firstSeen: Date(timeIntervalSince1970: 0),
                     originalAppUserId: "user")
    }

    // MARK: - No-factory path tests

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

        try XCTUnwrap(self.starts.first).passed(
            CheckpointResult(flow: nil, customer: self.makeCustomer())
        )

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

    func testPassesEachPresentationModeToStart() throws {
        let expected: [(String?, FlowPresentationMode)] = [
            (CheckpointProxy.presentationModeFullScreen, .modalFullScreen),
            (CheckpointProxy.presentationModeSheet, .modalSheet),
            ("DEFAULT", .default),
            ("unknown", .default),
            (nil, .default)
        ]

        for (presentationMode, mode) in expected {
            self.starts = []
            self.present(presentationMode: presentationMode)

            let started = try XCTUnwrap(self.starts.first)
            XCTAssertEqual(started.mode, mode, "presentationMode: \(String(describing: presentationMode))")
        }
    }

    // MARK: - Factory path: basic behaviour

    func testFactoryPathReportsNotConfiguredAndDoesNotStart() {
        self.presentWithFactory(isConfigured: false)

        XCTAssertTrue(self.factoryStarts.isEmpty)
        XCTAssertEqual(self.errors.map(\.code), [CheckpointProxy.notConfiguredErrorCode])
    }

    func testFactoryPathStartsWithIdentifierAndDoesNotCallBackUntilPassed() {
        self.presentWithFactory()

        XCTAssertEqual(self.factoryStarts.map(\.identifier), ["upgrade"])
        XCTAssertTrue(self.passed.isEmpty)
        XCTAssertTrue(self.errors.isEmpty)
    }

    func testFactoryPathSerializesPassedResult() throws {
        self.presentWithFactory()

        try XCTUnwrap(self.factoryStarts.first).passed(
            CheckpointResult(flow: nil, customer: self.makeCustomer())
        )

        let result = try XCTUnwrap(self.passed.first)
        XCTAssertEqual(self.passed.count, 1)
        XCTAssertTrue(result["flow"] is NSNull)
        XCTAssertNotNil(result["customer"])
    }

    // MARK: - Factory path: onErrorDialogRequested

    func testFactoryCallsOnErrorDialogRequestedWithErrorDict() throws {
        self.presentWithFactory()
        let start = try XCTUnwrap(self.factoryStarts.first)

        start.factory?(self.makeParams(errorCode: 99), self.makeCompletion())

        let requested = try XCTUnwrap(self.requestedErrors.first)
        XCTAssertFalse(requested.requestId.isEmpty)
        XCTAssertEqual(requested.error["kind"] as? String, "flowCouldNotBeShown")
        XCTAssertEqual(requested.error["code"] as? Int, 99)
        XCTAssertEqual(requested.error["message"] as? String, "something went wrong")
    }

    func testFactorySerializesKindFlowCouldNotBeShown() throws {
        self.presentWithFactory()
        try XCTUnwrap(self.factoryStarts.first).factory?(
            self.makeParams(kind: .flowCouldNotBeShown), self.makeCompletion()
        )
        XCTAssertEqual(self.requestedErrors.first?.error["kind"] as? String, "flowCouldNotBeShown")
    }

    func testFactorySerializesKindFlowActionFailed() throws {
        self.presentWithFactory()
        try XCTUnwrap(self.factoryStarts.first).factory?(
            self.makeParams(kind: .flowActionFailed), self.makeCompletion()
        )
        XCTAssertEqual(self.requestedErrors.first?.error["kind"] as? String, "flowActionFailed")
    }

    func testFactorySerializesKindFlowResultSyncFailed() throws {
        self.presentWithFactory()
        try XCTUnwrap(self.factoryStarts.first).factory?(
            self.makeParams(kind: .flowResultSyncFailed), self.makeCompletion()
        )
        XCTAssertEqual(self.requestedErrors.first?.error["kind"] as? String, "flowResultSyncFailed")
    }

    // MARK: - Factory path: resolveErrorDialog

    func testResolveWithDialogContentCompletesWithDialog() throws {
        self.presentWithFactory()
        let start = try XCTUnwrap(self.factoryStarts.first)
        start.factory?(self.makeParams(), self.makeCompletion())
        let requestId = try XCTUnwrap(self.requestedErrors.first?.requestId)

        CheckpointProxy.resolveErrorDialog(
            requestId: requestId,
            outcome: ["type": "show", "dialog": ["message": "Try again", "buttonTitle": "OK"]]
        )

        XCTAssertEqual(self.resolvedOutcomes.count, 1)
        XCTAssertEqual(self.resolvedOutcomes[0], .show(CheckpointErrorDialog(message: "Try again", buttonTitle: "OK")))
    }

    func testResolveWithNilCompletesWithUseDefault() throws {
        self.presentWithFactory()
        let start = try XCTUnwrap(self.factoryStarts.first)
        start.factory?(self.makeParams(), self.makeCompletion())
        let requestId = try XCTUnwrap(self.requestedErrors.first?.requestId)

        CheckpointProxy.resolveErrorDialog(requestId: requestId, outcome: nil)

        XCTAssertEqual(self.resolvedOutcomes.count, 1)
        XCTAssertEqual(self.resolvedOutcomes[0], .useDefault)
    }

    func testResolveWithMissingButtonTitleFallsBackToUseDefault() throws {
        self.presentWithFactory()
        let start = try XCTUnwrap(self.factoryStarts.first)
        start.factory?(self.makeParams(), self.makeCompletion())
        let requestId = try XCTUnwrap(self.requestedErrors.first?.requestId)

        // dialog dict is missing "buttonTitle"
        CheckpointProxy.resolveErrorDialog(requestId: requestId, outcome: ["type": "show", "dialog": ["message": "Try again"]])

        XCTAssertEqual(self.resolvedOutcomes.count, 1)
        XCTAssertEqual(self.resolvedOutcomes[0], .useDefault)
    }

    func testResolveWithEmptyMessageFallsBackToUseDefault() throws {
        self.presentWithFactory()
        let start = try XCTUnwrap(self.factoryStarts.first)
        start.factory?(self.makeParams(), self.makeCompletion())
        let requestId = try XCTUnwrap(self.requestedErrors.first?.requestId)

        CheckpointProxy.resolveErrorDialog(requestId: requestId, outcome: ["type": "show", "dialog": ["message": "", "buttonTitle": "OK"]])

        XCTAssertEqual(self.resolvedOutcomes.count, 1)
        XCTAssertEqual(self.resolvedOutcomes[0], .useDefault)
    }

    func testResolveExplicitOutcomesAndInvalidPayloads() throws {
        let cases: [([String: Any], ErrorDialogFactoryOutcome)] = [
            (["type": "useDefault"], .useDefault),
            (["type": "suppress"], .suppress),
            (["type": "unknown"], .useDefault),
            ([:], .useDefault),
            (["type": 1], .useDefault),
            (["type": "show"], .useDefault),
            (["type": "show", "dialog": "invalid"], .useDefault),
            (["type": "show", "dialog": ["message": 1, "buttonTitle": "OK"]], .useDefault),
            (["type": "show", "dialog": ["message": "Oops", "buttonTitle": ""]], .useDefault)
        ]
        for (payload, expected) in cases {
            self.presentWithFactory()
            let start = try XCTUnwrap(self.factoryStarts.last)
            start.factory?(self.makeParams(), self.makeCompletion())
            let requestId = try XCTUnwrap(self.requestedErrors.last?.requestId)
            let previousCount = self.resolvedOutcomes.count

            CheckpointProxy.resolveErrorDialog(requestId: requestId, outcome: payload)

            XCTAssertEqual(self.resolvedOutcomes.count, previousCount + 1)
            XCTAssertEqual(self.resolvedOutcomes.last, expected, "Payload: \(payload)")
        }
    }

    func testSuppressIgnoresLaterResolutionsAndCancellation() throws {
        self.presentWithFactory()
        let start = try XCTUnwrap(self.factoryStarts.first)
        start.factory?(self.makeParams(), self.makeCompletion())
        let requestId = try XCTUnwrap(self.requestedErrors.first?.requestId)

        CheckpointProxy.resolveErrorDialog(requestId: requestId, outcome: ["type": "suppress"])
        CheckpointProxy.resolveErrorDialog(requestId: requestId, outcome: ["type": "useDefault"])
        CheckpointProxy.cancelErrorDialogs(callId: "call-1")

        XCTAssertEqual(self.resolvedOutcomes, [.suppress])
    }

    func testResolveUnknownRequestIdIsIgnored() {
        self.presentWithFactory()

        // Should not crash or produce a resolved dialog.
        CheckpointProxy.resolveErrorDialog(requestId: "unknown-request-id", outcome: nil)

        XCTAssertTrue(self.resolvedOutcomes.isEmpty)
    }

    func testResolveSecondCallForSameRequestIdIsIgnored() throws {
        self.presentWithFactory()
        let start = try XCTUnwrap(self.factoryStarts.first)
        start.factory?(self.makeParams(), self.makeCompletion())
        let requestId = try XCTUnwrap(self.requestedErrors.first?.requestId)

        CheckpointProxy.resolveErrorDialog(requestId: requestId, outcome: nil)
        // Second call — requestId has been removed from pendingRequests, so this is silently ignored.
        CheckpointProxy.resolveErrorDialog(
            requestId: requestId,
            outcome: ["type": "show", "dialog": ["message": "Try again", "buttonTitle": "OK"]]
        )

        XCTAssertEqual(self.resolvedOutcomes.count, 1)
    }

    func testSeveralErrorsAnsweredIndependently() throws {
        self.presentWithFactory(callId: "call-a")
        self.presentWithFactory(callId: "call-b")

        let startA = self.factoryStarts[0]
        let startB = self.factoryStarts[1]

        startA.factory?(self.makeParams(), self.makeCompletion())
        startB.factory?(self.makeParams(), self.makeCompletion())

        XCTAssertEqual(self.requestedErrors.count, 2)
        let requestIdA = self.requestedErrors[0].requestId
        let requestIdB = self.requestedErrors[1].requestId
        XCTAssertNotEqual(requestIdA, requestIdB)

        CheckpointProxy.resolveErrorDialog(
            requestId: requestIdA,
            outcome: ["type": "show", "dialog": ["message": "Error A", "buttonTitle": "Close"]]
        )
        CheckpointProxy.resolveErrorDialog(requestId: requestIdB, outcome: nil)

        XCTAssertEqual(self.resolvedOutcomes.count, 2)
        XCTAssertEqual(self.resolvedOutcomes[0], .show(CheckpointErrorDialog(message: "Error A", buttonTitle: "Close")))
        XCTAssertEqual(self.resolvedOutcomes[1], .useDefault)
    }

    // MARK: - Factory path: cancelErrorDialogs

    func testCancelForCallIdCompletesPendingRequestWithNil() throws {
        self.presentWithFactory(callId: "call-1")
        let start = try XCTUnwrap(self.factoryStarts.first)
        start.factory?(self.makeParams(), self.makeCompletion())

        CheckpointProxy.cancelErrorDialogs(callId: "call-1")

        XCTAssertEqual(self.resolvedOutcomes.count, 1)
        XCTAssertEqual(self.resolvedOutcomes[0], .useDefault)
    }

    func testCancelForCallIdDoesNotAffectOtherCallIds() throws {
        self.presentWithFactory(callId: "call-1")
        self.presentWithFactory(callId: "call-2")

        self.factoryStarts[0].factory?(self.makeParams(), self.makeCompletion())
        self.factoryStarts[1].factory?(self.makeParams(), self.makeCompletion())

        XCTAssertEqual(self.requestedErrors.count, 2)

        // Cancel only call-1.
        CheckpointProxy.cancelErrorDialogs(callId: "call-1")

        // Only call-1's request completed; call-2's is still pending.
        XCTAssertEqual(self.resolvedOutcomes.count, 1)

        // Resolve call-2 manually.
        let requestId2 = self.requestedErrors[1].requestId
        CheckpointProxy.resolveErrorDialog(requestId: requestId2, outcome: nil)
        XCTAssertEqual(self.resolvedOutcomes.count, 2)
    }

    func testCancelMarksCallIdDetachedSoSubsequentFactoryCallsCompleteWithUseDefaultImmediately() throws {
        self.presentWithFactory(callId: "call-1")

        // Cancel before any factory call.
        CheckpointProxy.cancelErrorDialogs(callId: "call-1")

        // Now trigger the factory — it should complete with UseDefault immediately without
        // calling onErrorDialogRequested.
        let start = try XCTUnwrap(self.factoryStarts.first)
        start.factory?(self.makeParams(), self.makeCompletion())

        XCTAssertTrue(self.requestedErrors.isEmpty)
        XCTAssertEqual(self.resolvedOutcomes.count, 1)
        XCTAssertEqual(self.resolvedOutcomes[0], .useDefault)
    }

    func testDetachedMarkerClearedWhenCallPasses() throws {
        self.presentWithFactory(callId: "call-1")

        // Mark the callId as detached.
        CheckpointProxy.cancelErrorDialogs(callId: "call-1")

        // Simulate the checkpoint passing — this clears the detached marker.
        try XCTUnwrap(self.factoryStarts.first).passed(
            CheckpointResult(flow: nil, customer: self.makeCustomer())
        )

        // A new call with the same callId should now work normally.
        self.presentWithFactory(callId: "call-1")
        try XCTUnwrap(self.factoryStarts.last).factory?(self.makeParams(), self.makeCompletion())

        // onErrorDialogRequested should have been called for the new factory invocation.
        XCTAssertEqual(self.requestedErrors.count, 1)
    }

    func testCancelNilCompleteAllPendingRequestsWithUseDefault() throws {
        self.presentWithFactory(callId: "call-a")
        self.presentWithFactory(callId: "call-b")

        self.factoryStarts[0].factory?(self.makeParams(), self.makeCompletion())
        self.factoryStarts[1].factory?(self.makeParams(), self.makeCompletion())

        XCTAssertEqual(self.requestedErrors.count, 2)

        CheckpointProxy.cancelErrorDialogs(callId: nil)

        XCTAssertEqual(self.resolvedOutcomes.count, 2)
        XCTAssertEqual(self.resolvedOutcomes[0], .useDefault)
        XCTAssertEqual(self.resolvedOutcomes[1], .useDefault)
    }

    func testCancelNilClearsAllDetachedMarkersAlreadySet() throws {
        // Mark call-1 as detached.
        CheckpointProxy.cancelErrorDialogs(callId: "call-1")

        // Cancel all — should also clear the existing detached marker for call-1.
        CheckpointProxy.cancelErrorDialogs(callId: nil)

        // A new call with call-1 should now work normally.
        self.presentWithFactory(callId: "call-1")
        try XCTUnwrap(self.factoryStarts.first).factory?(self.makeParams(), self.makeCompletion())

        XCTAssertEqual(self.requestedErrors.count, 1)
    }

}

#endif
