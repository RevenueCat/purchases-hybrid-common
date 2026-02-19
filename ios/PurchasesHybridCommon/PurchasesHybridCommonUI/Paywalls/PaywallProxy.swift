//
//  PaywallProxy.swift
//  PurchasesHybridCommonUI
//
//  Created by Nacho Soto on 11/1/23.
//  Copyright © 2023 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Foundation
import PurchasesHybridCommon
import RevenueCat
@_spi(Internal) import RevenueCatUI
import UIKit

@available(iOS 15.0, *)
@objcMembers public class PaywallViewCreationParams: NSObject {
    public var offeringIdentifier: String?
    public var presentedOfferingContext: [String: Any]?
    public var purchaseLogicBridge: HybridPurchaseLogicBridge?

    public override init() {
        super.init()
    }
}

@available(iOS 15.0, *)
@objcMembers public class PaywallProxy: NSObject {

    /// Keys for configuring paywall presentation options.
    /// Used by hybrid SDKs (Flutter, React Native, Unity, etc.) to pass configuration to native iOS.
    @objc public class PaywallOptionsKeys: NSObject {
        @objc public static let requiredEntitlementIdentifier = "requiredEntitlementIdentifier"
        @objc public static let offeringIdentifier = "offeringIdentifier"
        @objc public static let presentedOfferingContext = "presentedOfferingContext"
        @objc public static let displayCloseButton = "displayCloseButton"
        @objc public static let shouldBlockTouchEvents = "shouldBlockTouchEvents"
        @objc public static let fontName = "fontName"
        @objc public static let customVariables = "customVariables"
        /// When `true`, presents the paywall using `UIModalPresentationStyle.fullScreen` instead of `.pageSheet`.
        /// This is useful for ensuring the paywall covers the entire screen in landscape orientation,
        /// where `.pageSheet` leaves visible space on the sides.
        /// Defaults to `false` to preserve backwards compatibility.
        @objc public static let useFullScreenPresentation = "useFullScreenPresentation"
    }
    
    @objc public class PresentedOfferingContextKeys: NSObject {
        @objc public static let offeringIdentifier = "offeringIdentifier"
        @objc public static let placementIdentifier = "placementIdentifier"
        @objc public static let targetingContext = "targetingContext"
    }
    
    @objc public class PresentedOfferingTargetingContextKeys: NSObject {
        @objc public static let revision = "revision"
        @objc public static let ruleId = "ruleId"
    }

    /// See ``PaywallViewControllerDelegateWrapper`` for receiving events.
    public weak var delegate: PaywallViewControllerDelegateWrapper?

    private var resultByVC: [PaywallViewController: (paywallResultHandler: (String) -> Void,
                                                     result: PaywallResult)] = [:]
    private var requiredEntitlementIdentifierByVC: [PaywallViewController: String] = [:]
    private var purchaseLogicBridgeByVC: [PaywallViewController: HybridPurchaseLogicBridge] = [:]

    private static var pendingPurchaseInitiatedCallbacks: [String: (Bool) -> Void] = [:]

    @objc public static func resumePurchasePackageInitiated(requestId: String, shouldProceed: Bool) {
        guard let callback = pendingPurchaseInitiatedCallbacks.removeValue(forKey: requestId) else { return }
        callback(shouldProceed)
    }

    @objc
    public func createPaywallView(params: PaywallViewCreationParams) -> PaywallViewController {
        let dismissHandler = createDismissHandler()
        let controller: PaywallViewController

        switch (params.offeringIdentifier, params.purchaseLogicBridge) {
        case let (offeringId?, bridge?):
            controller = PaywallViewController(
                offeringIdentifier: offeringId,
                presentedOfferingContext: createPresentedOfferingContext(
                    for: offeringId, data: params.presentedOfferingContext
                ),
                performPurchase: bridge.makePerformPurchase(),
                performRestore: bridge.makePerformRestore(),
                dismissRequestedHandler: dismissHandler
            )
        case let (nil, bridge?):
            controller = PaywallViewController(
                fonts: DefaultPaywallFontProvider(),
                performPurchase: bridge.makePerformPurchase(),
                performRestore: bridge.makePerformRestore(),
                dismissRequestedHandler: dismissHandler
            )
        case let (offeringId?, nil):
            controller = PaywallViewController(
                offeringIdentifier: offeringId,
                presentedOfferingContext: createPresentedOfferingContext(
                    for: offeringId, data: params.presentedOfferingContext
                ),
                dismissRequestedHandler: dismissHandler
            )
        case (nil, nil):
            controller = PaywallViewController(dismissRequestedHandler: dismissHandler)
        }

        controller.delegate = self
        if let bridge = params.purchaseLogicBridge {
            purchaseLogicBridgeByVC[controller] = bridge
        }
        return controller
    }

