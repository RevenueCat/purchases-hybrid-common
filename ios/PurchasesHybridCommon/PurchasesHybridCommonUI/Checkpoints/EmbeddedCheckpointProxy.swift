//
//  EmbeddedCheckpointProxy.swift
//  PurchasesHybridCommonUI
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import Foundation
import PurchasesHybridCommon
import RevenueCat
@_spi(Internal) @_spi(InviteOnlyCheckpointsApi) import RevenueCatUI
import UIKit

/// Experimental. Runs checkpoints that purchases-ios embeds in a parent view controller the bridge supplies,
/// and turns the SDK's callbacks into bridge events keyed by the caller's `callId`.
///
/// Events are dictionaries with `callId` and `type`:
/// - `error`: `requestId`, `kind`, `error` (an `ErrorContainer.info`). The flow stays blocked until the bridge
///   calls ``completeError(callId:requestId:)``, so acknowledge only once the app's error UI is gone.
/// - `passed`: `result`, see ``CheckpointSerialization/dictionary(for:)``.
/// - `finished`: exactly once per call, last.
///
/// purchases-ios owns all containment: this proxy never adds, lays out, or removes views.
@available(iOS 15.0, *)
@MainActor
@objcMembers public final class EmbeddedCheckpointProxy: NSObject {

    public typealias Event = [String: Any]

    typealias Start = (
        String, [String: CustomVariableValue], UIViewController,
        @escaping ErrorPresentationHandler, @escaping (CheckpointResult) -> Void, @escaping () -> Void
    ) -> EmbeddedCheckpointExecution

    private let onEvent: (Event) -> Void
    private let startNative: Start
    private let makeRequestId: () -> String
    private let isConfigured: () -> Bool
    private var sessions: [String: Session] = [:]
    private var usedCallIds: Set<String> = []

    public convenience init(onEvent: @escaping (Event) -> Void) {
        self.init(
            onEvent: onEvent,
            start: { identifier, variables, parent, error, passed, finished in
                Purchases.shared.checkpoint(identifier, customVariables: variables, parentViewController: parent,
                                            errorPresenter: error, onPassed: passed, onFinished: finished)
            },
            makeRequestId: { UUID().uuidString },
            isConfigured: { Purchases.isConfigured }
        )
    }

    init(onEvent: @escaping (Event) -> Void, start: @escaping Start, makeRequestId: @escaping () -> String,
         isConfigured: @escaping () -> Bool) {
        self.onEvent = onEvent
        self.startNative = start
        self.makeRequestId = makeRequestId
        self.isConfigured = isConfigured
        super.init()
    }

    /// Whether a controller can contain a checkpoint right now: on screen, not an alert, not on its way out.
    public static func isUsableParent(_ controller: UIViewController?) -> Bool {
        guard let controller, !(controller is UIAlertController), controller.isViewLoaded,
              controller.view.window != nil, !controller.isBeingDismissed else { return false }
        return true
    }

    /// `parentViewController` is the controller the framework is showing. Passing `nil` or an unusable
    /// controller fails the call through an `error` event followed by `finished` once acknowledged.
    public func start(callId: String, identifier: String, customVariables: [String: Any]?,
                      parentViewController: UIViewController?) {
        // Never reuse a call id: a late acknowledgement must not reach a successor.
        guard self.usedCallIds.insert(callId).inserted else { return }
        let session = Session(id: callId)
        self.sessions[callId] = session
        guard self.isConfigured() else {
            self.fail(session, message: "Configure Purchases before calling a checkpoint.")
            return
        }
        guard let parentViewController, Self.isUsableParent(parentViewController) else {
            self.fail(session, message: "No presentable view controller is on screen to contain the checkpoint.")
            return
        }

        let execution = self.startNative(
            identifier,
            CheckpointSerialization.customVariables(from: customVariables),
            parentViewController,
            { [weak self, weak session] params, completion in
                guard let self, let session, self.isActive(session) else {
                    completion.complete()
                    return
                }
                let requestId = self.makeRequestId()
                session.errors[requestId] = { completion.complete() }
                self.emit(session, type: "error", payload: [
                    "requestId": requestId,
                    "kind": CheckpointSerialization.name(for: params.kind),
                    "error": ErrorContainer(error: params.error, extraPayload: [:]).info
                ])
            },
            { [weak self, weak session] result in
                guard let self, let session, self.isActive(session), !session.passed else { return }
                session.passed = true
                self.emit(session, type: "passed", payload: ["result": CheckpointSerialization.dictionary(for: result)])
            },
            { [weak self, weak session] in
                guard let self, let session else { return }
                self.finish(session)
            }
        )
        // The SDK may have finished synchronously during start.
        if self.isActive(session) {
            session.execution = execution
        }
    }

    public func cancel(callId: String) {
        guard let session = self.sessions[callId] else { return }
        if let execution = session.execution {
            execution.cancel()
        } else {
            self.finish(session)
        }
    }

    public func completeError(callId: String, requestId: String) {
        self.sessions[callId]?.errors.removeValue(forKey: requestId)?()
    }

    /// Cancels every call. For bridge teardown, when nothing can acknowledge anything anymore.
    public func cancelAll() {
        for session in Array(self.sessions.values) {
            self.cancel(callId: session.id)
            self.finish(session)
        }
    }

    private func fail(_ session: Session, message: String) {
        let error = NSError(domain: "PurchasesHybridCommon.EmbeddedCheckpoint", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: message])
        let requestId = self.makeRequestId()
        session.errors[requestId] = { [weak self, weak session] in
            guard let self, let session else { return }
            self.finish(session)
        }
        self.emit(session, type: "error", payload: [
            "requestId": requestId,
            "kind": CheckpointSerialization.name(for: .flowCouldNotBeShown),
            "error": ErrorContainer(error: error, extraPayload: [:]).info
        ])
    }

    private func finish(_ session: Session) {
        guard self.isActive(session) else { return }
        self.sessions.removeValue(forKey: session.id)
        let pending = Array(session.errors.values)
        session.errors.removeAll()
        pending.forEach { $0() }
        session.execution = nil
        self.emit(session, type: "finished")
    }

    private func isActive(_ session: Session) -> Bool {
        return self.sessions[session.id] === session
    }

    private func emit(_ session: Session, type: String, payload: Event = [:]) {
        var event = payload
        event["callId"] = session.id
        event["type"] = type
        self.onEvent(event)
    }

    @MainActor
    private final class Session {
        let id: String
        var execution: EmbeddedCheckpointExecution?
        var errors: [String: () -> Void] = [:]
        var passed = false
        init(id: String) { self.id = id }
    }

}
#endif
