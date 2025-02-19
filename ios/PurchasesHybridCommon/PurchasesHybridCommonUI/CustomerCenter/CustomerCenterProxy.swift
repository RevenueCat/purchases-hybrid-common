//
//  CustomerCenterProxy.swift
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Foundation
import PurchasesHybridCommon
import RevenueCat
import RevenueCatUI
import UIKit

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@objcMembers
public class CustomerCenterProxy: NSObject {

    @objc
    func createCustomerCenterViewController() -> RCCustomerCenterViewController {
        return RCCustomerCenterViewController(
            customerCenterActionHandler: nil
        )
    }

    public func present() {
        guard let rootController = Self.rootViewController else {
            return
        }

        let vc = createCustomerCenterViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = .clear

        rootController.present(vc, animated: true)
    }

    private static var rootViewController: UIViewController? {
        let scene = UIApplication
            .shared
            .connectedScenes
            .first { $0.activationState == .foregroundActive }

        guard let windowScene = scene as? UIWindowScene else { return nil }
        return windowScene.keyWindow?.rootViewController
    }
}

#endif
