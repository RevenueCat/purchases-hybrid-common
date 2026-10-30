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

    /// Maps requestId → pending error-dialog request. Must only be accessed from the main actor.
    @available(iOS 15.0, *)
    private static var pendingRequests: [String: PendingRequest] = [:]

    /// Set of callIds marked detached; requests for them immediately use the default dialog.
    /// Must only be accessed from the main actor.
    @available(iOS 15.0, *)
    private static var detachedCallIds: Set<String> = []

    // MARK: - Public API (no-factory path)

    /// Registers that `identifier` was hit, which may present a flow.
    ///
    /// - `onPassed` is called at most once, on the main actor, only when the user passes the checkpoint, with
    ///   `{ customer, flow: { obtainedEntitlements: [{ entitlementInfo }], obtainedProducts: [{ product }] } | null }`.
    ///   Backing out, a blocking failure, or another checkpoint owning presentation never calls it.
    /// - `onError` is called when the checkpoint could not be started: not configured, or below iOS 15.
    ///
    /// Custom variables support String, Number and Boolean values. Other values are ignored.
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

    /// Registers that `identifier` was hit, which may present a flow.
    ///
    /// Like the no-factory overload, but allows the hybrid to supply custom error dialog content.
    ///
    /// - `callId` is an opaque identifier for this particular call; used to cancel pending
    ///   requests when the JS runtime tears down.
    /// - `onErrorDialogRequested` is called (on the main thread) whenever the SDK wants to show
    ///   an error dialog. PHC passes a unique `requestId` and an `error` dictionary with keys:
    ///   `kind` (`"flowCouldNotBeShown"` | `"flowActionFailed"` | `"flowResultSyncFailed"`),
    ///   `code` (NSError code), `message` (localizedDescription).
    ///   The hybrid must call ``resolveErrorDialog(requestId:outcome:)`` exactly once.
    ///
    /// Custom variables support String, Number and Boolean values. Other values are ignored.
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
                // checkpoint(errorDialogFactory:) is @MainActor; dispatch onto the main actor.
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

    /// Applies the outcome for a pending error-dialog request identified by `requestId`.
    ///
    /// Must be called on the main thread. Unknown or already-answered request IDs are ignored.
    ///
    /// `outcome` is one of:
    /// - `{ type: "show", dialog: { message: String, buttonTitle: String } }` for custom dialog content.
    /// - `{ type: "useDefault" }` for the SDK's own localized dialog.
    /// - `{ type: "suppress" }` to continue without showing a dialog.
    ///
    /// Nil or invalid outcomes use the SDK's default dialog.
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
            return .show(CheckpointErrorDialog(message: message, buttonTitle: buttonTitle))
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

    /// Completes all pending error-dialog requests for `callId` with the SDK default outcome.
    ///
    /// Must be called on the main thread.
    ///
    /// - If `callId` is non-nil, only requests matching that callId are completed.
    ///   The callId is marked detached so future requests for it immediately use the SDK default outcome.
    /// - If `callId` is nil, ALL pending requests are completed with the SDK default outcome.
    ///
    /// The detached marker is cleared when the matching call's `onPassed` fires.
    @MainActor
    public static func cancelErrorDialogs(callId: String?) {
        guard #available(iOS 15.0, *) else { return }
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
        if let callId = callId {
            Self.detachedCallIds.insert(callId)
        } else {
            // Cancel all: clear all accumulated detached markers too.
            Self.detachedCallIds.removeAll()
        }
    }

    // MARK: - Internal testable core (no-factory path)

    /// The testable core of ``present(identifier:customVariables:presentationMode:onPassed:onError:)``.
    ///
    /// This is a separate overload because the public one must stay callable from hybrid SDKs that deploy to iOS 13,
    /// so it can't be `@available(iOS 15.0, *)` and can't mention iOS 15 types (`CustomVariableValue`,
    /// `FlowPresentationMode`, `CheckpointResult`) in its signature. This one can, which lets tests inject
    /// `isConfigured` and `start` instead of needing a configured `Purchases.shared`.
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

    /// The testable core of ``present(identifier:callId:customVariables:presentationMode:onPassed:onError:onErrorDialogRequested:)``.
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
        // The ErrorDialogFactory typealias is @MainActor, so this closure's body runs on the
        // main actor whenever the native SDK calls it.
        let factory: ErrorDialogFactory = { params, completion in
            // If the callId is detached (JS runtime torn down), immediately use the SDK default outcome.
            guard !Self.detachedCallIds.contains(callId) else {
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
            // When the call passes, clear the detached marker so future uses of the same callId
            // are not silently swallowed.
            Self.detachedCallIds.remove(callId)
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
