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

    // MARK: - Public API (no-factory path)

    /// Registers a checkpoint hit. `onPassed` runs only when the user passes; `onError` reports setup failures.
    /// Custom variables accept String, Number, and Boolean values; other values are ignored.
    public static func present(
        identifier: String,
        customVariables: [String: Any]?,
        presentationMode: String?,
        onPassed: @escaping ([String: Any]) -> Void,
        onError: @escaping (_ code: String, _ message: String) -> Void
    ) {
        guard #available(iOS 15.0, *) else {
            let message = "Checkpoints require iOS 15 or later."
            NSLog("[RevenueCatUI] %@", message)
            onError(Self.unsupportedOSVersionErrorCode, message)
            return
        }
        Self.present(
            identifier: identifier,
            customVariables: customVariables,
            presentationMode: presentationMode,
            isConfigured: { Purchases.isConfigured },
            start: { identifier, variables, mode, passed in
                Purchases.shared.checkpoint(
                    identifier,
                    customVariables: variables,
                    presentationMode: mode,
                    errorPresenter: nil,
                    passed
                )
            },
            onPassed: onPassed,
            onError: onError
        )
    }

    // MARK: - Public API (error-dialog-factory path)

    /// Registers a checkpoint with custom error-dialog support. `callId` identifies the call for cancellation.
    /// The handler receives a unique request ID and an error (`kind`, `code`, and `message`); resolve it with
    /// ``resolveErrorDialog(requestId:outcome:)``. Custom variables accept String, Number, and Boolean values.
    public static func present(
        identifier: String,
        callId: String,
        customVariables: [String: Any]?,
        presentationMode: String?,
        onPassed: @escaping ([String: Any]) -> Void,
        onError: @escaping (_ code: String, _ message: String) -> Void,
        onErrorDialogRequested: @escaping (_ requestId: String, _ error: [String: Any]) -> Void
    ) {
        guard #available(iOS 15.0, *) else {
            let message = "Checkpoints require iOS 15 or later."
            NSLog("[RevenueCatUI] %@", message)
            onError(Self.unsupportedOSVersionErrorCode, message)
            return
        }
        Self.present(
            identifier: identifier,
            callId: callId,
            customVariables: customVariables,
            presentationMode: presentationMode,
            isConfigured: { Purchases.isConfigured },
            start: { identifier, variables, mode, factory, passed in
                Task { @MainActor in
                    Purchases.shared.checkpoint(
                        identifier,
                        customVariables: variables,
                        presentationMode: mode,
                        errorDialogFactory: factory,
                        passed
                    )
                }
            },
            onErrorDialogRequested: onErrorDialogRequested,
            onPassed: onPassed,
            onError: onError
        )
    }

    // MARK: - Error dialog resolution

    /// Resolves a pending request with `show` (message and button title), `useDefault`, or `suppress`.
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

    /// Cancels requests for `callId`, or all requests when nil. Canceled requests use the SDK default.
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

    // MARK: - Internal testable core (no-factory path)

    /// iOS 15 test seam; keeps the public overload compatible with iOS 13 clients and lets tests inject native calls.
    @available(iOS 15.0, *)
    static func present(
        identifier: String,
        customVariables: [String: Any]?,
        presentationMode: String?,
        isConfigured: () -> Bool,
        start: (
            String, [String: CustomVariableValue], FlowPresentationMode, @escaping (CheckpointResult) -> Void
        ) -> Void,
        onPassed: @escaping ([String: Any]) -> Void,
        onError: (_ code: String, _ message: String) -> Void
    ) {
        guard isConfigured() else {
            let message = "Configure Purchases before calling a checkpoint."
            NSLog("[RevenueCatUI] %@", message)
            onError(Self.notConfiguredErrorCode, message)
            return
        }
        let variables = (customVariables ?? [:]).compactMapValues(PaywallCustomVariables.value(from:))
        start(identifier, variables, Self.mode(for: presentationMode)) {
            onPassed(CheckpointSerialization.dictionary(for: $0))
        }
    }

    // MARK: - Internal testable core (error-dialog-factory path)

    /// iOS 15 test seam for the error-dialog overload.
    @available(iOS 15.0, *)
    static func present(
        identifier: String,
        callId: String,
        customVariables: [String: Any]?,
        presentationMode: String?,
        isConfigured: () -> Bool,
        start: (
            String,
            [String: CustomVariableValue],
            FlowPresentationMode,
            ErrorDialogFactory?,
            @escaping (CheckpointResult) -> Void
        ) -> Void,
        onErrorDialogRequested: @escaping (_ requestId: String, _ error: [String: Any]) -> Void,
        onPassed: @escaping ([String: Any]) -> Void,
        onError: (_ code: String, _ message: String) -> Void
    ) {
        guard isConfigured() else {
            let message = "Configure Purchases before calling a checkpoint."
            NSLog("[RevenueCatUI] %@", message)
            onError(Self.notConfiguredErrorCode, message)
            return
        }
        let variables = (customVariables ?? [:]).compactMapValues(PaywallCustomVariables.value(from:))
        let generation = Self.errorDialogGeneration
        let factory: ErrorDialogFactory = { params, completion in
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
        start(identifier, variables, Self.mode(for: presentationMode), factory) { result in
            if generation == Self.errorDialogGeneration {
                Self.detachedCallIds.remove(callId)
            }
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
