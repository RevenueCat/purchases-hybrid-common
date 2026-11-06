//
//  CheckpointProxy.swift
//  PurchasesHybridCommonUI
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if os(iOS) && !targetEnvironment(macCatalyst)

import Foundation
import PurchasesHybridCommon
import RevenueCat
@_spi(Internal) @_spi(InviteOnlyCheckpointsApi) import RevenueCatUI

@available(iOS 15.0, *)
final class CheckpointCall {
    let callId: String

    init(callId: String) {
        self.callId = callId
    }
}

/// Experimental, invite-only. Presents the dashboard-defined flow behind a checkpoint, if any.
@objcMembers public final class CheckpointProxy: NSObject {

    /// `presentationMode` values accepted by `present`.
    public static let presentationModeFullScreen = "MODAL_FULL_SCREEN"
    public static let presentationModeSheet = "MODAL_SHEET"

    public static let notConfiguredErrorCode = "NOT_CONFIGURED"
    public static let unsupportedOSVersionErrorCode = "UNSUPPORTED_OS_VERSION"

    // MARK: - Pending error-dialog requests

    @available(iOS 15.0, *)
    private struct PendingRequest {
        let callId: String
        let completion: ErrorDialogFactoryCompletion
    }

    /// Main-actor-only pending requests.
    @available(iOS 15.0, *)
    private static var pendingRequests: [String: PendingRequest] = [:]

    // Public present calls may arrive off the main thread, before native work is dispatched.
    private static let callsLock = NSLock()

    @available(iOS 15.0, *)
    private static var errorDialogCalls: [String: CheckpointCall] = [:]

    // Calls are recorded before scheduling main-actor work, so runtime invalidation also cancels queued calls.
    @available(iOS 15.0, *)
    private static var paywallCalls: [String: CheckpointCall] = [:]
    @available(iOS 15.0, *)
    private static var pendingPaywalls: [String: (call: CheckpointCall,
                                                completion: PaywallPresentationCompletion)] = [:]

    @available(iOS 15.0, *)
    static func beginCall(callId: String) -> CheckpointCall {
        Self.callsLock.lock()
        defer { Self.callsLock.unlock() }
        let call = CheckpointCall(callId: callId)
        Self.paywallCalls[callId] = call
        Self.errorDialogCalls[callId] = call
        return call
    }

    @available(iOS 15.0, *)
    private static func isAttached(_ call: CheckpointCall) -> Bool {
        Self.callsLock.lock()
        defer { Self.callsLock.unlock() }
        return Self.paywallCalls[call.callId] === call
    }

    @available(iOS 15.0, *)
    private static func isErrorDialogAttached(_ call: CheckpointCall) -> Bool {
        Self.callsLock.lock()
        defer { Self.callsLock.unlock() }
        return Self.errorDialogCalls[call.callId] === call
    }

    @available(iOS 15.0, *)
    private static func finish(_ call: CheckpointCall) {
        Self.callsLock.lock()
        defer { Self.callsLock.unlock() }
        if Self.paywallCalls[call.callId] === call {
            Self.paywallCalls.removeValue(forKey: call.callId)
        }
        if Self.errorDialogCalls[call.callId] === call {
            Self.errorDialogCalls.removeValue(forKey: call.callId)
        }
    }

    // MARK: - Presentation

