//
//  EmbeddedCheckpointProxyTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import XCTest
import UIKit
@testable import PurchasesHybridCommon
@testable import PurchasesHybridCommonUI
@_spi(Internal) @testable import RevenueCat
@_spi(Internal) @_spi(InviteOnlyCheckpointsApi) @testable import RevenueCatUI

@MainActor
@available(iOS 15.0, *)
final class EmbeddedCheckpointProxyTests: XCTestCase {

    private var events: [[String: Any]] = []
    private var calls: [Call] = []
    private var window: UIWindow!
    private var parent: UIViewController!

    override func setUp() {
        super.setUp()
        self.events = []
        self.calls = []
        self.parent = UIViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.rootViewController = self.parent
        self.window.makeKeyAndVisible()
        self.parent.loadViewIfNeeded()
    }

    override func tearDown() {
        self.window = nil
        self.parent = nil
        super.tearDown()
    }

    private func proxy(requestIds: [String] = ["error-A", "error-B"]) -> EmbeddedCheckpointProxy {
        var remaining = requestIds
        return EmbeddedCheckpointProxy(
            onEvent: { [weak self] in self?.events.append($0) },
            start: { [unowned self] identifier, variables, parent, error, passed, finished in
                let call = Call(identifier: identifier, variables: variables, parent: parent,
                                error: error, passed: passed, finished: finished)
                self.calls.append(call)
                return call.execution
            },
            makeRequestId: { remaining.isEmpty ? UUID().uuidString : remaining.removeFirst() },
            isConfigured: { true }
        )
    }

    private var types: [String] { self.events.compactMap { $0["type"] as? String } }

    func testStartForwardsIdentifierTypedVariablesAndParent() throws {
        let proxy = self.proxy()

        proxy.start(callId: "A", identifier: "rn_error_presenter_test", customVariables: [
            "name": "Ada", "enabled": true, "one": NSNumber(value: 1), "fraction": 2.5, "ignored": ["x"]
        ], parentViewController: self.parent)

        let call = try XCTUnwrap(self.calls.first)
        XCTAssertEqual(self.calls.count, 1)
        XCTAssertEqual(call.identifier, "rn_error_presenter_test")
        XCTAssertEqual(call.variables, ["name": .string("Ada"), "enabled": .bool(true),
                                        "one": .number(1), "fraction": .number(2.5)])
        XCTAssertTrue(call.parent === self.parent)
        XCTAssertTrue(self.events.isEmpty)
        proxy.cancelAll()
    }

    func testErrorsAreAcknowledgedOnceThroughTheirRequestId() throws {
        let proxy = self.proxy()
        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: self.parent)
        let call = try XCTUnwrap(self.calls.first)
        var completions = 0
        let error = NSError(domain: "test", code: 7, userInfo: [NSLocalizedDescriptionKey: "Boom"])

        call.error(.init(checkpointIdentifier: "test", error: error, customVariables: [:], kind: .flowActionFailed),
                   .init { completions += 1 })

        let event = try XCTUnwrap(self.events.first)
        XCTAssertEqual(event["callId"] as? String, "A")
        XCTAssertEqual(event["type"] as? String, "error")
        XCTAssertEqual(event["requestId"] as? String, "error-A")
        XCTAssertEqual(event["kind"] as? String, "flowActionFailed")
        let info = try XCTUnwrap(event["error"] as? [String: Any])
        XCTAssertEqual(info["message"] as? String, "Boom")
        XCTAssertNotNil(info["code"])
        XCTAssertTrue(JSONSerialization.isValidJSONObject(self.events))
        XCTAssertEqual(completions, 0)

