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

    @objc
    public func createPaywallView() -> UIViewController {
        return UIHostingController(rootView: PaywallView())
    }

    @objc
    public func presentPaywall() {
        guard let rootController = UIApplication.shared.keyWindow?.rootViewController else {
            NSLog("Unable to find root UIViewController")
            return
        }

        let controller = PaywallViewController(displayCloseButton: true)
        controller.modalPresentationStyle = .pageSheet

        rootController.present(controller, animated: true)
    }

    @objc
    public func presentPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        _ = Task { @MainActor in
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                if !customerInfo.entitlements.active.keys.contains(requiredEntitlementIdentifier) {
                    self.presentPaywall()
                }
            } catch {
                NSLog("Failed presenting paywall: \(error)")
            }
        }
    }

}

@available(iOS 15.0, *)
extension PaywallProxy: PaywallViewControllerDelegate {

    public func paywallViewController(_ controller: PaywallViewController,
                                      didFinishPurchasingWith customerInfo: CustomerInfo) {
        controller.dismiss(animated: true)
    }

}

#endif