    @objc
    public func createFooterPaywallView() -> PaywallFooterViewController {
        let controller = PaywallFooterViewController(dismissRequestedHandler: createDismissHandler())
        controller.delegate = self
        return controller
    }

    @objc
    public func createFooterPaywallView(offeringIdentifier: String, presentedOfferingContext: [String: Any]) -> PaywallFooterViewController {
        let controller = PaywallFooterViewController(
            offeringIdentifier: offeringIdentifier,
            presentedOfferingContext: createPresentedOfferingContext(
                for: offeringIdentifier,
                data: presentedOfferingContext
            ),
            dismissRequestedHandler: createDismissHandler()
        )
        controller.delegate = self
        return controller
    }


    @available(*, deprecated, message: "Use presentPaywall with purchaseLogicBridge instead")
    @objc
    public func presentPaywall(options: [String:Any],
                               paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywall(options: options,
                            purchaseLogicBridge: nil,
                            paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with purchaseLogicBridge instead")
    @objc
    public func presentPaywallIfNeeded(options: [String:Any],
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywallIfNeeded(options: options,
                                    purchaseLogicBridge: nil,
                                    paywallResultHandler: paywallResultHandler)
    }

    /// Presents a paywall with optional custom purchase logic.
    /// When `purchaseLogicBridge` is provided, the paywall delegates purchase and restore
    /// operations to the hybrid layer via the bridge's handlers.
    /// Use ``HybridPurchaseLogicBridge/resolveResult(requestId:resultString:errorMessage:)``
    /// to complete the operations.
    @objc
    public func presentPaywall(options: [String: Any],
                               purchaseLogicBridge: HybridPurchaseLogicBridge?,
                               paywallResultHandler: @escaping (String) -> Void) {
        let params = PaywallPresentationParams(options: options, content: createContent(from: options))
        self.privatePresentPaywall(params: params,
                                   purchaseLogicBridge: purchaseLogicBridge,
                                   paywallResultHandler: paywallResultHandler)
    }

    /// Presents a paywall only if the user does not have the specified entitlement,
    /// with optional custom purchase logic.
    /// See ``presentPaywall(options:purchaseLogicBridge:paywallResultHandler:)`` for details.
    @objc
    public func presentPaywallIfNeeded(options: [String: Any],
                                       purchaseLogicBridge: HybridPurchaseLogicBridge?,
                                       paywallResultHandler: @escaping (String) -> Void) {
        guard let requiredEntitlementIdentifier = options[PaywallOptionsKeys.requiredEntitlementIdentifier] as? String else {
            print("Error: missing required entitlement identifier.")
            return
        }

        let params = PaywallPresentationParams(options: options, content: createContent(from: options))

        _ = Task { @MainActor in
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                let shouldDisplay = !customerInfo.entitlements.active.keys.contains(requiredEntitlementIdentifier)
                if shouldDisplay {
                    self.privatePresentPaywall(params: params,
                                               purchaseLogicBridge: purchaseLogicBridge,
                                               requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                               paywallResultHandler: paywallResultHandler)
                } else {
                    paywallResultHandler(PaywallResult.notPresented.name)
                }
            } catch {
                NSLog("Failed presenting paywall: \(error)")
            }
        }
    }

    private func privatePresentPaywall(params: PaywallPresentationParams,
                                       purchaseLogicBridge: HybridPurchaseLogicBridge? = nil,
                                       requiredEntitlementIdentifier: String? = nil,
                                       paywallResultHandler: ((String) -> Void)? = nil) {
        guard var rootController = Self.rootViewController else {
            NSLog("Unable to find root UIViewController")
            return
        }

        // In case we are currently presenting a modal or any other
        // view controller get to the top of the chain.
        while let presentedVC = rootController.presentedViewController {
            rootController = presentedVC
        }

        let performPurchase = purchaseLogicBridge?.makePerformPurchase()
        let performRestore = purchaseLogicBridge?.makePerformRestore()

        let controller: PaywallViewController
        switch params.content {
        case let .offering(offering):
            controller = PaywallViewController(offering: offering,
                                               fonts: params.fontProvider,
                                               displayCloseButton: params.displayCloseButton,
                                               shouldBlockTouchEvents: params.shouldBlockTouchEvents,
                                               performPurchase: performPurchase,
                                               performRestore: performRestore)
        case let .offeringIdentifier(identifier):
            controller = PaywallViewController(offeringIdentifier: identifier,
                                               presentedOfferingContext: .init(offeringIdentifier: identifier),
                                               fonts: params.fontProvider,
                                               displayCloseButton: params.displayCloseButton,
                                               shouldBlockTouchEvents: params.shouldBlockTouchEvents,
                                               performPurchase: performPurchase,
                                               performRestore: performRestore)
        case let .offeringIdentifierWithPresentedOfferingContext(identifier, presentedOfferingContext):
            controller = PaywallViewController(offeringIdentifier: identifier,
                                               presentedOfferingContext: presentedOfferingContext,
                                               fonts: params.fontProvider,
                                               displayCloseButton: params.displayCloseButton,
                                               shouldBlockTouchEvents: params.shouldBlockTouchEvents,
                                               performPurchase: performPurchase,
                                               performRestore: performRestore)
        case .defaultOffering:
            controller = PaywallViewController(fonts: params.fontProvider,
                                               displayCloseButton: params.displayCloseButton,
                                               shouldBlockTouchEvents: params.shouldBlockTouchEvents,
                                               performPurchase: performPurchase,
                                               performRestore: performRestore)
        }

        params.customVariables?.forEach { key, value in
            // Currently only String values are supported. Other types will be supported in a future release.
            if let stringValue = value as? String {
                controller.setCustomVariable(stringValue, forKey: key)
            } else {
                NSLog("Custom variable '%@' has unsupported type %@. " +
                      "Only String values are currently supported. This variable will be ignored.",
                      key, String(describing: type(of: value)))
            }
        }

        controller.delegate = self
        controller.modalPresentationStyle = params.useFullScreenPresentation ? .fullScreen : .pageSheet
        controller.view.backgroundColor = .systemBackground

        if let purchaseLogicBridge {
            self.purchaseLogicBridgeByVC[controller] = purchaseLogicBridge
        }

        if let requiredEntitlementIdentifier {
            self.requiredEntitlementIdentifierByVC[controller] = requiredEntitlementIdentifier
        }

        if let paywallResultHandler {
            self.resultByVC[controller] = (paywallResultHandler, .cancelled)
        }

        rootController.present(controller, animated: true)
    }

    private static var rootViewController: UIViewController? {
        let scene = UIApplication
            .shared
            .connectedScenes
            .first { $0.activationState == .foregroundActive }

        guard let windowScene = scene as? UIWindowScene else { return nil }
        return windowScene.keyWindow?.rootViewController
    }

    private enum Content {

        case offering(Offering)
        case offeringIdentifierWithPresentedOfferingContext(String, presentedOfferingContext: PresentedOfferingContext)
        // `offeringIdentifierWithPresentedOfferingContext` is preferred, but this case is necessary for backwards compatibility
        case offeringIdentifier(String)
        case defaultOffering

    }

    private func createDismissHandler() -> (PaywallViewController) -> Void {
        return { [weak self] controller in
            guard let delegate = self?.delegate else { return }
            delegate.paywallViewControllerRequestedDismissal?(controller)
        }
    }
    
    private func createContent(from options: [String: Any]) -> Content {
        let offeringIdentifier = options[PaywallOptionsKeys.offeringIdentifier] as? String
        let presentedOfferingContext = createPresentedOfferingContext(
            from: (options[PaywallOptionsKeys.presentedOfferingContext] as? [String: Any]) ?? [:]
        )
        
        if let offeringIdentifier = offeringIdentifier, let presentedOfferingContext = presentedOfferingContext {
            return .offeringIdentifierWithPresentedOfferingContext(
                offeringIdentifier,
                presentedOfferingContext: presentedOfferingContext
            )
        }
        else if let offeringIdentifier = offeringIdentifier {
            return .offeringIdentifier(offeringIdentifier)
        } else {
            return .defaultOffering
        }
    }
    
    private func createPresentedOfferingContext(for offeringIdentifier: String, data: [String: Any]?) -> PresentedOfferingContext {
        data.flatMap { createPresentedOfferingContext(from: $0) } ?? .init(offeringIdentifier: offeringIdentifier)
    }

    private func createPresentedOfferingContext(from data: [String: Any]) -> PresentedOfferingContext? {
        guard let offeringIdentifier = data[PresentedOfferingContextKeys.offeringIdentifier] as? String else {
            return nil
        }
        return PresentedOfferingContext(
            offeringIdentifier: offeringIdentifier,
            placementIdentifier: data[PresentedOfferingContextKeys.placementIdentifier] as? String,
            targetingContext: (data[PresentedOfferingContextKeys.targetingContext] as? [String: Any]).flatMap {
                createPresentedOfferingContextTargetingContext(from: $0)
            }
        )
    }
    
    private func createPresentedOfferingContextTargetingContext(from data: [String: Any]) -> PresentedOfferingContext.TargetingContext? {
        guard let revision = data[PresentedOfferingTargetingContextKeys.revision] as? Int, let ruleId = data[PresentedOfferingTargetingContextKeys.ruleId] as? String else {
            return nil
        }
        return PresentedOfferingContext.TargetingContext(
            revision: revision,
            ruleId: ruleId
        )
    }

    /// Parsed paywall presentation parameters extracted from an options dictionary.
    private struct PaywallPresentationParams {
        let displayCloseButton: Bool
        let fontProvider: PaywallFontProvider
        let shouldBlockTouchEvents: Bool
        let customVariables: [String: Any]?
        let useFullScreenPresentation: Bool
        let content: Content

        init(options: [String: Any], content: Content) {
            self.displayCloseButton = options[PaywallOptionsKeys.displayCloseButton] as? Bool ?? false
            self.shouldBlockTouchEvents = options[PaywallOptionsKeys.shouldBlockTouchEvents] as? Bool ?? false
            self.customVariables = options[PaywallOptionsKeys.customVariables] as? [String: Any]
            self.useFullScreenPresentation = options[PaywallOptionsKeys.useFullScreenPresentation] as? Bool ?? false
            self.content = content

            if let fontName = options[PaywallOptionsKeys.fontName] as? String {
                self.fontProvider = CustomPaywallFontProvider(fontName: fontName)
            } else {
                self.fontProvider = DefaultPaywallFontProvider()
            }
        }
    }
}

@available(iOS 15.0, *)
extension PaywallProxy: PaywallViewControllerDelegate {

