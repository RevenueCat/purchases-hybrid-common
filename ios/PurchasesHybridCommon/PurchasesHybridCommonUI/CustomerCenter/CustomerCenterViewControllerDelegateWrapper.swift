//
//  CustomerCenterViewControllerDelegateWrapper.swift
//  PurchasesHybridCommonUI
//
//  Created by Facundo Menzella on 17/2/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

#if os(iOS)

import Foundation
import RevenueCat
import RevenueCatUI

/// Delegate for ``CustomerCenterUIViewController`` that sends dictionaries instead of the original objects.
@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@objc(RCCustomerCenterViewControllerDelegateWrapper)
public protocol CustomerCenterViewControllerDelegateWrapper: AnyObject {

    /// Notifies that a restore operation has started in the Customer Center.
    @objc(customerCenterViewControllerDidStartRestore:)
    optional func customerCenterViewControllerDidStartRestore(_ controller: CustomerCenterUIViewController)
    
    /// Notifies that a restore operation has completed successfully in the Customer Center.
    @objc(customerCenterViewController:didFinishRestoringWithCustomerInfoDictionary:)
    optional func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didFinishRestoringWith customerInfoDictionary: [String: Any])
    
    /// Notifies that a restore operation has failed in the Customer Center.
    @objc(customerCenterViewController:didFailRestoringWithErrorDictionary:)
    optional func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                            didFailRestoringWith errorDictionary: [String: Any])
    
    /// Notifies that the user is navigating to manage subscriptions in the Customer Center.
    @objc(customerCenterViewControllerDidShowManageSubscriptions:)
    optional func customerCenterViewControllerDidShowManageSubscriptions(_ controller: CustomerCenterUIViewController)
    
    /// Notifies that a refund request has started in the Customer Center.
    @objc(customerCenterViewController:didStartRefundRequestForProductWithID:)
    optional func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                            didStartRefundRequestForProductWithID productID: String)
    
    /// Notifies that a refund request has completed in the Customer Center.
    @objc(customerCenterViewController:didCompleteRefundRequestWithStatusDictionary:)
    optional func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                            didCompleteRefundRequestWithStatus statusDictionary: [String: Any])
    
    /// Notifies that a feedback survey has been completed in the Customer Center.
    @objc(customerCenterViewController:didCompleteFeedbackSurveyWithOptionID:)
    optional func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                            didCompleteFeedbackSurveyWithOptionID optionID: String)
    
    /// Notifies that the ``CustomerCenterUIViewController`` was dismissed.
    @objc(customerCenterViewControllerWasDismissed:)
    optional func customerCenterViewControllerWasDismissed(_ controller: CustomerCenterUIViewController)

}

#endif
