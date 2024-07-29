//
//  Purchases+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc public extension Purchases {

    @objc(configureWithAPIKey:appUserID:purchasesAreCompletedBy:userDefaultsSuiteName:platformFlavor:
            platformFlavorVersion:storeKitVersion:dangerousSettings:shouldShowInAppMessagesAutomatically:
            verificationMode:)
    static func configure(apiKey: String,
                          appUserID: String?,
                          purchasesAreCompletedBy: String?,
                          userDefaultsSuiteName: String?,
                          platformFlavor: String?,
                          platformFlavorVersion: String?,
                          storeKitVersion: String = "DEFAULT",
                          dangerousSettings: DangerousSettings?,
                          shouldShowInAppMessagesAutomatically: Bool = true,
                          verificationMode: String?) -> Purchases {
        var userDefaults: UserDefaults?
        if let userDefaultsSuiteName = userDefaultsSuiteName {
            userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
            guard userDefaults != nil else {
                fatalError("Could not create an instance of UserDefaults with suite name \(userDefaultsSuiteName)")
            }
        }

        var configurationBuilder: Configuration.Builder = .init(withAPIKey: apiKey)
        if let appUserID = appUserID {
            configurationBuilder = configurationBuilder.with(appUserID: appUserID)
        }

        let storeKitVersion = StoreKitVersion(name: storeKitVersion) ?? .default
        configurationBuilder = configurationBuilder.with(storeKitVersion: storeKitVersion)

        if let purchasesAreCompletedBy = purchasesAreCompletedBy {
            if let actualPurchasesAreCompletedBy = PurchasesAreCompletedBy(name: purchasesAreCompletedBy) {
                configurationBuilder = configurationBuilder.with(
                    purchasesAreCompletedBy: actualPurchasesAreCompletedBy,
                    storeKitVersion: storeKitVersion
                )
            }
        }

        if let userDefaults = userDefaults {
            configurationBuilder = configurationBuilder.with(userDefaults: userDefaults)
        }
        if let dangerousSettings = dangerousSettings {
            configurationBuilder = configurationBuilder.with(dangerousSettings: dangerousSettings)
        }
        if let platformFlavor = platformFlavor, let platformFlavorVersion = platformFlavorVersion {
            let platformInfo = Purchases.PlatformInfo(flavor: platformFlavor, version: platformFlavorVersion)
            configurationBuilder = configurationBuilder.with(platformInfo: platformInfo)
        }
        configurationBuilder = configurationBuilder.with(showStoreMessagesAutomatically:
                                                            shouldShowInAppMessagesAutomatically)

        if let verificationMode {
            if let mode = Configuration.EntitlementVerificationMode(name: verificationMode) {
                if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *) {
                    configurationBuilder = configurationBuilder.with(entitlementVerificationMode: mode)
                }
            } else {
                NSLog("Attempted to configure with unknown verification mode: '\(verificationMode)'")
            }
        }

        let purchases = self.configure(with: configurationBuilder.build())
        CommonFunctionality.sharedInstance = purchases

        return purchases
    }


    @objc(configureWithAPIKey:appUserID:purchasesAreCompletedBy:userDefaultsSuiteName:platformFlavor:
            platformFlavorVersion:storeKitVersion:dangerousSettings:shouldShowInAppMessagesAutomatically:)
    static func configure(apiKey: String,
                          appUserID: String?,
                          purchasesAreCompletedBy: String?,
                          userDefaultsSuiteName: String?,
                          platformFlavor: String?,
                          platformFlavorVersion: String?,
                          storeKitVersion: String = "DEFAULT",
                          dangerousSettings: DangerousSettings?,
                          shouldShowInAppMessagesAutomatically: Bool = true) -> Purchases {
        return configure(apiKey: apiKey,
                         appUserID: appUserID,
                         purchasesAreCompletedBy: purchasesAreCompletedBy,
                         userDefaultsSuiteName: userDefaultsSuiteName,
                         platformFlavor: platformFlavor,
                         platformFlavorVersion: platformFlavorVersion,
                         storeKitVersion: storeKitVersion,
                         dangerousSettings: dangerousSettings,
                         shouldShowInAppMessagesAutomatically: shouldShowInAppMessagesAutomatically,
                         verificationMode: nil)
    }
}

extension LogLevel {

    static let levels: Set<LogLevel> = [
        .verbose,
        .debug,
        .info,
        .warn,
        .error,
    ]

    static let levelsByDescription: [String: LogLevel] = .init(
        uniqueKeysWithValues: LogLevel.levels.map { ($0.description, $0) }
    )
}

// MARK: - Deprecations

protocol ConfigurationBuilderDeprecatable {

    func with(usesStoreKit2IfAvailable: Bool) -> Configuration.Builder

}

extension Configuration.Builder: ConfigurationBuilderDeprecatable {}
