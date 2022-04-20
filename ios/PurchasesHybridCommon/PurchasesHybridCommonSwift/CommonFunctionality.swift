//
//  CommonFunctionality.swift
//  PurchasesHybridCommonSwift
//
//  Created by Andrés Boedo on 4/19/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import StoreKit
import Purchases

@objc(RCCommonFunctionality) public class CommonFunctionality: NSObject {

    @objc public var proxyURLString: String?
    @objc public var simulatesAskToBuyInSandbox: Bool = false

    private var _discountsByProductIdentifier: Any? = nil
    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
    var discountsByProductIdentifier: [String: SKPaymentDiscount]? {
        get {
            return _discountsByProductIdentifier as? [String: SKPaymentDiscount]
        } set {
            _discountsByProductIdentifier = newValue
        }
    }

    @objc public func configure() {
        // todo: it seems like this call isn't needed anymore?
    }

    @objc public func setAllowSharingStoreAccount(_ allowSharingStoreAccount: Bool) {
        Purchases.shared.allowSharingAppStoreAccount = allowSharingStoreAccount;
    }

    @objc public func addAttributionData(_ data: [String: Any], network: Int, networkUserId: String) {
        addAttributionData(data, network: network, networkUserId: networkUserId)
    }

}
