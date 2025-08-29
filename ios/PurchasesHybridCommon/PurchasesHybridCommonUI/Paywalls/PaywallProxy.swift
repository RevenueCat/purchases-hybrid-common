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
@objcMembers public class PaywallProxy: NSObject {

    @objc public class PaywallOptionsKeys: NSObject {
        @objc public static let requiredEntitlementIdentifier = "requiredEntitlementIdentifier"
        @objc public static let offeringIdentifier = "offeringIdentifier"
        @objc public static let presentedOfferingContext = "presentedOfferingContext"
        @objc public static let displayCloseButton = "displayCloseButton"
        @objc public static let shouldBlockTouchEvents = "shouldBlockTouchEvents"
        @objc public static let fontName = "fontName"
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

    @objc
    public func createPaywallView() -> PaywallViewController {
        let controller = PaywallViewController(dismissRequestedHandler: createDismissHandler())
        controller.delegate = self
        return controller
    }
    
    @objc
    public func createPaywallView(offeringIdentifier: String, presentedOfferingContext: [String: Any]) -> PaywallViewController {
        let controller = PaywallViewController(
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

    @objc
    public func presentPaywall(options: [String:Any],
                               paywallResultHandler: @escaping (String) -> Void) {
        let displayCloseButton = options[PaywallOptionsKeys.displayCloseButton] as? Bool ?? false,
            fontName = options[PaywallOptionsKeys.fontName] as? String,
            shouldBlockTouchEvents = options[PaywallOptionsKeys.shouldBlockTouchEvents] as? Bool ?? false
        
        self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                   content: createContent(from: options),
                                   fontName: fontName,
                                   shouldBlockTouchEvents: shouldBlockTouchEvents,
                                   paywallResultHandler: paywallResultHandler)
    }

    @objc
    public func presentPaywallIfNeeded(options: [String:Any],
                                       paywallResultHandler: @escaping (String) -> Void) {
        guard let requiredEntitlementIdentifier = options[PaywallOptionsKeys.requiredEntitlementIdentifier] as? String else {
            print("Error: missing required entitlement identifier.")
            return
        }

        let displayCloseButton = options[PaywallOptionsKeys.displayCloseButton] as? Bool ?? false,
            fontName = options[PaywallOptionsKeys.fontName] as? String,
            shouldBlockTouchEvents = options[PaywallOptionsKeys.shouldBlockTouchEvents] as? Bool ?? false

        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: displayCloseButton,
                                           content: createContent(from: options),
                                           fontName: fontName,
                                           shouldBlockTouchEvents: shouldBlockTouchEvents,
                                           paywallResultHandler: paywallResultHandler)
    }

    private func privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                               displayCloseButton: Bool = false,
                                               content: Content = .defaultOffering,
                                               fontName: String? = nil,
                                               shouldBlockTouchEvents: Bool = false,
                                               paywallResultHandler: ((String) -> Void)? = nil) {
        _ = Task { @MainActor in
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                let shouldDisplay = !customerInfo.entitlements.active.keys.contains(requiredEntitlementIdentifier)
                if shouldDisplay {
                    self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                               content: content,
                                               fontName: fontName,
                                               shouldBlockTouchEvents: shouldBlockTouchEvents,
                                               requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                               paywallResultHandler: paywallResultHandler)
                } else {
                    paywallResultHandler?(PaywallResult.notPresented.name)
                }
            } catch {
                NSLog("Failed presenting paywall: \(error)")
            }
        }
    }

    private func privatePresentPaywall(displayCloseButton: Bool = false,
                                       content: Content = .defaultOffering,
                                       fontName: String? = nil,
                                       shouldBlockTouchEvents: Bool = false,
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

        let fontProvider: PaywallFontProvider
        if let fontName = fontName {
            fontProvider = CustomPaywallFontProvider(fontName: fontName)
        } else {
            fontProvider = DefaultPaywallFontProvider()
        }

        let controller: PaywallViewController
        switch content {
        case let .offering(offering):
            controller = PaywallViewController(offering: offering, 
                                               fonts: fontProvider,
                                               displayCloseButton: displayCloseButton,
                                               shouldBlockTouchEvents: shouldBlockTouchEvents)
        case let .offeringIdentifier(identifier):
            controller = PaywallViewController(offeringIdentifier: identifier,
                                               presentedOfferingContext: .init(offeringIdentifier: identifier),
                                               fonts: fontProvider,
                                               displayCloseButton: displayCloseButton,
                                               shouldBlockTouchEvents: shouldBlockTouchEvents)
        case let .offeringIdentifierWithPresentedOfferingContext(identifier, presentedOfferingContext):
            controller = PaywallViewController(offeringIdentifier: identifier,
                                               presentedOfferingContext: presentedOfferingContext,
                                               fonts: fontProvider,
                                               displayCloseButton: displayCloseButton,
                                               shouldBlockTouchEvents: shouldBlockTouchEvents)
        case .defaultOffering:
            controller = PaywallViewController(fonts: fontProvider, 
                                               displayCloseButton: displayCloseButton,
                                               shouldBlockTouchEvents: shouldBlockTouchEvents)
        }

        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        controller.view.backgroundColor = .systemBackground

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
        guard let (paywallResultHandler, result) = self.resultByVC.removeValue(forKey: controller) else { return }
        paywallResultHandler(result.name)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didChangeSizeTo size: CGSize) {
        self.delegate?.paywallViewController?(controller, didChangeSizeTo: size)
    }

}

// MARK: - Deprecations

@available(iOS 15.0, *)
extension PaywallProxy {
    
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
        self.privatePresentPaywall()
    }

    @available(*, deprecated, message: "Use presentPaywall with paywallResultHandler instead")
    @objc
    public func presentPaywall(displayCloseButton: Bool) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton)
    }

    @available(*, deprecated, message: "Use presentPaywall with paywallResultHandler instead")
    @objc
    public func presentPaywall(offering: Offering) {
        self.privatePresentPaywall(content: .offering(offering))
    }

    @available(*, deprecated, message: "Use presentPaywall with paywallResultHandler instead")
    @objc
    public func presentPaywall(offering: Offering, displayCloseButton: Bool) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton, content: .offering(offering))
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(displayCloseButton: Bool, paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                   paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(offering: Offering, paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(content: .offering(offering),
                                   paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(offering: Offering,
                               displayCloseButton: Bool,
                               paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                   content: .offering(offering),
                                   paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywall with options instead")
    @objc
    public func presentPaywall(offeringIdentifier: String,
                               displayCloseButton: Bool,
                               paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                   content: .offeringIdentifier(offeringIdentifier),
                                   paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with paywallResultHandler instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           paywallResultHandler: nil)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with paywallResultHandler instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       displayCloseButton: Bool) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: displayCloseButton,
                                           paywallResultHandler: nil)
    }
    
    @available(*, deprecated, message: "Use presentPaywallIfNeeded with options instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with options instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       displayCloseButton: Bool,
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: displayCloseButton,
                                           paywallResultHandler: paywallResultHandler)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with options instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       offeringIdentifier: String,
                                       displayCloseButton: Bool,
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: displayCloseButton,
                                           content: .offeringIdentifier(offeringIdentifier),
                                           paywallResultHandler: paywallResultHandler)
    }

}

#endif
