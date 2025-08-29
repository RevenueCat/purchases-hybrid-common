//
//  CustomerCenterProxy.swift
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

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@objc
public class CustomerCenterProxy: NSObject {

    /// See ``CustomerCenterViewControllerDelegateWrapper`` for receiving events.
    @objc
    public weak var delegate: CustomerCenterViewControllerDelegateWrapper?

    /// Whether to show the close button in the navigation
    @objc
    public var shouldShowCloseButton: Bool = true
    
    @objc public func present(
        resultHandler: @escaping () -> Void
    ) {
        guard let rootController = Self.rootViewController else {
            return
        }
        let vc = createCustomerCenterViewController()
        resultByVC[vc] = resultHandler

        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = .clear

        rootController.present(vc, animated: true)
    }

    // MARK: - Private

    private var resultByVC: [CustomerCenterUIViewController: (() -> Void)] = [:]
}

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension CustomerCenterProxy: CustomerCenterViewControllerDelegateWrapper {

    public func customerCenterViewControllerWasDismissed(_ controller: CustomerCenterUIViewController) {
        self.delegate?.customerCenterViewControllerWasDismissed?(controller)
        guard let resultHandler = self.resultByVC.removeValue(forKey: controller) else { return }
        resultHandler()
    }
    
    public func customerCenterViewControllerDidStartRestore(_ controller: CustomerCenterUIViewController) {
        self.delegate?.customerCenterViewControllerDidStartRestore?(controller)
    }
    
    public func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didFinishRestoringWith customerInfoDictionary: [String: Any]) {
        self.delegate?.customerCenterViewController?(controller, didFinishRestoringWith: customerInfoDictionary)
    }
    
    public func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didFailRestoringWith errorDictionary: [String: Any]) {
        self.delegate?.customerCenterViewController?(controller, didFailRestoringWith: errorDictionary)
    }
    
    public func customerCenterViewControllerDidShowManageSubscriptions(_ controller: CustomerCenterUIViewController) {
        self.delegate?.customerCenterViewControllerDidShowManageSubscriptions?(controller)
    }
    
    public func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didStartRefundRequestForProductWithID productID: String) {
        self.delegate?.customerCenterViewController?(controller, didStartRefundRequestForProductWithID: productID)
    }
    
    public func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didCompleteRefundRequestForProductWithID productId: String,
                                             withStatus status: String) {
        self.delegate?.customerCenterViewController?(controller, didCompleteRefundRequestForProductWithID: productId, withStatus: status)
    }
    
    public func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didSelectCustomerCenterManagementOption optionID: String,
                                             withURL url: String?) {
        self.delegate?.customerCenterViewController?(controller, didSelectCustomerCenterManagementOption: optionID, withURL: url)
    }
    
    public func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didCompleteFeedbackSurveyWithOptionID optionID: String) {
        self.delegate?.customerCenterViewController?(controller, didCompleteFeedbackSurveyWithOptionID: optionID)
    }
    
    public func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didSelectCustomAction actionID: String,
                                             withPurchaseIdentifier purchaseIdentifier: String?) {
        self.delegate?.customerCenterViewController?(controller, didSelectCustomAction: actionID, withPurchaseIdentifier: purchaseIdentifier)
    }
}

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
private extension CustomerCenterProxy {

    static var rootViewController: UIViewController? {
        let scene = UIApplication
            .shared
            .connectedScenes
            .first { $0.activationState == .foregroundActive }

        guard let windowScene = scene as? UIWindowScene else { return nil }
        return windowScene.keyWindow?.rootViewController
    }

    func createCustomerCenterViewController() -> CustomerCenterUIViewController {
        let vc = CustomerCenterUIViewController()
        vc.delegate = self
        vc.shouldShowCloseButton = shouldShowCloseButton

        return vc
    }
}

#endif
