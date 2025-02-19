//
//  PaywallViewControllerWrapper.swift
//  PurchasesHybridCommonUI
//
//  Created by Cesar de la Vega on 2/2/24.
//
#if canImport(UIKit) && !os(tvOS) && !os(watchOS)

import Foundation
import RevenueCat
import RevenueCatUI

/// Delegate for ``PaywallViewController`` that sends dictionaries instead of the original objects.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
@objc(RCPaywallViewControllerDelegateWrapper)
public protocol PaywallViewControllerDelegateWrapper: AnyObject {

    /// Notifies that a purchase has started in a ``PaywallViewController``.
    @objc(paywallViewControllerDidStartPurchase:)
    optional func paywallViewControllerDidStartPurchase(_ controller: PaywallViewController)

    /// Notifies that a purchase has started in a ``PaywallViewController``.
    @objc(paywallViewController:didStartPurchaseWithPackage:)
    optional func paywallViewController(_ controller: PaywallViewController,
                                        didStartPurchaseWith packageDictionary: [String: Any])

    /// Notifies that a purchase has completed in a ``PaywallViewController``.
    @objc(paywallViewController:didFinishPurchasingWithCustomerInfoDictionary:)
    optional func paywallViewController(_ controller: PaywallViewController,
                                        didFinishPurchasingWith customerInfoDictionary: [String: Any])

    /// Notifies that a purchase has completed in a ``PaywallViewController``.
    @objc(paywallViewController:didFinishPurchasingWithCustomerInfoDictionary:transactionDictionary:)
    optional func paywallViewController(_ controller: PaywallViewController,
                                        didFinishPurchasingWith customerInfoDictionary: [String: Any],
                                        transaction transactionDictionary: [String: Any]?)

    /// Notifies that a purchase has been cancelled in a ``PaywallViewController``.
    @objc(paywallViewControllerDidCancelPurchase:)
    optional func paywallViewControllerDidCancelPurchase(_ controller: PaywallViewController)

    /// Notifies that the purchase operation has failed in a ``PaywallViewController``.
    @objc(paywallViewController:didFailPurchasingWithErrorDictionary:)
    optional func paywallViewController(_ controller: PaywallViewController,
                                        didFailPurchasingWith errorDictionary: [String: Any])

    /// Notifies that a restore has started in a ``PaywallViewController``.
    @objc(paywallViewControllerDidStartRestore:)
    optional func paywallViewControllerDidStartRestore(_ controller: PaywallViewController)

    /// Notifies that the restore operation has completed in a ``PaywallViewController``.
    ///
    /// - Warning: Receiving a ``CustomerInfo``does not imply that the user has any entitlements,
    /// simply that the process was successful. You must verify the ``CustomerInfo/entitlements``
    /// to confirm that they are active.
    @objc(paywallViewController:didFinishRestoringWithCustomerInfoDictionary:)
    optional func paywallViewController(_ controller: PaywallViewController,
                                        didFinishRestoringWith customerInfoDictionary: [String: Any])

    /// Notifies that the restore operation has failed in a ``PaywallViewController``.
    @objc(paywallViewController:didFailRestoringWithErrorDictionary:)
    optional func paywallViewController(_ controller: PaywallViewController,
                                        didFailRestoringWith errorDictionary: [String: Any])

    /// Notifies that the ``PaywallViewController`` has to be dismissed.
    /// - After close button is pressed if it's present
    /// - After a successful purchase
    /// Only called if the shouldAutomaticallyDismiss configuration option is set to false (true by default).
    @objc(paywallViewControllerRequestedDismissal:)
    optional func paywallViewControllerRequestedDismissal(_ controller: PaywallViewController)

    /// Notifies that the ``PaywallViewController`` was dismissed.
    @objc(paywallViewControllerWasDismissed:)
    optional func paywallViewControllerWasDismissed(_ controller: PaywallViewController)

    /// For internal use only.
    @objc(paywallViewController:didChangeSizeTo:)
    optional func paywallViewController(_ controller: PaywallViewController,
                                        didChangeSizeTo size: CGSize)

}

#endif
