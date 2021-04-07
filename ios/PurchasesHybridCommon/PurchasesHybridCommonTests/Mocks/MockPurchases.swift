//
// Created by Andrés Boedo on 4/7/21.
// Copyright (c) 2021 RevenueCat. All rights reserved.
//

import Foundation
import Purchases

class MockPurchases: Purchases {
    var invokedAppUserIDGetter = false
    var invokedAppUserIDGetterCount = 0
    var stubbedAppUserID: String! = ""
    override var appUserID: String {
        invokedAppUserIDGetter = true
        invokedAppUserIDGetterCount += 1
        return stubbedAppUserID
    }
    var invokedIsAnonymousGetter = false
    var invokedIsAnonymousGetterCount = 0
    var stubbedIsAnonymous: Bool! = false
    override var isAnonymous: Bool {
        invokedIsAnonymousGetter = true
        invokedIsAnonymousGetterCount += 1
        return stubbedIsAnonymous
    }
    var invokedCreateAliasStringRCReceivePurchaserInfoBlock = false
    var invokedCreateAliasStringRCReceivePurchaserInfoBlockCount = 0
    var invokedCreateAliasStringRCReceivePurchaserInfoBlockParameters: (alias: String, completion: Purchases.ReceivePurchaserInfoBlock?)?
    var invokedCreateAliasStringRCReceivePurchaserInfoBlockParametersList = [(alias: String,
                                                                              completion: Purchases.ReceivePurchaserInfoBlock?)]()

    override func createAlias(_ alias: String, _ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedCreateAliasStringRCReceivePurchaserInfoBlock = true
        invokedCreateAliasStringRCReceivePurchaserInfoBlockCount += 1
        invokedCreateAliasStringRCReceivePurchaserInfoBlockParameters = (alias, completion)
        invokedCreateAliasStringRCReceivePurchaserInfoBlockParametersList.append((alias, completion))
    }

    var invokedIdentifyStringRCReceivePurchaserInfoBlock = false
    var invokedIdentifyStringRCReceivePurchaserInfoBlockCount = 0
    var invokedIdentifyStringRCReceivePurchaserInfoBlockParameters: (appUserID: String, completion: Purchases.ReceivePurchaserInfoBlock?)?
    var invokedIdentifyStringRCReceivePurchaserInfoBlockParametersList = [(appUserID: String,
                                                                           completion: Purchases.ReceivePurchaserInfoBlock?)]()

    override func identify(_ appUserID: String,
                           _ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedIdentifyStringRCReceivePurchaserInfoBlock = true
        invokedIdentifyStringRCReceivePurchaserInfoBlockCount += 1
        invokedIdentifyStringRCReceivePurchaserInfoBlockParameters = (appUserID, completion)
        invokedIdentifyStringRCReceivePurchaserInfoBlockParametersList.append((appUserID, completion))
    }

