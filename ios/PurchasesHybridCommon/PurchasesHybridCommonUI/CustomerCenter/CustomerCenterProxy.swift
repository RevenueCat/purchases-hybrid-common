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
    public weak var delegate: CustomerCenterViewControllerDelegateWrapper?
    
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

        return vc
    }
}

#endif
