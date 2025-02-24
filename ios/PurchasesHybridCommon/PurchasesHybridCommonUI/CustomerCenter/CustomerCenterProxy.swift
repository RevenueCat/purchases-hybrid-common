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
    
    @objc public func present() {
        guard let rootController = Self.rootViewController else {
            return
        }

        let vc = createCustomerCenterViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = .clear

        rootController.present(vc, animated: true)
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

    func createCustomerCenterViewController() -> CustomerCenterViewController {
        // customerCenterActionHandler = nil for now, till we implement proper callbacks
        return CustomerCenterViewController(
            customerCenterActionHandler: nil
        )
    }
}

#endif