    var invokedResetRCReceivePurchaserInfoBlock = false
    var invokedResetRCReceivePurchaserInfoBlockCount = 0
    var invokedResetRCReceivePurchaserInfoBlockParameters: (completion: Purchases.ReceivePurchaserInfoBlock?, Void)?
    var invokedResetRCReceivePurchaserInfoBlockParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock?, Void)]()

    override func reset(_ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedResetRCReceivePurchaserInfoBlock = true
        invokedResetRCReceivePurchaserInfoBlockCount += 1
        invokedResetRCReceivePurchaserInfoBlockParameters = (completion, ())
        invokedResetRCReceivePurchaserInfoBlockParametersList.append((completion, ()))
    }

    var invokedLogInError = false
    var invokedLogInCount = 0
    var invokedLogInParameters: (appUserID: String, Void)?
    var invokedLogInParametersList = [(appUserID: String, Void)]()
    var stubbedLogInCompletionResult: (Purchases.PurchaserInfo?, Bool, Error?)?

    override func logIn(_ appUserID: String,
                        _ completion: @escaping (Purchases.PurchaserInfo?, Bool, Error?) -> ()) {
        invokedLogInError = true
        invokedLogInCount += 1
        invokedLogInParameters = (appUserID, ())
        invokedLogInParametersList.append((appUserID, ()))
        if let result = stubbedLogInCompletionResult {
            completion(result.0, result.1, result.2)
        }
    }

    var invokedLogOutRCReceivePurchaserInfoBlock = false
    var invokedLogOutRCReceivePurchaserInfoBlockCount = 0
    var invokedLogOutRCReceivePurchaserInfoBlockParameters: (completion: Purchases.ReceivePurchaserInfoBlock?, Void)?
    var invokedLogOutRCReceivePurchaserInfoBlockParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock?, Void)]()

    override func logOut(_ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedLogOutRCReceivePurchaserInfoBlock = true
        invokedLogOutRCReceivePurchaserInfoBlockCount += 1
        invokedLogOutRCReceivePurchaserInfoBlockParameters = (completion, ())
        invokedLogOutRCReceivePurchaserInfoBlockParametersList.append((completion, ()))
    }

    var invokedPurchaserInfoRCReceivePurchaserInfoBlock = false
    var invokedPurchaserInfoRCReceivePurchaserInfoBlockCount = 0
    var invokedPurchaserInfoRCReceivePurchaserInfoBlockParameters: (completion: Purchases.ReceivePurchaserInfoBlock, Void)?
    var invokedPurchaserInfoRCReceivePurchaserInfoBlockParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock,
                                                                             Void)]()

    override func purchaserInfo(_ completion: @escaping Purchases.ReceivePurchaserInfoBlock) {
        invokedPurchaserInfoRCReceivePurchaserInfoBlock = true
        invokedPurchaserInfoRCReceivePurchaserInfoBlockCount += 1
        invokedPurchaserInfoRCReceivePurchaserInfoBlockParameters = (completion, ())
        invokedPurchaserInfoRCReceivePurchaserInfoBlockParametersList.append((completion, ()))
    }

    var invokedOfferingsRCReceiveOfferingsBlock = false
    var invokedOfferingsRCReceiveOfferingsBlockCount = 0
    var invokedOfferingsRCReceiveOfferingsBlockParameters: (completion: Purchases.ReceiveOfferingsBlock, Void)?
    var invokedOfferingsRCReceiveOfferingsBlockParametersList = [(completion: Purchases.ReceiveOfferingsBlock, Void)]()

    override func offerings(_ completion: @escaping Purchases.ReceiveOfferingsBlock) {
        invokedOfferingsRCReceiveOfferingsBlock = true
        invokedOfferingsRCReceiveOfferingsBlockCount += 1
        invokedOfferingsRCReceiveOfferingsBlockParameters = (completion, ())
        invokedOfferingsRCReceiveOfferingsBlockParametersList.append((completion, ()))
    }

    var invokedProductsStringRCReceiveProductsBlock = false
    var invokedProductsStringRCReceiveProductsBlockCount = 0
    var invokedProductsStringRCReceiveProductsBlockParameters: (productIdentifiers: [String], completion: Purchases.ReceiveProductsBlock)?
    var invokedProductsStringRCReceiveProductsBlockParametersList = [(productIdentifiers: [String],
                                                                      completion: Purchases.ReceiveProductsBlock)]()

    override func products(_ productIdentifiers: [String],
                           _ completion: @escaping Purchases.ReceiveProductsBlock) {
        invokedProductsStringRCReceiveProductsBlock = true
        invokedProductsStringRCReceiveProductsBlockCount += 1
        invokedProductsStringRCReceiveProductsBlockParameters = (productIdentifiers, completion)
        invokedProductsStringRCReceiveProductsBlockParametersList.append((productIdentifiers, completion))
    }

    var invokedPurchaseProductSKProductRCPurchaseCompletedBlock = false
    var invokedPurchaseProductSKProductRCPurchaseCompletedBlockCount = 0
    var invokedPurchaseProductSKProductRCPurchaseCompletedBlockParameters: (product: SKProduct, completion: Purchases.PurchaseCompletedBlock)?
    var invokedPurchaseProductSKProductRCPurchaseCompletedBlockParametersList = [(product: SKProduct,
                                                                                  completion: Purchases.PurchaseCompletedBlock)]()

    override func purchaseProduct(_ product: SKProduct, _ completion: @escaping Purchases.PurchaseCompletedBlock) {
        invokedPurchaseProductSKProductRCPurchaseCompletedBlock = true
        invokedPurchaseProductSKProductRCPurchaseCompletedBlockCount += 1
        invokedPurchaseProductSKProductRCPurchaseCompletedBlockParameters = (product, completion)
        invokedPurchaseProductSKProductRCPurchaseCompletedBlockParametersList.append((product, completion))
    }

    var invokedPurchasePackageRCPackage = false
    var invokedPurchasePackageRCPackageCount = 0
    var invokedPurchasePackageRCPackageParameters: (package: Purchases.Package, completion: Purchases.PurchaseCompletedBlock)?
    var invokedPurchasePackageRCPackageParametersList = [(package: Purchases.Package, completion: Purchases.PurchaseCompletedBlock)]()

    override func purchasePackage(_ package: Purchases.Package, _ completion: @escaping Purchases.PurchaseCompletedBlock) {
        invokedPurchasePackageRCPackage = true
        invokedPurchasePackageRCPackageCount += 1
        invokedPurchasePackageRCPackageParameters = (package, completion)
        invokedPurchasePackageRCPackageParametersList.append((package, completion))
    }

    var invokedRestoreTransactionsRCReceivePurchaserInfoBlock = false
    var invokedRestoreTransactionsRCReceivePurchaserInfoBlockCount = 0
    var invokedRestoreTransactionsRCReceivePurchaserInfoBlockParameters: (completion: Purchases.ReceivePurchaserInfoBlock?, Void)?
    var invokedRestoreTransactionsRCReceivePurchaserInfoBlockParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock?,
                                                                                   Void)]()

    override func restoreTransactions(_ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedRestoreTransactionsRCReceivePurchaserInfoBlock = true
        invokedRestoreTransactionsRCReceivePurchaserInfoBlockCount += 1
        invokedRestoreTransactionsRCReceivePurchaserInfoBlockParameters = (completion, ())
        invokedRestoreTransactionsRCReceivePurchaserInfoBlockParametersList.append((completion, ()))
    }

    var invokedSyncPurchasesRCReceivePurchaserInfoBlock = false
    var invokedSyncPurchasesRCReceivePurchaserInfoBlockCount = 0
    var invokedSyncPurchasesRCReceivePurchaserInfoBlockParameters: (completion: Purchases.ReceivePurchaserInfoBlock?, Void)?
    var invokedSyncPurchasesRCReceivePurchaserInfoBlockParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock?,
                                                                             Void)]()

    override func syncPurchases(_ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedSyncPurchasesRCReceivePurchaserInfoBlock = true
        invokedSyncPurchasesRCReceivePurchaserInfoBlockCount += 1
        invokedSyncPurchasesRCReceivePurchaserInfoBlockParameters = (completion, ())
        invokedSyncPurchasesRCReceivePurchaserInfoBlockParametersList.append((completion, ()))
    }

    var invokedCheckTrialOrIntroductoryPriceEligibilityStringCompletionBlockRCReceiveIntroEligibilityBlock = false
    var invokedCheckTrialOrIntroductoryPriceEligibilityStringCompletionBlockRCReceiveIntroEligibilityBlockCount = 0
    var invokedCheckTrialOrIntroductoryPriceEligibilityStringCompletionBlockRCReceiveIntroEligibilityBlockParameters: (productIdentifiers: [String], receiveEligibility: Purchases.ReceiveIntroEligibilityBlock)?
    var invokedCheckTrialOrIntroductoryPriceEligibilityStringCompletionBlockRCReceiveIntroEligibilityBlockParametersList = [(productIdentifiers: [String],
                                                                                                                             receiveEligibility: Purchases.ReceiveIntroEligibilityBlock)]()

    override func checkTrialOrIntroductoryPriceEligibility(_ productIdentifiers: [String],
                                                           completionBlock receiveEligibility: @escaping Purchases.ReceiveIntroEligibilityBlock) {
        invokedCheckTrialOrIntroductoryPriceEligibilityStringCompletionBlockRCReceiveIntroEligibilityBlock = true
        invokedCheckTrialOrIntroductoryPriceEligibilityStringCompletionBlockRCReceiveIntroEligibilityBlockCount += 1
        invokedCheckTrialOrIntroductoryPriceEligibilityStringCompletionBlockRCReceiveIntroEligibilityBlockParameters = (
            productIdentifiers,
            receiveEligibility)
        invokedCheckTrialOrIntroductoryPriceEligibilityStringCompletionBlockRCReceiveIntroEligibilityBlockParametersList.append(
            (productIdentifiers, receiveEligibility))
    }

    var invokedPaymentDiscountForSKProductDiscountProductSKProductCompletionRCPaymentDiscountBlock = false
    var invokedPaymentDiscountForSKProductDiscountProductSKProductCompletionRCPaymentDiscountBlockCount = 0
    var invokedPaymentDiscountForSKProductDiscountProductSKProductCompletionRCPaymentDiscountBlockParameters: (discount: SKProductDiscount, product: SKProduct, completion: Purchases.PaymentDiscountBlock)?
    var invokedPaymentDiscountForSKProductDiscountProductSKProductCompletionRCPaymentDiscountBlockParametersList = [(discount: SKProductDiscount,
                                                                                                                        product: SKProduct,
                                                                                                                        completion: Purchases.PaymentDiscountBlock)]()

    override func paymentDiscount(for discount: SKProductDiscount,
                                  product: SKProduct,
                                  completion: @escaping Purchases.PaymentDiscountBlock) {
        invokedPaymentDiscountForSKProductDiscountProductSKProductCompletionRCPaymentDiscountBlock = true
        invokedPaymentDiscountForSKProductDiscountProductSKProductCompletionRCPaymentDiscountBlockCount += 1
        invokedPaymentDiscountForSKProductDiscountProductSKProductCompletionRCPaymentDiscountBlockParameters = (discount,
            product,
            completion)
        invokedPaymentDiscountForSKProductDiscountProductSKProductCompletionRCPaymentDiscountBlockParametersList.append(
            (discount, product, completion))
    }

    var invokedPurchaseProductSKProductDiscountSKPaymentDiscountRCPurchaseCompletedBlock = false
    var invokedPurchaseProductSKProductDiscountSKPaymentDiscountRCPurchaseCompletedBlockCount = 0
    var invokedPurchaseProductSKProductDiscountSKPaymentDiscountRCPurchaseCompletedBlockParameters: (product: SKProduct, discount: SKPaymentDiscount, completion: Purchases.PurchaseCompletedBlock)?
    var invokedPurchaseProductSKProductDiscountSKPaymentDiscountRCPurchaseCompletedBlockParametersList = [(product: SKProduct,
                                                                                                              discount: SKPaymentDiscount,
                                                                                                              completion: Purchases.PurchaseCompletedBlock)]()

    override func purchaseProduct(_ product: SKProduct,
                                  discount: SKPaymentDiscount,
                                  _ completion: @escaping Purchases.PurchaseCompletedBlock) {
        invokedPurchaseProductSKProductDiscountSKPaymentDiscountRCPurchaseCompletedBlock = true
        invokedPurchaseProductSKProductDiscountSKPaymentDiscountRCPurchaseCompletedBlockCount += 1
        invokedPurchaseProductSKProductDiscountSKPaymentDiscountRCPurchaseCompletedBlockParameters = (product,
            discount,
            completion)
        invokedPurchaseProductSKProductDiscountSKPaymentDiscountRCPurchaseCompletedBlockParametersList.append((product,
                                                                                                                  discount,
                                                                                                                  completion))
    }

    var invokedPurchasePackageRCPackageDiscount = false
    var invokedPurchasePackageRCPackageDiscountCount = 0
    var invokedPurchasePackageRCPackageDiscountParameters: (package: Purchases.Package, discount: SKPaymentDiscount, completion: Purchases.PurchaseCompletedBlock)?
    var invokedPurchasePackageRCPackageDiscountParametersList = [(package: Purchases.Package,
                                                                     discount: SKPaymentDiscount,
                                                                     completion: Purchases.PurchaseCompletedBlock)]()

    override func purchasePackage(_ package: Purchases.Package,
                                  discount: SKPaymentDiscount,
                                  _ completion: @escaping Purchases.PurchaseCompletedBlock) {
        invokedPurchasePackageRCPackageDiscount = true
        invokedPurchasePackageRCPackageDiscountCount += 1
        invokedPurchasePackageRCPackageDiscountParameters = (package, discount, completion)
        invokedPurchasePackageRCPackageDiscountParametersList.append((package, discount, completion))
    }

    var invokedInvalidatePurchaserInfoCache = false
    var invokedInvalidatePurchaserInfoCacheCount = 0

    override func invalidatePurchaserInfoCache() {
        invokedInvalidatePurchaserInfoCache = true
        invokedInvalidatePurchaserInfoCacheCount += 1
    }

    var invokedPresentCodeRedemptionSheet = false
    var invokedPresentCodeRedemptionSheetCount = 0

    override func presentCodeRedemptionSheet() {
        invokedPresentCodeRedemptionSheet = true
        invokedPresentCodeRedemptionSheetCount += 1
    }

    var invokedSetAttributes = false
    var invokedSetAttributesCount = 0
    var invokedSetAttributesParameters: (attributes: [String: String], Void)?
    var invokedSetAttributesParametersList = [(attributes: [String: String], Void)]()

    override func setAttributes(_ attributes: [String: String]) {
        invokedSetAttributes = true
        invokedSetAttributesCount += 1
        invokedSetAttributesParameters = (attributes, ())
        invokedSetAttributesParametersList.append((attributes, ()))
    }

    var invokedSetEmail = false
    var invokedSetEmailCount = 0
    var invokedSetEmailParameters: (email: String?, Void)?
    var invokedSetEmailParametersList = [(email: String?, Void)]()

    override func setEmail(_ email: String?) {
        invokedSetEmail = true
        invokedSetEmailCount += 1
        invokedSetEmailParameters = (email, ())
        invokedSetEmailParametersList.append((email, ()))
    }

    var invokedSetPhoneNumber = false
    var invokedSetPhoneNumberCount = 0
    var invokedSetPhoneNumberParameters: (phoneNumber: String?, Void)?
    var invokedSetPhoneNumberParametersList = [(phoneNumber: String?, Void)]()

    override func setPhoneNumber(_ phoneNumber: String?) {
        invokedSetPhoneNumber = true
        invokedSetPhoneNumberCount += 1
        invokedSetPhoneNumberParameters = (phoneNumber, ())
        invokedSetPhoneNumberParametersList.append((phoneNumber, ()))
    }

    var invokedSetDisplayName = false
    var invokedSetDisplayNameCount = 0
    var invokedSetDisplayNameParameters: (displayName: String?, Void)?
    var invokedSetDisplayNameParametersList = [(displayName: String?, Void)]()

    override func setDisplayName(_ displayName: String?) {
        invokedSetDisplayName = true
        invokedSetDisplayNameCount += 1
        invokedSetDisplayNameParameters = (displayName, ())
        invokedSetDisplayNameParametersList.append((displayName, ()))
    }

    var invokedSetPushToken = false
    var invokedSetPushTokenCount = 0
    var invokedSetPushTokenParameters: (pushToken: Data?, Void)?
    var invokedSetPushTokenParametersList = [(pushToken: Data?, Void)]()

    override func setPushToken(_ pushToken: Data?) {
        invokedSetPushToken = true
        invokedSetPushTokenCount += 1
        invokedSetPushTokenParameters = (pushToken, ())
        invokedSetPushTokenParametersList.append((pushToken, ()))
    }

    var invokedSetAdjustID = false
    var invokedSetAdjustIDCount = 0
    var invokedSetAdjustIDParameters: (adjustID: String?, Void)?
    var invokedSetAdjustIDParametersList = [(adjustID: String?, Void)]()

    override func setAdjustID(_ adjustID: String?) {
        invokedSetAdjustID = true
        invokedSetAdjustIDCount += 1
        invokedSetAdjustIDParameters = (adjustID, ())
        invokedSetAdjustIDParametersList.append((adjustID, ()))
    }

    var invokedSetAppsflyerID = false
    var invokedSetAppsflyerIDCount = 0
    var invokedSetAppsflyerIDParameters: (appsflyerID: String?, Void)?
    var invokedSetAppsflyerIDParametersList = [(appsflyerID: String?, Void)]()

    override func setAppsflyerID(_ appsflyerID: String?) {
        invokedSetAppsflyerID = true
        invokedSetAppsflyerIDCount += 1
        invokedSetAppsflyerIDParameters = (appsflyerID, ())
        invokedSetAppsflyerIDParametersList.append((appsflyerID, ()))
    }

    var invokedSetFBAnonymousID = false
    var invokedSetFBAnonymousIDCount = 0
    var invokedSetFBAnonymousIDParameters: (fbAnonymousID: String?, Void)?
    var invokedSetFBAnonymousIDParametersList = [(fbAnonymousID: String?, Void)]()

    override func setFBAnonymousID(_ fbAnonymousID: String?) {
        invokedSetFBAnonymousID = true
        invokedSetFBAnonymousIDCount += 1
        invokedSetFBAnonymousIDParameters = (fbAnonymousID, ())
        invokedSetFBAnonymousIDParametersList.append((fbAnonymousID, ()))
    }

    var invokedSetMparticleID = false
    var invokedSetMparticleIDCount = 0
    var invokedSetMparticleIDParameters: (mparticleID: String?, Void)?
    var invokedSetMparticleIDParametersList = [(mparticleID: String?, Void)]()

    override func setMparticleID(_ mparticleID: String?) {
        invokedSetMparticleID = true
        invokedSetMparticleIDCount += 1
        invokedSetMparticleIDParameters = (mparticleID, ())
        invokedSetMparticleIDParametersList.append((mparticleID, ()))
    }

    var invokedSetOnesignalID = false
    var invokedSetOnesignalIDCount = 0
    var invokedSetOnesignalIDParameters: (onesignalID: String?, Void)?
    var invokedSetOnesignalIDParametersList = [(onesignalID: String?, Void)]()

    override func setOnesignalID(_ onesignalID: String?) {
        invokedSetOnesignalID = true
        invokedSetOnesignalIDCount += 1
        invokedSetOnesignalIDParameters = (onesignalID, ())
        invokedSetOnesignalIDParametersList.append((onesignalID, ()))
    }

    var invokedSetMediaSource = false
    var invokedSetMediaSourceCount = 0
    var invokedSetMediaSourceParameters: (mediaSource: String?, Void)?
    var invokedSetMediaSourceParametersList = [(mediaSource: String?, Void)]()

    override func setMediaSource(_ mediaSource: String?) {
        invokedSetMediaSource = true
        invokedSetMediaSourceCount += 1
        invokedSetMediaSourceParameters = (mediaSource, ())
        invokedSetMediaSourceParametersList.append((mediaSource, ()))
    }

    var invokedSetCampaign = false
    var invokedSetCampaignCount = 0
    var invokedSetCampaignParameters: (campaign: String?, Void)?
    var invokedSetCampaignParametersList = [(campaign: String?, Void)]()

    override func setCampaign(_ campaign: String?) {
        invokedSetCampaign = true
        invokedSetCampaignCount += 1
        invokedSetCampaignParameters = (campaign, ())
        invokedSetCampaignParametersList.append((campaign, ()))
    }

    var invokedSetAdGroup = false
    var invokedSetAdGroupCount = 0
    var invokedSetAdGroupParameters: (adGroup: String?, Void)?
    var invokedSetAdGroupParametersList = [(adGroup: String?, Void)]()

    override func setAdGroup(_ adGroup: String?) {
        invokedSetAdGroup = true
        invokedSetAdGroupCount += 1
        invokedSetAdGroupParameters = (adGroup, ())
        invokedSetAdGroupParametersList.append((adGroup, ()))
    }

    var invokedSetAd = false
    var invokedSetAdCount = 0
    var invokedSetAdParameters: (ad: String?, Void)?
    var invokedSetAdParametersList = [(ad: String?, Void)]()

    override func setAd(_ ad: String?) {
        invokedSetAd = true
        invokedSetAdCount += 1
        invokedSetAdParameters = (ad, ())
        invokedSetAdParametersList.append((ad, ()))
    }

    var invokedSetKeyword = false
    var invokedSetKeywordCount = 0
    var invokedSetKeywordParameters: (keyword: String?, Void)?
    var invokedSetKeywordParametersList = [(keyword: String?, Void)]()

    override func setKeyword(_ keyword: String?) {
        invokedSetKeyword = true
        invokedSetKeywordCount += 1
        invokedSetKeywordParameters = (keyword, ())
        invokedSetKeywordParametersList.append((keyword, ()))
    }

    var invokedSetCreative = false
    var invokedSetCreativeCount = 0
    var invokedSetCreativeParameters: (creative: String?, Void)?
    var invokedSetCreativeParametersList = [(creative: String?, Void)]()

    override func setCreative(_ creative: String?) {
        invokedSetCreative = true
        invokedSetCreativeCount += 1
        invokedSetCreativeParameters = (creative, ())
        invokedSetCreativeParametersList.append((creative, ()))
    }

    var invokedCollectDeviceIdentifiers = false
    var invokedCollectDeviceIdentifiersCount = 0

    override func collectDeviceIdentifiers() {
        invokedCollectDeviceIdentifiers = true
        invokedCollectDeviceIdentifiersCount += 1
    }

    var invoked_setPushTokenString = false
    var invoked_setPushTokenStringCount = 0
    var invoked_setPushTokenStringParameters: (pushToken: String?, Void)?
    var invoked_setPushTokenStringParametersList = [(pushToken: String?, Void)]()

    override func _setPushTokenString(_ pushToken: String?) {
        invoked_setPushTokenString = true
        invoked_setPushTokenStringCount += 1
        invoked_setPushTokenStringParameters = (pushToken, ())
        invoked_setPushTokenStringParametersList.append((pushToken, ()))
    }
}