    public func paywallViewControllerDidStartPurchase(_ controller: PaywallViewController) {
        self.delegate?.paywallViewControllerDidStartPurchase?(controller)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didStartPurchaseWith package: Package) {
        self.delegate?.paywallViewController?(controller,
                                              didStartPurchaseWith: package.dictionary)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishPurchasingWith customerInfo: CustomerInfo) {
        self.resultByVC[controller]?.1 = .purchased
        self.delegate?.paywallViewController?(controller, didFinishPurchasingWith: customerInfo.dictionary)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishPurchasingWith customerInfo: CustomerInfo,
                                      transaction: StoreTransaction?) {
        self.delegate?.paywallViewController?(controller,
                                              didFinishPurchasingWith: customerInfo.dictionary,
                                              transaction: transaction?.dictionary)
    }

    public func paywallViewControllerDidCancelPurchase(_ controller: PaywallViewController) {
        self.delegate?.paywallViewControllerDidCancelPurchase?(controller)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFailPurchasingWith error: NSError) {
        let errorContainer = ErrorContainer(error: error, extraPayload: [:])
        self.delegate?.paywallViewController?(controller, didFailPurchasingWith: errorContainer.info)
    }

    public func paywallViewControllerDidStartRestore(_ controller: PaywallViewController) {
        self.delegate?.paywallViewControllerDidStartRestore?(controller)
        
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishRestoringWith customerInfo: CustomerInfo) {
        self.resultByVC[controller]?.1 = .restored
        self.delegate?.paywallViewController?(controller, didFinishRestoringWith: customerInfo.dictionary)

        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let customerInfo,
            let entitlementIdentifier = self.requiredEntitlementIdentifierByVC[controller],
                customerInfo.entitlements.active.keys.contains(entitlementIdentifier) {
                controller.dismiss(animated: true)
            }
        }
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFailRestoringWith error: NSError) {
        let errorContainer = ErrorContainer(error: error, extraPayload: [:])
        self.delegate?.paywallViewController?(controller, didFailRestoringWith: errorContainer.info)
    }

