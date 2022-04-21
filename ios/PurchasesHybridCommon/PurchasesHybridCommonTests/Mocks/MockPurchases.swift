//
// Created by Andrés Boedo on 4/7/21.
// Copyright (c) 2021 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

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

    var invokedLogOut = false
    var invokedLogOutCount = 0
    var invokedLogOutParameters: (completion: Purchases.ReceivePurchaserInfoBlock?, Void)?
    var invokedLogOutParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock?, Void)]()
    var stubbedLogOutCompletionResult: (Purchases.PurchaserInfo?, Error?)?

    override func logOut(_ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedLogOut = true
        invokedLogOutCount += 1
        invokedLogOutParameters = (completion, ())
        invokedLogOutParametersList.append((completion, ()))
        if let completion = completion, let result = stubbedLogOutCompletionResult {
            completion(result.0, result.1)
        }
    }

    var invokedCreateAlias = false
    var invokedCreateAliasCount = 0
    var invokedCreateAliasParameters: (alias: String, completion: Purchases.ReceivePurchaserInfoBlock?)?
    var invokedCreateAliasParametersList = [(alias: String,
        completion: Purchases.ReceivePurchaserInfoBlock?)]()

    override func createAlias(_ alias: String, _ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedCreateAlias = true
        invokedCreateAliasCount += 1
        invokedCreateAliasParameters = (alias, completion)
        invokedCreateAliasParametersList.append((alias, completion))
    }

    var invokedIdentify = false
    var invokedIdentifyCount = 0
    var invokedIdentifyParameters: (appUserID: String, completion: Purchases.ReceivePurchaserInfoBlock?)?
    var invokedIdentifyParametersList = [(appUserID: String,
        completion: Purchases.ReceivePurchaserInfoBlock?)]()

    override func identify(_ appUserID: String,
                           _ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedIdentify = true
        invokedIdentifyCount += 1
        invokedIdentifyParameters = (appUserID, completion)
        invokedIdentifyParametersList.append((appUserID, completion))
    }

    var invokedReset = false
    var invokedResetCount = 0
    var invokedResetParameters: (completion: Purchases.ReceivePurchaserInfoBlock?, Void)?
    var invokedResetParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock?, Void)]()

    override func reset(_ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedReset = true
        invokedResetCount += 1
        invokedResetParameters = (completion, ())
        invokedResetParametersList.append((completion, ()))
    }

    var invokedPurchaserInfo = false
    var invokedPurchaserInfoCount = 0
    var invokedPurchaserInfoParameters: (completion: Purchases.ReceivePurchaserInfoBlock, Void)?
    var invokedPurchaserInfoParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock,
        Void)]()

    override func purchaserInfo(_ completion: @escaping Purchases.ReceivePurchaserInfoBlock) {
        invokedPurchaserInfo = true
        invokedPurchaserInfoCount += 1
        invokedPurchaserInfoParameters = (completion, ())
        invokedPurchaserInfoParametersList.append((completion, ()))
    }

    var invokedOfferings = false
    var invokedOfferingsCount = 0
    var invokedOfferingsParameters: (completion: Purchases.ReceiveOfferingsBlock, Void)?
    var invokedOfferingsParametersList = [(completion: Purchases.ReceiveOfferingsBlock, Void)]()

    override func offerings(_ completion: @escaping Purchases.ReceiveOfferingsBlock) {
        invokedOfferings = true
        invokedOfferingsCount += 1
        invokedOfferingsParameters = (completion, ())
        invokedOfferingsParametersList.append((completion, ()))
    }

    var invokedProducts = false
    var invokedProductsCount = 0
    var invokedProductsParameters: (productIdentifiers: [String], completion: Purchases.ReceiveProductsBlock)?
    var invokedProductsParametersList = [(productIdentifiers: [String],
        completion: Purchases.ReceiveProductsBlock)]()

    override func products(_ productIdentifiers: [String],
                           _ completion: @escaping Purchases.ReceiveProductsBlock) {
        invokedProducts = true
        invokedProductsCount += 1
        invokedProductsParameters = (productIdentifiers, completion)
        invokedProductsParametersList.append((productIdentifiers, completion))
    }

    var invokedPurchaseProduct = false
    var invokedPurchaseProductCount = 0
    var invokedPurchaseProductParameters: (product: SKProduct, completion: Purchases.PurchaseCompletedBlock)?
    var invokedPurchaseProductParametersList = [(product: SKProduct,
        completion: Purchases.PurchaseCompletedBlock)]()

    override func purchaseProduct(_ product: SKProduct, _ completion: @escaping Purchases.PurchaseCompletedBlock) {
        invokedPurchaseProduct = true
        invokedPurchaseProductCount += 1
        invokedPurchaseProductParameters = (product, completion)
        invokedPurchaseProductParametersList.append((product, completion))
    }

    var invokedPurchasePackage = false
    var invokedPurchasePackageCount = 0
    var invokedPurchasePackageParameters: (package: Purchases.Package, completion: Purchases.PurchaseCompletedBlock)?
    var invokedPurchasePackageParametersList = [(package: Purchases.Package,
        completion: Purchases.PurchaseCompletedBlock)]()

    override func purchasePackage(_ package: Purchases.Package,
                                  _ completion: @escaping Purchases.PurchaseCompletedBlock) {
        invokedPurchasePackage = true
        invokedPurchasePackageCount += 1
        invokedPurchasePackageParameters = (package, completion)
        invokedPurchasePackageParametersList.append((package, completion))
    }

    var invokedRestoreTransactions = false
    var invokedRestoreTransactionsCount = 0
    var invokedRestoreTransactionsParameters: (completion: Purchases.ReceivePurchaserInfoBlock?, Void)?
    var invokedRestoreTransactionsParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock?,
        Void)]()

    override func restoreTransactions(_ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedRestoreTransactions = true
        invokedRestoreTransactionsCount += 1
        invokedRestoreTransactionsParameters = (completion, ())
        invokedRestoreTransactionsParametersList.append((completion, ()))
    }

    var invokedSyncPurchases = false
    var invokedSyncPurchasesCount = 0
    var invokedSyncPurchasesParameters: (completion: Purchases.ReceivePurchaserInfoBlock?, Void)?
    var invokedSyncPurchasesParametersList = [(completion: Purchases.ReceivePurchaserInfoBlock?,
        Void)]()

    override func syncPurchases(_ completion: Purchases.ReceivePurchaserInfoBlock?) {
        invokedSyncPurchases = true
        invokedSyncPurchasesCount += 1
        invokedSyncPurchasesParameters = (completion, ())
        invokedSyncPurchasesParametersList.append((completion, ()))
    }

    var invokedCheckTrialOrIntroductoryPriceEligibility = false
    var invokedCheckTrialOrIntroductoryPriceEligibilityCount = 0
    var invokedCheckTrialOrIntroductoryPriceEligibilityParameters: (productIdentifiers: [String], receiveEligibility: Purchases.ReceiveIntroEligibilityBlock)?
    var invokedCheckTrialOrIntroductoryPriceEligibilityParametersList = [(
        productIdentifiers: [String],
        receiveEligibility: Purchases.ReceiveIntroEligibilityBlock)]()

    override func checkTrialOrIntroductoryPriceEligibility(_ productIdentifiers: [String],
                                                           completionBlock receiveEligibility: @escaping Purchases.ReceiveIntroEligibilityBlock) {
        invokedCheckTrialOrIntroductoryPriceEligibility = true
        invokedCheckTrialOrIntroductoryPriceEligibilityCount += 1
        invokedCheckTrialOrIntroductoryPriceEligibilityParameters = (
            productIdentifiers,
            receiveEligibility)
        invokedCheckTrialOrIntroductoryPriceEligibilityParametersList.append(
            (productIdentifiers, receiveEligibility))
    }

    var invokedPaymentDiscount = false
    var invokedPaymentDiscountCount = 0
    var invokedPaymentDiscountParameters: (discount: SKProductDiscount, product: SKProduct, completion: Purchases.PaymentDiscountBlock)?
    var invokedPaymentDiscountParametersList = [(
        discount: SKProductDiscount,
        product: SKProduct,
        completion: Purchases.PaymentDiscountBlock)]()

    override func paymentDiscount(for discount: SKProductDiscount,
                                  product: SKProduct,
                                  completion: @escaping Purchases.PaymentDiscountBlock) {
        invokedPaymentDiscount = true
        invokedPaymentDiscountCount += 1
        invokedPaymentDiscountParameters = (discount,
            product,
            completion)
        invokedPaymentDiscountParametersList.append(
            (discount, product, completion))
    }

    var invokedPurchaseProductWithDiscount = false
    var invokedPurchaseProductWithDiscountCount = 0
    var invokedPurchaseProductWithDiscountParameters: (product: SKProduct, discount: SKPaymentDiscount, completion: Purchases.PurchaseCompletedBlock)?
    var invokedPurchaseProductWithDiscountParametersList = [(product: SKProduct,
        discount: SKPaymentDiscount,
        completion: Purchases.PurchaseCompletedBlock)]()

    override func purchaseProduct(_ product: SKProduct,
                                  discount: SKPaymentDiscount,
                                  _ completion: @escaping Purchases.PurchaseCompletedBlock) {
        invokedPurchaseProductWithDiscount = true
        invokedPurchaseProductWithDiscountCount += 1
        invokedPurchaseProductWithDiscountParameters = (product,
            discount,
            completion)
        invokedPurchaseProductWithDiscountParametersList.append((product,
                                                                    discount,
                                                                    completion))
    }

    var invokedPurchasePackageWithDiscount = false
    var invokedPurchasePackageWithDiscountCount = 0
    var invokedPurchasePackageWithDiscountParameters: (package: Purchases.Package, discount: SKPaymentDiscount, completion: Purchases.PurchaseCompletedBlock)?
    var invokedPurchasePackageWithDiscountParametersList = [(package: Purchases.Package,
        discount: SKPaymentDiscount,
        completion: Purchases.PurchaseCompletedBlock)]()

    override func purchasePackage(_ package: Purchases.Package,
                                  discount: SKPaymentDiscount,
                                  _ completion: @escaping Purchases.PurchaseCompletedBlock) {
        invokedPurchasePackageWithDiscount = true
        invokedPurchasePackageWithDiscountCount += 1
        invokedPurchasePackageWithDiscountParameters = (package, discount, completion)
        invokedPurchasePackageWithDiscountParametersList.append((package, discount, completion))
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
    
}
