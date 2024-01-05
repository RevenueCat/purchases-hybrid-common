//
//  PaywallProxy.swift
//  PurchasesHybridCommon
//
//  Created by Nacho Soto on 11/1/23.
//  Copyright © 2023 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Foundation
import SwiftUI
import RevenueCat
import RevenueCatUI
import UIKit

@available(iOS 15.0, *)
@objcMembers public class PaywallProxy: NSObject {

    /// See ``PaywallViewControllerDelegate`` for receiving events.
    public weak var delegate: PaywallViewControllerDelegate?

    private var resultByVC: [PaywallViewController: (onPaywallResult: (String) -> Void, result: PaywallResult)] = [:]

    @objc
    public func createPaywallView() -> UIViewController {
        return UIHostingController(rootView: PaywallView())
    }

    @objc
    public func createFooterPaywallView() -> UIViewController {
        return PaywallFooterViewController()
    }

    @available(*, deprecated, message: "Use presentPaywall with onPaywallResult instead")
    @objc
    public func presentPaywall() {
        self.privatePresentPaywall(displayCloseButton: nil, offering: nil)
    }

    @available(*, deprecated, message: "Use presentPaywall with onPaywallResult instead")
    @objc
    public func presentPaywall(displayCloseButton: Bool) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton, offering: nil)
    }

    @available(*, deprecated, message: "Use presentPaywall with onPaywallResult instead")
    @objc
    public func presentPaywall(offering: Offering) {
        self.privatePresentPaywall(displayCloseButton: nil, offering: offering)
    }

    @available(*, deprecated, message: "Use presentPaywall with onPaywallResult instead")
    @objc
    public func presentPaywall(offering: Offering, displayCloseButton: Bool) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton, offering: offering)
    }

    @objc
    public func presentPaywall(onPaywallResult: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: nil, offering: nil, onPaywallResult: onPaywallResult)
    }

    @objc
    public func presentPaywall(displayCloseButton: Bool, onPaywallResult: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton, 
                                   offering: nil,
                                   onPaywallResult: onPaywallResult)
    }

    @objc
    public func presentPaywall(offering: Offering, onPaywallResult: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: nil, offering: offering, onPaywallResult: onPaywallResult)
    }

    @objc
    public func presentPaywall(offering: Offering,
                               displayCloseButton: Bool,
                               onPaywallResult: @escaping (String) -> Void) {
        self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                   offering: offering,
                                   onPaywallResult: onPaywallResult)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with onPaywallResult instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: nil,
                                           offering: nil,
                                           onPaywallResult: nil)
    }

    @available(*, deprecated, message: "Use presentPaywallIfNeeded with onPaywallResult instead")
    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String, 
                                       displayCloseButton: Bool) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: displayCloseButton,
                                           offering: nil,
                                           onPaywallResult: nil)
    }

    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       onPaywallResult: @escaping (String) -> Void) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: nil,
                                           offering: nil,
                                           onPaywallResult: onPaywallResult)
    }

    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                       displayCloseButton: Bool,
                                       onPaywallResult: @escaping (String) -> Void) {
        self.privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                                           displayCloseButton: displayCloseButton,
                                           offering: nil,
                                           onPaywallResult: onPaywallResult)
    }

    private func privatePresentPaywallIfNeeded(requiredEntitlementIdentifier: String,
                                               displayCloseButton: Bool?,
                                               offering: Offering?,
                                               onPaywallResult: ((String) -> Void)? = nil) {
        _ = Task { @MainActor in
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                let shouldDisplay = !customerInfo.entitlements.active.keys.contains(requiredEntitlementIdentifier)
                if shouldDisplay {
                    self.privatePresentPaywall(displayCloseButton: displayCloseButton,
                                        offering: offering)
                } else {
                    onPaywallResult?(PaywallResult.notPresented.name)
                }
            } catch {
                NSLog("Failed presenting paywall: \(error)")
            }
        }
    }

    private func privatePresentPaywall(displayCloseButton: Bool?,
                                       offering: Offering?,
                                       onPaywallResult: ((String) -> Void)? = nil) {
        guard let rootController = UIApplication.shared.keyWindow?.rootViewController else {
            NSLog("Unable to find root UIViewController")
            return
        }

        let controller: PaywallViewController
        if let displayCloseButton = displayCloseButton {
            controller = PaywallViewController(offering: offering, displayCloseButton: displayCloseButton)
        } else {
            controller = PaywallViewController()
        }

        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        if let onPaywallResult {
            self.resultByVC[controller] = (onPaywallResult, .cancelled)
        }
        rootController.present(controller, animated: true)
    }

}

@available(iOS 15.0, *)
extension PaywallProxy: PaywallViewControllerDelegate {

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishPurchasingWith customerInfo: CustomerInfo) {
        self.resultByVC[controller]?.1 = .purchased
        self.delegate?.paywallViewController?(controller, didFinishPurchasingWith: customerInfo)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishPurchasingWith customerInfo: CustomerInfo,
                                      transaction: StoreTransaction?) {
        self.delegate?.paywallViewController?(controller, didFinishPurchasingWith: customerInfo, transaction: transaction)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishRestoringWith customerInfo: CustomerInfo) {
        self.resultByVC[controller]?.1 = .restored
        self.delegate?.paywallViewController?(controller, didFinishRestoringWith: customerInfo)
    }

    public func paywallViewControllerWasDismissed(_ controller: PaywallViewController) {
        self.delegate?.paywallViewControllerWasDismissed?(controller)
        guard let (onPaywallResult, result) = self.resultByVC.removeValue(forKey: controller) else { return }
        onPaywallResult(result.name)
    }
}

#endif