    /// The hybrid wrapper calls this when the app hits a checkpoint. Native work runs on the main actor.
    /// Paywall presentation and error-dialog callbacks are independently optional.
    /// Use a unique `callId` for each invocation. A nil paywall callback uses the SDK presenter; a nil error callback
    /// uses its default error handling. Paywall requests contain `checkpointIdentifier`, primitive `customVariables`,
    /// resolved `presentationMode`, and the serialized `offering`. The wrapper owns dismissal and must complete
    /// every delivered presentation with ``completePaywallPresentation(requestId:result:)``.
    /// `onPassed` runs when the native checkpoint passes, after any required purchase synchronization;
    /// completing the paywall alone does not pass the checkpoint. `onError` reports failures to start the call.
    ///
    /// Call ``detachCheckpoint(callId:activePaywallRequestId:)`` when the owning screen stops listening, such as
    /// when a React Native screen unmounts. Call ``invalidateCheckpointPresentations()`` when the whole hybrid
    /// runtime reloads or shuts down.
    public static func present(
        identifier: String,
        callId: String,
        customVariables: [String: Any]?,
        presentationMode: String?,
        onPassed: @escaping ([String: Any]) -> Void,
        onError: @escaping (_ code: String, _ message: String) -> Void,
        onPaywallPresentationRequested: ((_ requestId: String, _ params: [String: Any]) -> Void)?,
        onErrorDialogRequested: ((_ requestId: String, _ error: [String: Any]) -> Void)?
    ) {
        guard #available(iOS 15.0, *) else {
            onError(Self.unsupportedOSVersionErrorCode, "Checkpoints require iOS 15 or later.")
            return
        }
        let call = Self.beginCall(callId: callId)
        Task { @MainActor in
            Self.present(
                identifier: identifier, callId: callId, customVariables: customVariables,
                presentationMode: presentationMode, isConfigured: { Purchases.isConfigured },
                start: { identifier, variables, mode, presenter, factory, passed in
                    Purchases.shared.checkpoint(identifier, customVariables: variables, presentationMode: mode,
                                                paywallPresenter: presenter, errorDialogFactory: factory, passed)
                },
                onPaywallPresentationRequested: onPaywallPresentationRequested,
                onErrorDialogRequested: onErrorDialogRequested, onPassed: onPassed, onError: onError,
                call: call
            )
        }
    }

    /// The wrapper calls this on the main actor after dismissing a paywall shown by its presentation handler.
    /// Use the `requestId` received by `onPaywallPresentationRequested` and report how that presentation ended.
    /// `CONTINUED` and `CLOSED` let the native flow proceed with purchase synchronization; neither directly calls
    /// `onPassed`. `NAVIGATED_BACK` and unrecognized values back out without passing the checkpoint.
    /// Complete every delivered presentation, including one preserved by `detachCheckpoint`, after dismissal.
    /// Repeated or unknown requests are ignored.
    @MainActor
    public static func completePaywallPresentation(requestId: String, result: String) {
        guard #available(iOS 15.0, *) else { return }
        guard let request = Self.pendingPaywalls.removeValue(forKey: requestId) else { return }
        switch result {
        case "CONTINUED": request.completion(.continued)
        case "CLOSED": request.completion(.closed)
        default:
            Self.finish(request.call)
            request.completion(.navigatedBack)
        }
    }

    /// The wrapper calls this on the main actor when it no longer listens for this checkpoint call.
    /// For example, a React Native screen can unmount while a separately presented paywall is still open.
    /// The wrapper calls this when cleaning up the screen and passes that paywall's request ID as
    /// `activePaywallRequestId`. This preserves the open presentation so the wrapper can dismiss it and call
    /// `completePaywallPresentation(requestId:result:)` afterward, without notifying the unmounted screen.
    ///
    /// Preserve only a request whose app-owned presentation handler has already run. All other pending paywall
    /// requests back out. Pass nil if there is no active presentation to preserve. Pending and future error
    /// requests use the SDK's default dialog, and late native presentation requests are rejected.
    @MainActor
    public static func detachCheckpoint(callId: String, activePaywallRequestId: String?) {
        guard #available(iOS 15.0, *) else { return }
        Self.callsLock.lock()
        Self.paywallCalls.removeValue(forKey: callId)
        Self.callsLock.unlock()
        Self.cancelErrorDialogs(callId: callId)
        let requestIds = Self.pendingPaywalls.compactMap { id, request in
            request.call.callId == callId && id != activePaywallRequestId ? id : nil
        }
        for id in requestIds {
            Self.completePaywallPresentation(requestId: id, result: "NAVIGATED_BACK")
        }
    }

    /// The wrapper calls this on the main actor when the whole hybrid runtime reloads or shuts down.
    /// For example, call it when the React Native bridge is invalidated, so pending native work cannot call
    /// JavaScript in the old runtime. Use `detachCheckpoint` instead when only one screen stops listening.
    ///
    /// All pending paywalls back out and error requests use the SDK's default dialogs. Calls from the old runtime
    /// remain invalid, including calls still waiting to start on the main actor. Calls from a new runtime work normally.
    @MainActor
    public static func invalidateCheckpointPresentations() {
        guard #available(iOS 15.0, *) else { return }
        Self.callsLock.lock()
        Self.paywallCalls.removeAll()
        Self.errorDialogCalls.removeAll()
        Self.callsLock.unlock()
        let pending = Array(Self.pendingPaywalls.values)
        Self.pendingPaywalls.removeAll()
        let errors = Array(Self.pendingRequests.values)
        Self.pendingRequests.removeAll()
        for request in errors { request.completion.complete(with: .useDefault) }
        for request in pending { request.completion(.navigatedBack) }
    }

    // MARK: - Error dialog resolution

    /// The wrapper calls this on the main actor after its error-dialog handler chooses an outcome.
    /// Use the `requestId` received by `onErrorDialogRequested`. `show` supplies a message and button title for
    /// the SDK to display, `useDefault` uses the SDK's default dialog, and `suppress` shows no dialog.
    /// Nil or invalid outcomes use the SDK default; unknown request IDs are ignored.
    @MainActor
    public static func resolveErrorDialog(requestId: String, outcome: [String: Any]?) {
        guard #available(iOS 15.0, *) else { return }
        guard let request = Self.pendingRequests.removeValue(forKey: requestId) else {
            NSLog("[RevenueCatUI] resolveErrorDialog: unknown or already-answered requestId '%@'", requestId)
            return
        }
        request.completion.complete(with: Self.errorDialogOutcome(from: outcome))
    }

    @available(iOS 15.0, *)
    private static func errorDialogOutcome(from outcome: [String: Any]?) -> ErrorDialogFactoryOutcome {
        guard let outcome = outcome else { return .useDefault }
        switch outcome["type"] as? String {
        case "useDefault":
            return .useDefault
        case "suppress":
            return .suppress
        case "show":
            guard let dialog = outcome["dialog"] as? [String: Any],
                  let message = dialog["message"] as? String,
                  let buttonTitle = dialog["buttonTitle"] as? String,
                  !message.isEmpty,
                  !buttonTitle.isEmpty else {
                return Self.invalidErrorDialogOutcome()
            }
            return .show(CheckpointErrorDialog(message: message, dismissButtonTitle: buttonTitle))
        default:
            return Self.invalidErrorDialogOutcome()
        }
    }

    @available(iOS 15.0, *)
    private static func invalidErrorDialogOutcome() -> ErrorDialogFactoryOutcome {
        NSLog("[RevenueCatUI] resolveErrorDialog: invalid outcome; falling back to SDK default.")
        return .useDefault
    }

    // MARK: - Cancellation

    /// The wrapper calls this on the main actor to stop custom error-dialog handling for `callId`, or all calls
    /// when nil. Canceled requests use the SDK's default dialog. This does not cancel paywall presentations;
    /// use `detachCheckpoint` when a screen stops listening or `invalidateCheckpointPresentations` on runtime reload.
    /// Canceled factories remain inactive; new checkpoint calls can install their own handlers.
    @MainActor
    public static func cancelErrorDialogs(callId: String?) {
        guard #available(iOS 15.0, *) else { return }
        Self.callsLock.lock()
        if let callId = callId {
            Self.errorDialogCalls.removeValue(forKey: callId)
        } else {
            Self.errorDialogCalls.removeAll()
        }
        Self.callsLock.unlock()
        var toCancel: [String] = []
        for (requestId, request) in Self.pendingRequests {
            if callId == nil || request.callId == callId {
                toCancel.append(requestId)
            }
        }
        for requestId in toCancel {
            if let request = Self.pendingRequests.removeValue(forKey: requestId) {
                request.completion.complete(with: .useDefault)
            }
        }
    }

    @available(iOS 15.0, *)
    private static func makeErrorDialogFactory(
        call: CheckpointCall,
        onErrorDialogRequested: @escaping (String, [String: Any]) -> Void
    ) -> ErrorDialogFactory {
        return { params, completion in
            // Detached calls may outlive the hybrid runtime; fall back to the SDK dialog.
            guard Self.isErrorDialogAttached(call) else {
                completion.complete(with: .useDefault)
                return
            }
            let requestId = UUID().uuidString
            Self.pendingRequests[requestId] = PendingRequest(callId: call.callId, completion: completion)
            let kind: String
            if params.kind == .flowCouldNotBeShown {
                kind = "flowCouldNotBeShown"
            } else if params.kind == .flowActionFailed {
                kind = "flowActionFailed"
            } else {
                kind = "flowResultSyncFailed"
            }
            let nsError = params.error as NSError
            let errorDict: [String: Any] = [
                "kind": kind,
                "code": nsError.code,
                "message": nsError.localizedDescription
            ]
            onErrorDialogRequested(requestId, errorDict)
        }
    }

    /// Testable presentation core with injectable native dependencies.
    @available(iOS 15.0, *)
    @MainActor
    static func present(
        identifier: String,
        callId: String,
        customVariables: [String: Any]?,
        presentationMode: String?,
        isConfigured: () -> Bool,
        start: (String, [String: CustomVariableValue], FlowPresentationMode,
                PaywallPresentationHandler?, ErrorDialogFactory?, @escaping (CheckpointResult) -> Void) -> Void,
        onPaywallPresentationRequested: ((String, [String: Any]) -> Void)?,
        onErrorDialogRequested: ((String, [String: Any]) -> Void)?,
        onPassed: @escaping ([String: Any]) -> Void,
        onError: (String, String) -> Void,
        call: CheckpointCall? = nil
    ) {
        let call = call ?? Self.beginCall(callId: callId)
        guard Self.isAttached(call) else { return }
        guard isConfigured() else {
            Self.finish(call)
            onError(Self.notConfiguredErrorCode, "Configure Purchases before calling a checkpoint.")
            return
        }
        let variables = (customVariables ?? [:]).compactMapValues(PaywallCustomVariables.value(from:))
        let presenter: PaywallPresentationHandler?
        if let onRequested = onPaywallPresentationRequested {
            presenter = { params, completion in
                guard Self.isAttached(call) else {
                    completion(.navigatedBack)
                    return
                }
                let requestId = UUID().uuidString
                Self.pendingPaywalls[requestId] = (call, completion)
                onRequested(requestId, CheckpointSerialization.dictionary(for: params,
                                                                         customVariables: customVariables ?? [:]))
            }
        } else {
            presenter = nil
        }
        let factory = onErrorDialogRequested.map {
            Self.makeErrorDialogFactory(call: call, onErrorDialogRequested: $0)
        }
        start(identifier, variables, Self.mode(for: presentationMode), presenter, factory) { result in
            guard Self.isAttached(call) else { return }
            Self.finish(call)
            onPassed(CheckpointSerialization.dictionary(for: result))
        }
    }

    @available(iOS 15.0, *)
    static func mode(for presentationMode: String?) -> FlowPresentationMode {
        switch presentationMode {
        case Self.presentationModeFullScreen: return .modalFullScreen
        case Self.presentationModeSheet: return .modalSheet
        default: return .default
        }
    }

}

#endif
