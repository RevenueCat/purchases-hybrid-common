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
        self.present(resultHandler: resultHandler, errorHandler: { error in
            NSLog("Failed to present Customer Center: \(error.localizedDescription)")
        })
    }

    /// Presents the Customer Center. `resultHandler` is called when it's dismissed.
    /// `errorHandler` is called instead if the presentation could not happen, so callers can settle their promises.
    @objc public func present(
        resultHandler: @escaping () -> Void,
        errorHandler: @escaping (NSError) -> Void
    ) {
        guard var presenter = Self.rootViewController else {
            errorHandler(Self.presentationError("Could not find a view controller to present Customer Center from."))
            return
        }

        // In case we are currently presenting a modal or any other
        // view controller get to the top of the chain.
        while let presentedVC = presenter.presentedViewController {
            presenter = presentedVC
        }

        let vc = createCustomerCenterViewController()
        resultByVC[vc] = resultHandler

        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = .clear

        presenter.present(vc, animated: true)

        // UIKit doesn't report failures (it only logs), but the presented view controller
        // is set synchronously when the presentation is accepted.
        if presenter.presentedViewController !== vc {
            resultByVC.removeValue(forKey: vc)
            errorHandler(Self.presentationError("UIKit refused to present Customer Center."))
        }
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

    public func customerCenterViewController(_ controller: CustomerCenterUIViewController,
                                             didSucceedWithPromotionalOffer offerId: String,
                                             customerInfoDictionary: [String: Any],
                                             transactionDictionary: [String: Any]) {
        self.delegate?.customerCenterViewController?(controller,
                                                     didSucceedWithPromotionalOffer: offerId,
                                                     customerInfoDictionary: customerInfoDictionary,
                                                     transactionDictionary: transactionDictionary)
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

    static func presentationError(_ message: String) -> NSError {
        return NSError(domain: "com.revenuecat.purchaseshybridcommon.customercenter",
                       code: 1,
                       userInfo: [NSLocalizedDescriptionKey: message])
    }

    func createCustomerCenterViewController() -> CustomerCenterUIViewController {
        let vc = CustomerCenterUIViewController()
        vc.delegate = self
        vc.shouldShowCloseButton = shouldShowCloseButton

        return vc
    }
}

#endif
