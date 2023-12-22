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

    @objc
    public func createPaywallView() -> UIViewController {
        return UIHostingController(rootView: PaywallView())
    }

    @objc
    public func presentPaywall() {
        presentPaywall(optionalDisplayCloseButton: nil)
    }

    @objc
    public func presentPaywall(displayCloseButton: Bool) {
        presentPaywall(optionalDisplayCloseButton: displayCloseButton)
    }

    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        presentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                               optionalDisplayCloseButton: nil)
    }

    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String, displayCloseButton: Bool) {
        presentPaywallIfNeeded(requiredEntitlementIdentifier: requiredEntitlementIdentifier,
                               optionalDisplayCloseButton: displayCloseButton)
    }

    private func presentPaywallIfNeeded(requiredEntitlementIdentifier: String, optionalDisplayCloseButton: Bool?) {
        _ = Task { @MainActor in
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                if !customerInfo.entitlements.active.keys.contains(requiredEntitlementIdentifier) {
                    if let displayCloseButton = optionalDisplayCloseButton {
                        self.presentPaywall(displayCloseButton: displayCloseButton)
                    } else {
                        self.presentPaywall()
                    }

                }
            } catch {
                NSLog("Failed presenting paywall: \(error)")
            }
        }
    }

    private func presentPaywall(optionalDisplayCloseButton: Bool?) {
        guard let rootController = UIApplication.shared.keyWindow?.rootViewController else {
            NSLog("Unable to find root UIViewController")
            return
        }

        let controller: PaywallViewController
        if let displayCloseButton = optionalDisplayCloseButton {
            controller = PaywallViewController(displayCloseButton: displayCloseButton)
        } else {
            controller = PaywallViewController()
        }

        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        rootController.present(controller, animated: true)
    }

}

@available(iOS 15.0, *)
extension PaywallProxy: PaywallViewControllerDelegate {

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishPurchasingWith customerInfo: CustomerInfo) {
        self.delegate?.paywallViewController?(controller, didFinishPurchasingWith: customerInfo)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishPurchasingWith customerInfo: CustomerInfo,
                                      transaction: StoreTransaction?) {
        self.delegate?.paywallViewController?(controller, didFinishPurchasingWith: customerInfo, transaction: transaction)
    }

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishRestoringWith customerInfo: CustomerInfo) {
        self.delegate?.paywallViewController?(controller, didFinishRestoringWith: customerInfo)
    }

    public func paywallViewControllerWasDismissed(_ controller: PaywallViewController) {
        self.delegate?.paywallViewControllerWasDismissed?(controller)
    }
}

#endif
