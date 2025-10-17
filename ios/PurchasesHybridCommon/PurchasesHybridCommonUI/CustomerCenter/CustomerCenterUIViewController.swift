//
//  CustomerCenterViewController.swift
//  PurchasesHybridCommon
//
//  Created by Facundo Menzella on 17/2/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

#if os(iOS)

import Foundation
import PurchasesHybridCommon
import RevenueCat
import RevenueCatUI
import UIKit
import SwiftUI

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@objc
public final class CustomerCenterUIViewController: UIViewController {

    /// See ``CustomerCenterViewControllerDelegateWrapper`` for receiving events.
    @objc
    public weak var delegate: CustomerCenterViewControllerDelegateWrapper?

    /// Handler for when the navigation close button is tapped
    @objc
    public var onCloseHandler: (() -> Void)?

    /// Whether to show the close button in the navigation
    @objc
    public var shouldShowCloseButton: Bool = true

    @objc
    public required init() {
        super.init(nibName: nil, bundle: nil)
    }
      
    public override func viewDidLoad() {
        super.viewDidLoad()

        let vc = createHostingController()

        addChild(vc)

        view.subviews.forEach { $0.removeFromSuperview() }

        view.addSubview(vc.view)
        vc.didMove(toParent: self)

        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    public override func viewDidDisappear(_ animated: Bool) {
        if self.isBeingDismissed {
            self.delegate?.customerCenterViewControllerWasDismissed?(self)
        }
        super.viewDidDisappear(animated)
    }

    @available(*, unavailable, message: "Use init() and set delegate after initialization")
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Hosting Controller Creation

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension CustomerCenterUIViewController {

    func createHostingController() -> UIViewController {
        // Create the SwiftUI view with handlers that forward to the delegate
        let view = CustomerCenterView(
            navigationOptions: CustomerCenterNavigationOptions(
                shouldShowCloseButton: shouldShowCloseButton,
                onCloseHandler: onCloseHandler
            )
        )
        .onCustomerCenterRestoreStarted { [weak self] in
            guard let self = self else { return }
            self.delegate?.customerCenterViewControllerDidStartRestore?(self)
        }
        .onCustomerCenterRestoreCompleted { [weak self] customerInfo in
            guard let self = self else { return }
            let customerInfoDict = customerInfo.dictionary
            self.delegate?.customerCenterViewController?(self, didFinishRestoringWith: customerInfoDict)
        }
        .onCustomerCenterRestoreFailed { [weak self] error in
            guard let self = self else { return }
            let errorContainer = ErrorContainer(error: error, extraPayload: [:])
            self.delegate?.customerCenterViewController?(self, didFailRestoringWith: errorContainer.info)
        }
        .onCustomerCenterShowingManageSubscriptions { [weak self] in
            guard let self = self else { return }
            self.delegate?.customerCenterViewControllerDidShowManageSubscriptions?(self)
        }
        .onCustomerCenterRefundRequestStarted { [weak self] productID in
            guard let self = self else { return }
            self.delegate?.customerCenterViewController?(self, didStartRefundRequestForProductWithID: productID)
        }
        .onCustomerCenterRefundRequestCompleted { [weak self] (productID, status) in
            guard let self = self else { return }
            self.delegate?.customerCenterViewController?(self,
                                                         didCompleteRefundRequestForProductWithID: productID,
                                                         withStatus: status.name)
        }
        .onCustomerCenterFeedbackSurveyCompleted { [weak self] optionID in
            guard let self = self else { return }
            self.delegate?.customerCenterViewController?(self, didCompleteFeedbackSurveyWithOptionID: optionID)
        }
        .onCustomerCenterManagementOptionSelected { [weak self] action in
            guard let self = self else { return }
            if let customUrl = action as? CustomerCenterManagementOption.CustomUrl {
                self.delegate?.customerCenterViewController?(self,
                                                             didSelectCustomerCenterManagementOption: action.name,
                                                             withURL: customUrl.url.absoluteString)
            } else {
                self.delegate?.customerCenterViewController?(self,
                                                             didSelectCustomerCenterManagementOption: action.name,
                                                             withURL: nil)
            }
        }
        .onCustomerCenterCustomActionSelected { [weak self] actionIdentifier, purchaseIdentifier in
            guard let self = self else { return }
            self.delegate?.customerCenterViewController?(self, didSelectCustomAction: actionIdentifier, withPurchaseIdentifier: purchaseIdentifier)
        }
        
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = UIColor.clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        return controller
    }
}

// MARK: - CustomerCenterManagementOption Name Extension
@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension CustomerCenterActionable {
    
    var name: String {
        switch self {
        case is CustomerCenterManagementOption.Cancel:
            return "cancel"
        case is CustomerCenterManagementOption.CustomUrl:
            return "custom_url"
        case is CustomerCenterManagementOption.MissingPurchase:
            return "missing_purchase"
        case is CustomerCenterManagementOption.RefundRequest:
            return "refund_request"
        case is CustomerCenterManagementOption.ChangePlans:
            return "change_plans"
        default:
            return "unknown"
        }
    }
    
}

#endif
