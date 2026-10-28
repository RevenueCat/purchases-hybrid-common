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

    /// `presentationMode` values accepted by ``present(identifier:customVariables:presentationMode:onPassed:onError:)``.
    public static let presentationModeFullScreen = "MODAL_FULL_SCREEN"
    public static let presentationModeSheet = "MODAL_SHEET"

    public static let notConfiguredErrorCode = "NOT_CONFIGURED"
    public static let unsupportedOSVersionErrorCode = "UNSUPPORTED_OS_VERSION"

    /// Registers that `identifier` was hit, which may present a flow. Call on the main thread.
    ///
    /// - `onPassed` is called at most once, only when the user passes the checkpoint, with
    ///   `{ customer, flow: { obtainedEntitlements: [{ entitlementInfo }], obtainedProducts: [{ product }] } | null }`.
    ///   Backing out, a blocking failure, or another checkpoint owning presentation never calls it.
    /// - `onError` is called when the checkpoint could not be started: not configured, or below iOS 15.
    ///
    /// Custom variables support String, Number and Boolean values. Other values are ignored.
    @MainActor
    public static func present(
        identifier: String,
        customVariables: [String: Any]?,
        presentationMode: String?,
        onPassed: @escaping ([String: Any]) -> Void,
        onError: @escaping (_ code: String, _ message: String) -> Void
    ) {
        guard #available(iOS 15.0, *) else {
            onError(Self.unsupportedOSVersionErrorCode, "Checkpoints require iOS 15 or later.")
            return
        }
        Self.present(
            identifier: identifier,
            customVariables: customVariables,
            presentationMode: presentationMode,
            isConfigured: { Purchases.isConfigured },
            start: { identifier, variables, mode, passed in
                Purchases.shared.checkpoint(identifier, customVariables: variables, presentationMode: mode) {
                    passed(CheckpointSerialization.dictionary(for: $0))
                }
            },
            onPassed: onPassed,
            onError: onError
        )
    }

    @available(iOS 15.0, *)
    @MainActor
    static func present(
        identifier: String,
        customVariables: [String: Any]?,
        presentationMode: String?,
        isConfigured: () -> Bool,
        start: (String, [String: CustomVariableValue], FlowPresentationMode, @escaping ([String: Any]) -> Void) -> Void,
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
        start(identifier, variables, Self.mode(for: presentationMode), onPassed)
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
