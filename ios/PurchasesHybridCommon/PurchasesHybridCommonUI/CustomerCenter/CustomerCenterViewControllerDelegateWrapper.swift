//
//  CustomerCenterViewControllerDelegateWrapper.swift
//  PurchasesHybridCommon
//
//  Created by Facundo Menzella on 17/2/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

#if os(iOS)

import Foundation
import RevenueCat
import RevenueCatUI

/// Delegate for ``RCCustomerCenterViewController`` that sends dictionaries instead of the original objects.
@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@objc(RCCustomerCenterViewControllerDelegateWrapper)
public protocol CustomerCenterViewControllerDelegateWrapper: AnyObject {

    /// Notifies that the ``CustomerCenterUIViewController`` was dismissed.
    @objc(customerCenterViewControllerWasDismissed:)
    optional func customerCenterViewControllerWasDismissed(_ controller: CustomerCenterUIViewController)

}

#endif
