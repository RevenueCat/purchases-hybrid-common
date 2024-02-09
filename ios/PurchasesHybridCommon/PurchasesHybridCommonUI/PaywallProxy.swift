//
//  PaywallProxy.swift
//  PurchasesHybridCommonUI
//
//  Created by Nacho Soto on 11/1/23.
//  Copyright © 2023 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Foundation
import SwiftUI
import PurchasesHybridCommon
import RevenueCat
import RevenueCatUI
import UIKit

@available(iOS 15.0, *)
@objcMembers public class PaywallProxy: NSObject {

    /// See ``PaywallViewControllerDelegateWrapper`` for receiving events.
    public weak var delegate: PaywallViewControllerDelegateWrapper?

    private var resultByVC: [PaywallViewController: (paywallResultHandler: (String) -> Void,
                                                     result: PaywallResult)] = [:]

    @objc
    public func createPaywallView() -> PaywallViewController {
        let controller = PaywallViewController()
        controller.delegate = self
        
        return controller
    }

    @objc
    public func createPaywallView(offeringIdentifier: String) -> PaywallViewController {
        let controller = PaywallViewController(offeringIdentifier: offeringIdentifier)
        controller.delegate = self

        return controller
    }

    @objc
    public func createFooterPaywallView() -> PaywallFooterViewController {
        let controller = PaywallFooterViewController()
        controller.delegate = self

        return controller
    }

    @objc
    public func createFooterPaywallView(offeringIdentifier: String) -> PaywallFooterViewController {
        let controller = PaywallFooterViewController(offeringIdentifier: offeringIdentifier)
        controller.delegate = self

        return controller
    }

    @objc
    public func presentPaywall(paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(paywallResultHandler: paywallResultHandler)
    }

    @objc
    public func presentPaywall(displayCloseButton: Bool, paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                   paywallResultHandler: paywallResultHandler)
    }

    @objc
    public func presentPaywall(offering: Offering, paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(content: .offering(offering),
                                   paywallResultHandler: paywallResultHandler)
    }

    @objc
    public func presentPaywall(offering: Offering,
                               displayCloseButton: Bool,
                               paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                   content: .offering(offering),
                                   paywallResultHandler: paywallResultHandler)
    }

    @objc
    public func presentPaywall(offeringIdentifier: String,
                               displayCloseButton: Bool,
                               paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                   content: .offeringIdentifier(offeringIdentifier),
                                   paywallResultHandler: paywallResultHandler)
    }

    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           paywallResultHandler: paywallResultHandler)
    }

    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       displayCloseButton: Bool,
                                       paywallResultHandler: @escaping (String) -> Void) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: displayCloseButton,
                                           paywallResultHandler: paywallResultHandler)
    }

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

    private func privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                               displayCloseButton: Bool = false,
                                               content: Content = .defaultOffering,
                                               paywallResultHandler: ((String) -> Void)? = nil) {
        _ = Task { @MainActor in
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                let shouldDisplay = !customerInfo.entitlements.active.keys.contains(requiredEntitlementIdentifier)
                if shouldDisplay {
                    self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                               content: content,
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
                                       paywallResultHandler: ((String) -> Void)? = nil) {
        guard let rootController = Self.rootViewController else {
            NSLog("Unable to find root UIViewController")
            return
        }

        let controller: PaywallViewController
        switch content {
        case let .offering(offering):
            controller = PaywallViewController(offering: offering, displayCloseButton: displayCloseButton)
        case let .offeringIdentifier(identifier):
            controller = PaywallViewController(offeringIdentifier: identifier, displayCloseButton: displayCloseButton)
        case .defaultOffering:
            controller = PaywallViewController(displayCloseButton: displayCloseButton)
        }

        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet

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
        case offeringIdentifier(String)
        case defaultOffering

    }

}

@available(iOS 15.0, *)
extension PaywallProxy: PaywallViewControllerDelegate {
    
    public func paywallViewControllerDidStartPurchase(_ controller: PaywallViewController) {
        self.delegate?.paywallViewControllerDidStartPurchase?(controller)
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

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishRestoringWith customerInfo: CustomerInfo) {
        self.resultByVC[controller]?.1 = .restored
        self.delegate?.paywallViewController?(controller, didFinishRestoringWith: customerInfo.dictionary)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFailRestoringWith error: NSError) {
        let errorContainer = ErrorContainer(error: error, extraPayload: [:])
        self.delegate?.paywallViewController?(controller, didFailRestoringWith: errorContainer.info)
    }

    public func paywallViewControllerWasDismissed(_ controller: PaywallViewController) {
        self.delegate?.paywallViewControllerWasDismissed?(controller)
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

}

#endif
