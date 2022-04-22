//
//  PurchasesExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc public extension Purchases {

    @objc(configureWithAPIKey:appUserID:observerMode:userDefaultsSuiteName:platformFlavor:platformFlavorVersion:
            dangerousSettings:)
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
                              // todo: provide option
                              useStoreKit2IfAvailable: false,
                              dangerousSettings: dangerousSettings)
    }

}

