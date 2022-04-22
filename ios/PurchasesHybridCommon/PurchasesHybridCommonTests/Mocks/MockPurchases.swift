//
// Created by Andrés Boedo on 4/7/21.
// Copyright (c) 2021 RevenueCat. All rights reserved.
//

import Foundation
@testable import RevenueCat
import StoreKit

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
    var stubbedLogInCompletionResult: (CustomerInfo?, Bool, Error?)?

    override func logIn(_ appUserID: String,
                        completion: @escaping (CustomerInfo?, Bool, Error?) -> ()) {
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
    var invokedLogOutParameters: (completion: ((CustomerInfo?, Error?) -> ())?, Void)?
    var invokedLogOutParametersList = [(completion: ((CustomerInfo?, Error?) -> ())?, Void)]()
    var stubbedLogOutCompletionResult: (CustomerInfo?, Error?)?

    override func logOut(completion: ((CustomerInfo?, Error?) -> ())?) {
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
    var invokedCreateAliasParameters: (alias: String, completion: ((CustomerInfo?, Error?) -> ())?)?
    var invokedCreateAliasParametersList = [(alias: String,
        completion: ((CustomerInfo?, Error?) -> ())?)]()

    var invokedPurchaserInfo = false
    var invokedPurchaserInfoCount = 0
    var invokedPurchaserInfoParameters: (completion: ((CustomerInfo?, Error?) -> ()), Void)?
    var invokedPurchaserInfoParametersList = [(completion: ((CustomerInfo?, Error?) -> ()),
        Void)]()

    override func getCustomerInfo(completion: @escaping ((CustomerInfo?, Error?) -> ())) {
        invokedPurchaserInfo = true
        invokedPurchaserInfoCount += 1
        invokedPurchaserInfoParameters = (completion, ())
        invokedPurchaserInfoParametersList.append((completion, ()))
    }

    var invokedOfferings = false
    var invokedOfferingsCount = 0
    var invokedOfferingsParameters: (completion: ((Offerings?, Error?) -> ()), Void)?
    var invokedOfferingsParametersList = [(completion: ((Offerings?, Error?) -> ()), Void)]()

    override func getOfferings(completion: @escaping ((Offerings?, Error?) -> ())) {
        invokedOfferings = true
        invokedOfferingsCount += 1
        invokedOfferingsParameters = (completion, ())
        invokedOfferingsParametersList.append((completion, ()))
    }

    var invokedProducts = false
    var invokedProductsCount = 0
    var invokedProductsParameters: (productIdentifiers: [String], completion: ([StoreProduct]) -> ())?
    var invokedProductsParametersList: [(productIdentifiers: [String], completion: ([StoreProduct]) -> ())] = []

    override func getProducts(_ productIdentifiers: [String],
                              completion: @escaping ([StoreProduct]) -> ()) {
        invokedProducts = true
        invokedProductsCount += 1
        invokedProductsParameters = (productIdentifiers, completion)
        invokedProductsParametersList.append((productIdentifiers, completion))
    }

    var invokedPurchaseProduct = false
    var invokedPurchaseProductCount = 0
    var invokedPurchaseProductParameters: (product: StoreProduct, completion: PurchaseCompletedBlock)?
    var invokedPurchaseProductParametersList = [(product: StoreProduct,
        completion: PurchaseCompletedBlock)]()

    override func purchase(product: StoreProduct, completion: @escaping PurchaseCompletedBlock) {
        invokedPurchaseProduct = true
        invokedPurchaseProductCount += 1
        invokedPurchaseProductParameters = (product, completion)
        invokedPurchaseProductParametersList.append((product, completion))
    }

    var invokedPurchasePackage = false
    var invokedPurchasePackageCount = 0
    var invokedPurchasePackageParameters: (package: Package, completion: PurchaseCompletedBlock)?
    var invokedPurchasePackageParametersList = [(package: Package,
        completion: PurchaseCompletedBlock)]()

    override func purchase(package: Package,
                           completion: @escaping PurchaseCompletedBlock) {
        invokedPurchasePackage = true
        invokedPurchasePackageCount += 1
        invokedPurchasePackageParameters = (package, completion)
        invokedPurchasePackageParametersList.append((package, completion))
    }

    var invokedRestoreTransactions = false
    var invokedRestoreTransactionsCount = 0
    var invokedRestoreTransactionsParameters: (completion: ((CustomerInfo?, Error?) -> ())?, Void)?
    var invokedRestoreTransactionsParametersList = [(completion: ((CustomerInfo?, Error?) -> ())?,
        Void)]()

    override func restorePurchases(completion: ((CustomerInfo?, Error?) -> ())?) {
        invokedRestoreTransactions = true
        invokedRestoreTransactionsCount += 1
        invokedRestoreTransactionsParameters = (completion, ())
        invokedRestoreTransactionsParametersList.append((completion, ()))
    }

    var invokedSyncPurchases = false
    var invokedSyncPurchasesCount = 0
    var invokedSyncPurchasesParameters: (completion: ((CustomerInfo?, Error?) -> ())?, Void)?
    var invokedSyncPurchasesParametersList = [(completion: ((CustomerInfo?, Error?) -> ())?,
        Void)]()

    override func syncPurchases(completion: ((CustomerInfo?, Error?) -> ())?) {
        invokedSyncPurchases = true
        invokedSyncPurchasesCount += 1
        invokedSyncPurchasesParameters = (completion, ())
        invokedSyncPurchasesParametersList.append((completion, ()))
    }

    var invokedCheckTrialOrIntroductoryPriceEligibility = false
    var invokedCheckTrialOrIntroductoryPriceEligibilityCount = 0
    var invokedCheckTrialOrIntroductoryPriceEligibilityParameters: (productIdentifiers: [String], receiveEligibility: ([String : IntroEligibility]) -> Void)?
    var invokedCheckTrialOrIntroductoryPriceEligibilityParametersList = [(
        productIdentifiers: [String],
        receiveEligibility: ([String : IntroEligibility]) -> Void)]()

    override func checkTrialOrIntroDiscountEligibility(productIdentifiers: [String],
                                                       completion receiveEligibility: @escaping ([String : IntroEligibility]) -> Void) {
        invokedCheckTrialOrIntroductoryPriceEligibility = true
        invokedCheckTrialOrIntroductoryPriceEligibilityCount += 1
        invokedCheckTrialOrIntroductoryPriceEligibilityParameters = (
            productIdentifiers,
            receiveEligibility)
        invokedCheckTrialOrIntroductoryPriceEligibilityParametersList.append(
            (productIdentifiers, receiveEligibility))
    }

    var invokedGetPromotionalOffer = false
    var invokedGetPromotionalOfferCount = 0
    var invokedGetPromotionalOfferParameters: (discount: StoreProductDiscount,
                                               product: StoreProduct,
                                               completion: (PromotionalOffer?, Error?) -> Void)?
    var invokedGetPromotionalOfferParametersList = [(
        discount: StoreProductDiscount,
        product: StoreProduct,
        completion: (PromotionalOffer?, Error?) -> Void)]()

    override func getPromotionalOffer(forProductDiscount discount: StoreProductDiscount,
                                      product: StoreProduct,
                                      completion: @escaping ((PromotionalOffer?, Error?) -> Void)) {
        invokedGetPromotionalOffer = true
        invokedGetPromotionalOfferCount += 1
        invokedGetPromotionalOfferParameters = (discount, product, completion)
        invokedGetPromotionalOfferParametersList.append(
            (discount, product, completion))
    }

    var invokedPurchaseProductWithPromotionalOffer = false
    var invokedPurchaseProductWithPromotionalOfferCount = 0
    var invokedPurchaseProductWithPromotionalOfferParameters: (product: StoreProduct,
                                                               promotionalOffer: PromotionalOffer,
                                                               completion: PurchaseCompletedBlock)?
    var invokedPurchaseProductWithPromotionalOfferParametersList = [(product: StoreProduct,
                                                                     promotionalOffer: PromotionalOffer,
                                                                     completion: PurchaseCompletedBlock)]()

    override func purchase(product: StoreProduct,
                           promotionalOffer: PromotionalOffer,
                           completion: @escaping PurchaseCompletedBlock) {
        invokedPurchaseProductWithPromotionalOffer = true
        invokedPurchaseProductWithPromotionalOfferCount += 1
        invokedPurchaseProductWithPromotionalOfferParameters = (product,
                                                                promotionalOffer,
                                                                completion)
        invokedPurchaseProductWithPromotionalOfferParametersList.append((product,
                                                                         promotionalOffer,
                                                                         completion))
    }

    var invokedPurchasePackageWithPromotionalOffer = false
    var invokedPurchasePackageWithPromotionalOfferCount = 0
    var invokedPurchasePackageWithPromotionalOfferParameters: (package: Package,
                                                       promotionalOffer: PromotionalOffer,
                                                       completion: PurchaseCompletedBlock)?
    var invokedPurchasePackageWithPromotionalOfferParametersList = [(package: Package,
        promotionalOffer: PromotionalOffer,
        completion: PurchaseCompletedBlock)]()

    override func purchase(package: Package,
                                  promotionalOffer: PromotionalOffer,
                                  completion: @escaping PurchaseCompletedBlock) {
        invokedPurchasePackageWithPromotionalOffer = true
        invokedPurchasePackageWithPromotionalOfferCount += 1
        invokedPurchasePackageWithPromotionalOfferParameters = (package, promotionalOffer, completion)
        invokedPurchasePackageWithPromotionalOfferParametersList.append((package, promotionalOffer, completion))
    }

    var invokedInvalidatePurchaserInfoCache = false
    var invokedInvalidatePurchaserInfoCacheCount = 0

    override func invalidateCustomerInfoCache() {
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