    public func paywallViewControllerWasDismissed(_ controller: PaywallViewController) {
        self.delegate?.paywallViewControllerWasDismissed?(controller)
        self.requiredEntitlementIdentifierByVC.removeValue(forKey: controller)
        self.purchaseLogicBridgeByVC.removeValue(forKey: controller)?.cancelPending()
        guard let (paywallResultHandler, result) = self.resultByVC.removeValue(forKey: controller) else { return }
        paywallResultHandler(result.name)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didChangeSizeTo size: CGSize) {
        self.delegate?.paywallViewController?(controller, didChangeSizeTo: size)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didInitiatePurchaseWith package: Package,
                                      resume: @escaping (Bool) -> Void) {
        let requestId = UUID().uuidString
        Self.pendingPurchaseInitiatedCallbacks[requestId] = resume
        self.delegate?.paywallViewController?(controller,
                                              didInitiatePurchaseWith: package.dictionary,
                                              requestId: requestId)
            ?? Self.resumePurchasePackageInitiated(requestId: requestId, shouldProceed: true)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      willPresentExitOfferController exitOfferController: PaywallViewController) {
        // Transfer result tracking from main paywall to exit offer controller.
        // This ensures the paywallResultHandler is called when the exit offer is dismissed.
        if let tracked = self.resultByVC.removeValue(forKey: controller) {
            self.resultByVC[exitOfferController] = tracked
        }
        if let entitlement = self.requiredEntitlementIdentifierByVC.removeValue(forKey: controller) {
            self.requiredEntitlementIdentifierByVC[exitOfferController] = entitlement
        }
        if let bridge = self.purchaseLogicBridgeByVC.removeValue(forKey: controller) {
            self.purchaseLogicBridgeByVC[exitOfferController] = bridge
        }

        self.delegate?.paywallViewController?(controller, willPresentExitOfferController: exitOfferController)
    }

}

