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
final class CheckpointPaywallCall {
    let callId: String
    let errorGeneration: UUID

    init(callId: String, errorGeneration: UUID) {
        self.callId = callId
        self.errorGeneration = errorGeneration
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

    /// Main-actor-only set of detached call IDs.
    @available(iOS 15.0, *)
    private static var detachedCallIds: Set<String> = []

    // Public present calls may arrive off the main thread, before native work is dispatched.
    private static let errorDialogGenerationLock = NSLock()
    private static var currentErrorDialogGeneration = UUID()

    /// Factories from older generations remain detached after runtime invalidation.
    private static var errorDialogGeneration: UUID {
        get {
            Self.errorDialogGenerationLock.lock()
            defer { Self.errorDialogGenerationLock.unlock() }
            return Self.currentErrorDialogGeneration
        }
        set {
            Self.errorDialogGenerationLock.lock()
            defer { Self.errorDialogGenerationLock.unlock() }
            Self.currentErrorDialogGeneration = newValue
        }
    }

    // Calls are recorded before scheduling main-actor work, so runtime invalidation also cancels queued calls.
    @available(iOS 15.0, *)
    private static var paywallCalls: [String: CheckpointPaywallCall] = [:]
    @available(iOS 15.0, *)
    private static var pendingPaywalls: [String: (call: CheckpointPaywallCall,
                                                completion: PaywallPresentationCompletion)] = [:]

    @available(iOS 15.0, *)
    static func beginPaywallCall(callId: String) -> CheckpointPaywallCall {
        Self.errorDialogGenerationLock.lock()
        defer { Self.errorDialogGenerationLock.unlock() }
        let call = CheckpointPaywallCall(callId: callId, errorGeneration: Self.currentErrorDialogGeneration)
        Self.paywallCalls[callId] = call
        return call
    }

    @available(iOS 15.0, *)
    private static func isAttached(_ call: CheckpointPaywallCall) -> Bool {
        Self.errorDialogGenerationLock.lock()
        defer { Self.errorDialogGenerationLock.unlock() }
        return Self.paywallCalls[call.callId] === call
    }

    @available(iOS 15.0, *)
    private static func finish(_ call: CheckpointPaywallCall) {
        Self.errorDialogGenerationLock.lock()
        defer { Self.errorDialogGenerationLock.unlock() }
        if Self.paywallCalls[call.callId] === call {
            Self.paywallCalls.removeValue(forKey: call.callId)
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
        let call = Self.beginPaywallCall(callId: callId)
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
        Self.errorDialogGenerationLock.lock()
        Self.paywallCalls.removeValue(forKey: callId)
        Self.errorDialogGenerationLock.unlock()
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
        Self.errorDialogGenerationLock.lock()
        Self.currentErrorDialogGeneration = UUID()
        Self.paywallCalls.removeAll()
        Self.errorDialogGenerationLock.unlock()
        let pending = Array(Self.pendingPaywalls.values)
        Self.pendingPaywalls.removeAll()
        Self.detachedCallIds.removeAll()
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
    /// The call stays detached until it passes; nil invalidates existing factories so new calls can use a handler.
    @MainActor
    public static func cancelErrorDialogs(callId: String?) {
        guard #available(iOS 15.0, *) else { return }
        if let callId = callId {
            Self.detachedCallIds.insert(callId)
        } else {
            Self.errorDialogGeneration = UUID()
            Self.detachedCallIds.removeAll()
        }
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
        callId: String,
        generation: UUID,
        onErrorDialogRequested: @escaping (String, [String: Any]) -> Void
    ) -> ErrorDialogFactory {
        return { params, completion in
            // Detached calls may outlive the hybrid runtime; fall back to the SDK dialog.
            guard generation == Self.errorDialogGeneration,
                  !Self.detachedCallIds.contains(callId) else {
                completion.complete(with: .useDefault)
                return
            }
            let requestId = UUID().uuidString
            Self.pendingRequests[requestId] = PendingRequest(callId: callId, completion: completion)
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
        call: CheckpointPaywallCall? = nil
    ) {
        let call = call ?? Self.beginPaywallCall(callId: callId)
        guard Self.isAttached(call) else { return }
        guard isConfigured() else {
            Self.finish(call)
            onError(Self.notConfiguredErrorCode, "Configure Purchases before calling a checkpoint.")
            return
        }
        let generation = call.errorGeneration
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
            Self.makeErrorDialogFactory(callId: callId, generation: generation, onErrorDialogRequested: $0)
        }
        start(identifier, variables, Self.mode(for: presentationMode), presenter, factory) { result in
            guard Self.isAttached(call) else { return }
            Self.finish(call)
            if generation == Self.errorDialogGeneration { Self.detachedCallIds.remove(callId) }
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
