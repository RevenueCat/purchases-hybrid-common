//
//  IOSAPIAvailabilityChecker.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 1/9/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

/// A utility class that checks the availability of iOS-specific APIs based on the operating system version.
@objc
public final class IOSAPIAvailabilityChecker: NSObject {

    /// Determines if the Win-Back Offer APIs are available on the current device.
    ///
    /// Note: This only checks if the APIs are available in the current OS version, 
    /// not if the SDK is using StoreKit 2, which is required for the APIs.
    ///
    /// - Returns: `true` if the Win-Back Offer APIs are available, `false` otherwise.
    @objc
    public func isWinBackOfferAPIAvailable() -> Bool {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            return true
        } else {
            return false
        }
    }

}