// MARK: - Deprecations

@available(iOS 15.0, *)
extension PaywallProxy {

    @available(*, deprecated, message: "Use createPaywallView(params:) instead")
    @objc
    public func createPaywallView() -> PaywallViewController {
        return createPaywallView(params: PaywallViewCreationParams())
    }

    @available(*, deprecated, message: "Use createPaywallView(params:) instead")
    @objc
    public func createPaywallView(offeringIdentifier: String, presentedOfferingContext: [String: Any]) -> PaywallViewController {
        let params = PaywallViewCreationParams()
        params.offeringIdentifier = offeringIdentifier
        params.presentedOfferingContext = presentedOfferingContext
        return createPaywallView(params: params)
    }

    @available(*, deprecated, message: "use init with offeringIdentifier:presentedOfferingContext instead")
    @objc
    public func createPaywallView(offeringIdentifier: String) -> PaywallViewController {
        let controller = PaywallViewController(offeringIdentifier: offeringIdentifier,
                                               dismissRequestedHandler: createDismissHandler())
        controller.delegate = self
        return controller
    }
    
    @available(*, deprecated, message: "use init with offeringIdentifier:presentedOfferingContext instead")
    @objc
    public func createFooterPaywallView(offeringIdentifier: String) -> PaywallFooterViewController {
        let controller = PaywallFooterViewController(offeringIdentifier: offeringIdentifier,
                                                     dismissRequestedHandler: createDismissHandler())
        controller.delegate = self

        return controller
    }

