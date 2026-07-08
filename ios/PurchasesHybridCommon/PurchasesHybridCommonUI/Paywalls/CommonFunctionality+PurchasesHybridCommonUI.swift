//
//  CommonFunctionality+PurchasesHybridCommonUI.swift
//  PurchasesHybridCommon
//
//  Created by Dave DeLong on 7/7/26.
//
#if canImport(UIKit) && !os(tvOS) && !os(watchOS)

import Foundation
@_spi(Internal) import PurchasesHybridCommon
import RevenueCat
import RevenueCatUI

extension CommonFunctionality {

    @available(iOS 15.0, *)
    @MainActor
    @objc(presentPaywallFromURL:)
    public static func presentPaywall(from url: String) -> Bool {
        guard let url = URL(string: url) else {
            return false
        }
        /*
         Q: Why does this cast to Purchases?
         A: Self.sharedInstance is typed to be a "PurchasesType & PurchasesSwiftType". These are protocols
         defined in RevenueCat to make mocking easier, among other reasons. The "presentPaywall(...)" methods exist
         directly as methods on the "Purchases" type, and not as requirements from a protocol. Therefore, calling
         them requires having a direct instance of the Purchases type.

         Q: Why not add the presentation methods to the protocols?
         A: Adding the "presentPaywall()" methods to the protocol would not be possible, because the protocol is
         declared the RevenueCat package, and the methods exist in the RevenueCatUI package. Swift does not allow
         @objc extensions to @objc protocols, for the same reason that Objective-C category methods can only be
         defined on classes, and not protocols (ie, intricacies of how ObjC dispatch tables are constructed).

         Q: What about a new PurchasesUIType?
         A: That is the overall "most correct" solution, but it would *still* require a cast here, because of the
         module boundary. Self.sharedInstance would still just be a "PurchasesType & PurchasesSwiftType" value,
         and we would still need to cast to "PurchasesUIType" to access the method.

         Therefore, to avoid the hassle of creating an entirely new protocol in another repo just to add a single
         method where we would still need to cast to the correct type, this implementation does a direct cast
         to the "Purchases" type. In the event that a "PurchasesUIType" protocol ever gets created,
         this cast would be a reasonable place to adopt it.
         */
        guard let purchases = Self.sharedInstance as? Purchases else {
            // in the off-chance that we somehow have the wrong kind of shared instance, log a message
            // that can be easily traced back to this particular point-of-failure
            print("Error: attempting to open a paywall URL, but do not have the correct Purchases value")
            return false
        }
        return purchases.presentPaywall(from: url)
    }

}

#endif
