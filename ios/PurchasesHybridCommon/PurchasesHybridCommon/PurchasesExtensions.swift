//
//  PurchasesExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
// todo: remove testable
@testable import Purchases.Purchases
import PurchasesCoreSwift

@objc public extension Purchases {

    @objc(configureWithAPIKey:appUserID:observerMode:userDefaultsSuiteName:
            platformFlavor:platformFlavorVersion:dangerousSettings:)
        static func configure(apiKey: String,
                              appUserID: String?,
                              observerMode: Bool,
                              userDefaultsSuiteName: String?,
                              platformFlavor: String?,
                              platformFlavorVersion: String?,
                              dangerousSettings: DangerousSettings?) -> Purchases {
        var userDefaults: UserDefaults?
        if let userDefaultsSuiteName = userDefaultsSuiteName {
            userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
            guard userDefaults != nil else {
                fatalError("Could not create an instance of UserDefaults with suite name \(userDefaultsSuiteName)")
            }
        }

        return self.configure(withAPIKey: apiKey,
                              appUserID: appUserID,
                              observerMode: observerMode,
                              userDefaults: userDefaults,
                              dangerousSettings: dangerousSettings)
    }


    // todo: make internal
    @objc static func setDefaultInstance(_ instance: Purchases) {

    }

}