        proxy.completeError(callId: "A", requestId: "unknown")
        proxy.completeError(callId: "B", requestId: "error-A")
        XCTAssertEqual(completions, 0)
        proxy.completeError(callId: "A", requestId: "error-A")
        proxy.completeError(callId: "A", requestId: "error-A")
        XCTAssertEqual(completions, 1)
        proxy.cancelAll()
    }

    func testPassedThenFinishedAreEmittedOnceAndLateCallbacksAreDropped() throws {
        let proxy = self.proxy()
        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: self.parent)
        let call = try XCTUnwrap(self.calls.first)

        call.passed(Self.result())
        call.finished()
        call.passed(Self.result())
        var lateCompletions = 0
        call.error(.init(checkpointIdentifier: "test", error: NSError(domain: "t", code: 1),
                         customVariables: [:], kind: .flowActionFailed),
                   .init { lateCompletions += 1 })

        XCTAssertEqual(self.types, ["passed", "finished"])
        let passed = try XCTUnwrap(self.events.first)
        let result = try XCTUnwrap(passed["result"] as? [String: Any])
        XCTAssertTrue(result["flow"] is NSNull)
        XCTAssertEqual((result["customer"] as? [String: Any])?["originalAppUserId"] as? String, "user")
        XCTAssertTrue(JSONSerialization.isValidJSONObject(self.events))
        // A late error after finish is completed on the SDK's behalf, never surfaced.
        XCTAssertEqual(lateCompletions, 1)
    }

    func testCancelFinishesAndReleasesPendingErrors() throws {
        let proxy = self.proxy()
        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: self.parent)
        let call = try XCTUnwrap(self.calls.first)
        var completions = 0
        call.error(.init(checkpointIdentifier: "test", error: NSError(domain: "t", code: 1),
                         customVariables: [:], kind: .flowActionFailed),
                   .init { completions += 1 })

        proxy.cancel(callId: "missing")
        XCTAssertEqual(self.types, ["error"])
        proxy.cancel(callId: "A")
        proxy.cancel(callId: "A")

        XCTAssertTrue(call.execution.isCancelled)
        XCTAssertEqual(self.types, ["error", "finished"])
        XCTAssertEqual(completions, 1)
        // The id is retired: a stale acknowledgement or restart cannot reach a successor.
        proxy.completeError(callId: "A", requestId: "error-A")
        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: self.parent)
        XCTAssertEqual(self.calls.count, 1)
    }

    func testCancelAllFinishesEverySessionWithoutEmittingAfterInvalidation() throws {
        let proxy = self.proxy()
        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: self.parent)
        proxy.start(callId: "B", identifier: "test", customVariables: [:], parentViewController: self.parent)
        XCTAssertEqual(self.calls.count, 2)

        proxy.cancelAll()

        XCTAssertEqual(self.calls.map(\.execution.isCancelled), [true, true])
        XCTAssertEqual(self.types.filter { $0 == "finished" }.count, 2)
        XCTAssertEqual(Set(self.events.compactMap { $0["callId"] as? String }), ["A", "B"])
    }

    func testUnusableParentFailsThroughAnErrorEventWithoutStartingNatively() throws {
        let proxy = self.proxy(requestIds: ["startup"])
        let offscreen = UIViewController()

        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: offscreen)

        XCTAssertTrue(self.calls.isEmpty)
        XCTAssertEqual(self.types, ["error"])
        let event = try XCTUnwrap(self.events.first)
        XCTAssertEqual(event["kind"] as? String, "flowCouldNotBeShown")
        XCTAssertEqual(event["requestId"] as? String, "startup")
        proxy.completeError(callId: "A", requestId: "startup")
        XCTAssertEqual(self.types, ["error", "finished"])
    }

    func testUnconfiguredSDKFailsThroughAnErrorEvent() {
        let proxy = EmbeddedCheckpointProxy(
            onEvent: { [weak self] in self?.events.append($0) },
            start: { _, _, _, _, _, _ in XCTFail("Must not start"); fatalError() },
            makeRequestId: { "r" },
            isConfigured: { false }
        )

        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: self.parent)

        XCTAssertEqual(self.types, ["error"])
        proxy.completeError(callId: "A", requestId: "r")
        XCTAssertEqual(self.types, ["error", "finished"])
    }

    func testNilParentFailsThroughAnErrorEvent() {
        let proxy = self.proxy()

        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: nil)

        XCTAssertTrue(self.calls.isEmpty)
        XCTAssertEqual(self.types, ["error"])
        proxy.cancelAll()
        XCTAssertEqual(self.types, ["error", "finished"])
    }

    func testAlertControllerIsNotAnAcceptableParent() {
        let proxy = self.proxy()
        let alert = UIAlertController(title: "t", message: nil, preferredStyle: .alert)
        self.parent.present(alert, animated: false)

        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: alert)

        XCTAssertTrue(self.calls.isEmpty)
        XCTAssertEqual(self.types, ["error"])
        proxy.cancelAll()
        self.parent.dismiss(animated: false)
    }

    func testDuplicateCallIdIsIgnored() {
        let proxy = self.proxy()
        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: self.parent)
        proxy.start(callId: "A", identifier: "other", customVariables: [:], parentViewController: self.parent)

        XCTAssertEqual(self.calls.count, 1)
        proxy.cancelAll()
    }

    func testSynchronousFinishDuringStartIsHandled() throws {
        let proxy = EmbeddedCheckpointProxy(
            onEvent: { [weak self] in self?.events.append($0) },
            start: { _, _, parent, _, _, finished in
                let execution = EmbeddedCheckpointExecution(parentViewController: parent, onFinished: finished)
                execution.cancel()
                return execution
            },
            makeRequestId: { "r" },
            isConfigured: { true }
        )

        proxy.start(callId: "A", identifier: "test", customVariables: [:], parentViewController: self.parent)

        XCTAssertEqual(self.types, ["finished"])
        proxy.cancel(callId: "A")
        XCTAssertEqual(self.types, ["finished"])
    }

    func testSerializationOfResultWithFlow() throws {
        let customer = Self.customerInfo()
        let result = CheckpointResult(
            flow: FlowResult(obtainedEntitlements: [], obtainedProducts: []),
            customer: customer
        )

        let dictionary = CheckpointSerialization.dictionary(for: result)

        let flow = try XCTUnwrap(dictionary["flow"] as? [String: Any])
        XCTAssertEqual((flow["obtainedEntitlements"] as? [Any])?.count, 0)
        XCTAssertEqual((flow["obtainedProducts"] as? [Any])?.count, 0)
        XCTAssertNotNil(dictionary["customer"] as? [String: Any])
        XCTAssertTrue(JSONSerialization.isValidJSONObject(dictionary))
    }

    // MARK: - Helpers

    @MainActor
    private final class Call {
        let identifier: String
        let variables: [String: CustomVariableValue]
        let parent: UIViewController
        let error: ErrorPresentationHandler
        let passed: (CheckpointResult) -> Void
        let finished: () -> Void
        let execution: EmbeddedCheckpointExecution

        init(identifier: String, variables: [String: CustomVariableValue], parent: UIViewController,
             error: @escaping ErrorPresentationHandler, passed: @escaping (CheckpointResult) -> Void,
             finished: @escaping () -> Void) {
            self.identifier = identifier
            self.variables = variables
            self.parent = parent
            self.error = error
            self.passed = passed
            self.finished = finished
            self.execution = EmbeddedCheckpointExecution(parentViewController: parent, onFinished: finished)
        }
    }

    private static func result() -> CheckpointResult {
        return CheckpointResult(flow: nil, customer: Self.customerInfo())
    }

    private static func customerInfo() -> CustomerInfo {
        return CustomerInfo(entitlements: EntitlementInfos(entitlements: [:]),
                            requestDate: Date(timeIntervalSince1970: 0),
                            firstSeen: Date(timeIntervalSince1970: 0),
                            originalAppUserId: "user")
    }

}
#endif