    @available(*, deprecated, message: "Use presentPaywall with paywallResultHandler instead")
    @objc
    public func presentPaywall() {
        self.presentPaywall(options: [:], purchaseLogicBridge: nil, paywallResultHandler: { _ in })
    }

    @available(*, deprecated, message: "Use presentPaywall with paywallResultHandler instead")
    @objc
    public func presentPaywall(displayCloseButton: Bool) {
        self.presentPaywall(options: [PaywallOptionsKeys.displayCloseButton: displayCloseButton],
                            purchaseLogicBridge: nil,
                            paywallResultHandler: { _ in })
    }

    @available(*, deprecated, message: "Use presentPaywall with paywallResultHandler instead")
    @objc
    public func presentPaywall(offering: Offering) {
        self.presentPaywall(options: [:], purchaseLogicBridge: nil, paywallResultHandler: { _ in })
    }

    @available(*, deprecated, message: "Use presentPaywall with paywallResultHandler instead")
    @objc
    public func presentPaywall(offering: Offering, displayCloseButton: Bool) {
        self.presentPaywall(options: [PaywallOptionsKeys.displayCloseButton: displayCloseButton],
                            purchaseLogicBridge: nil,
                            paywallResultHandler: { _ in })
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywall(options: [:], purchaseLogicBridge: nil, paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(displayCloseButton: Bool, paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywall(options: [PaywallOptionsKeys.displayCloseButton: displayCloseButton],
                            purchaseLogicBridge: nil,
                            paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(offering: Offering, paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywall(options: [:], purchaseLogicBridge: nil, paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(offering: Offering,
                               displayCloseButton: Bool,
                               paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywall(options: [PaywallOptionsKeys.displayCloseButton: displayCloseButton],
                            purchaseLogicBridge: nil,
                            paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(offeringIdentifier: String,
                               displayCloseButton: Bool,
                               paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywall(options: [
            PaywallOptionsKeys.displayCloseButton: displayCloseButton,
            PaywallOptionsKeys.offeringIdentifier: offeringIdentifier,
        ], purchaseLogicBridge: nil, paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with paywallResultHandler instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        self.presentPaywallIfNeeded(
            options: [PaywallOptionsKeys.requiredEntitlementIdentifier: requiredEntitlementIdentifier],
            purchaseLogicBridge: nil,
            paywallResultHandler: { _ in })
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with paywallResultHandler instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       displayCloseButton: Bool) {
        self.presentPaywallIfNeeded(options: [
            PaywallOptionsKeys.requiredEntitlementIdentifier: requiredEntitlementIdentifier,
            PaywallOptionsKeys.displayCloseButton: displayCloseButton,
        ], purchaseLogicBridge: nil, paywallResultHandler: { _ in })
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with options instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywallIfNeeded(
            options: [PaywallOptionsKeys.requiredEntitlementIdentifier: requiredEntitlementIdentifier],
            purchaseLogicBridge: nil,
            paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with options instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       displayCloseButton: Bool,
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywallIfNeeded(options: [
            PaywallOptionsKeys.requiredEntitlementIdentifier: requiredEntitlementIdentifier,
            PaywallOptionsKeys.displayCloseButton: displayCloseButton,
        ], purchaseLogicBridge: nil, paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with options instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       offeringIdentifier: String,
                                       displayCloseButton: Bool,
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.presentPaywallIfNeeded(options: [
            PaywallOptionsKeys.requiredEntitlementIdentifier: requiredEntitlementIdentifier,
            PaywallOptionsKeys.displayCloseButton: displayCloseButton,
            PaywallOptionsKeys.offeringIdentifier: offeringIdentifier,
        ], purchaseLogicBridge: nil, paywallResultHandler: paywallResultHandler)
    }

}

#endif
