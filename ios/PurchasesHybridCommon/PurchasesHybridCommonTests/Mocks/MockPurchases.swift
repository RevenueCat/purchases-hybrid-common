//
// Created by Andrés Boedo on 4/7/21.
// Copyright (c) 2021 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat
import StoreKit

final class MockPurchases: PurchasesType {

    var cachedCustomerInfo: RevenueCat.CustomerInfo?

    var cachedOfferings: RevenueCat.Offerings?

    var cachedVirtualCurrencies: RevenueCat.VirtualCurrencies?

    var delegate: RevenueCat.PurchasesDelegate?

    init() {}

    var invokedAppUserIDGetter = false
    var invokedAppUserIDGetterCount = 0
    var stubbedAppUserID: String! = ""
    var appUserID: String {
        invokedAppUserIDGetter = true
        invokedAppUserIDGetterCount += 1
        return stubbedAppUserID
    }
    var invokedIsAnonymousGetter = false
    var invokedIsAnonymousGetterCount = 0
    var stubbedIsAnonymous: Bool! = false
    var isAnonymous: Bool {
        invokedIsAnonymousGetter = true
        invokedIsAnonymousGetterCount += 1
        return stubbedIsAnonymous
    }

    var invokedStoreFrontCountryCodeGetter = false
    var invokedStoreFrontCountryCodeGetterCount = 0
    var stubbedStoreFrontCountryCode: String? = nil
    var storeFrontCountryCode: String? {
        invokedStoreFrontCountryCodeGetter = true
        invokedStoreFrontCountryCodeGetterCount += 1
        return stubbedStoreFrontCountryCode
    }

    var invokedGetStorefront = false
    var invokedGetStorefrontCount = 0
    var invokedGetStorefrontParametersList: [(RevenueCat.GetStorefrontBlock)] = []
    func getStorefront(completion: @escaping RevenueCat.GetStorefrontBlock) {
        invokedGetStorefront = true
        invokedGetStorefrontCount += 1
        invokedGetStorefrontParametersList.append(completion)
    }

    var invokedGetStorefrontAsync = false
    var invokedGetStorefrontAsyncCount = 0
    var stubbedGetStorefrontAsyncResult: RevenueCat.Storefront? = nil
    func getStorefront() async -> RevenueCat.Storefront? {
        invokedGetStorefrontAsync = true
        invokedGetStorefrontAsyncCount += 1
        return stubbedGetStorefrontAsyncResult
    }

    var invokedLogInPublicError = false
    var invokedLogInCount = 0
    var invokedLogInParameters: (appUserID: String, Void)?
    var invokedLogInParametersList = [(appUserID: String, Void)]()
    var stubbedLogInCompletionResult: (CustomerInfo?, Bool, PublicError?)?

    func logIn(_ appUserID: String,
               completion: @escaping (CustomerInfo?, Bool, PublicError?) -> ()) {
        invokedLogInPublicError = true
        invokedLogInCount += 1
        invokedLogInParameters = (appUserID, ())
        invokedLogInParametersList.append((appUserID, ()))
        if let result = stubbedLogInCompletionResult {
            completion(result.0, result.1, result.2)
        }
    }

    var invokedLogOut = false
    var invokedLogOutCount = 0
    var invokedLogOutParameters: (completion: ((CustomerInfo?, PublicError?) -> ())?, Void)?
    var invokedLogOutParametersList = [(completion: ((CustomerInfo?, PublicError?) -> ())?, Void)]()
    var stubbedLogOutCompletionResult: (CustomerInfo?, PublicError?)?

    func logOut(completion: ((CustomerInfo?, PublicError?) -> ())?) {
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
    var invokedCreateAliasParameters: (alias: String, completion: ((CustomerInfo?, PublicError?) -> ())?)?
    var invokedCreateAliasParametersList = [(alias: String,
                                             completion: ((CustomerInfo?, PublicError?) -> ())?)]()

    var invokedCustomerInfo = false
    var invokedCustomerInfoCount = 0
    var invokedCustomerInfoParameters: (completion: ((CustomerInfo?, PublicError?) -> ()), Void)?
    var invokedCustomerInfoParametersList = [(completion: ((CustomerInfo?, PublicError?) -> ()),
                                              Void)]()

    func getCustomerInfo(completion: @escaping ((CustomerInfo?, PublicError?) -> ())) {
        invokedCustomerInfo = true
        invokedCustomerInfoCount += 1
        invokedCustomerInfoParameters = (completion, ())
        invokedCustomerInfoParametersList.append((completion, ()))
    }


    func getCustomerInfo(fetchPolicy: CacheFetchPolicy, completion: @escaping (CustomerInfo?, PublicError?) -> Void) {
        invokedCustomerInfo = true
        invokedCustomerInfoCount += 1
        invokedCustomerInfoParameters = (completion, ())
        invokedCustomerInfoParametersList.append((completion, ()))
    }

    var invokedOfferings = false
    var invokedOfferingsCount = 0
    var invokedOfferingsParameters: (completion: ((Offerings?, PublicError?) -> ()), Void)?
    var invokedOfferingsParametersList = [(completion: ((Offerings?, PublicError?) -> ()), Void)]()

    func getOfferings(completion: @escaping ((Offerings?, PublicError?) -> ())) {
        invokedOfferings = true
        invokedOfferingsCount += 1
        invokedOfferingsParameters = (completion, ())
        invokedOfferingsParametersList.append((completion, ()))
    }

    var invokedSyncAttributesAndOfferingsIfNeeded = false
    var invokedSyncAttributesAndOfferingsIfNeededCount = 0
    var invokedSyncAttributesAndOfferingsIfNeededParameters: (completion: ((Offerings?, PublicError?) -> ()), Void)?
    var invokedSyncAttributesAndOfferingsIfNeededParametersList = [(completion: ((Offerings?, PublicError?) -> ()), Void)]()

    func syncAttributesAndOfferingsIfNeeded(completion: @escaping (RevenueCat.Offerings?, RevenueCat.PublicError?) -> Void) {
        invokedSyncAttributesAndOfferingsIfNeeded = true
        invokedSyncAttributesAndOfferingsIfNeededCount += 1
        invokedSyncAttributesAndOfferingsIfNeededParameters = (completion, ())
        invokedSyncAttributesAndOfferingsIfNeededParametersList.append((completion, ()))
    }

    var invokedProducts = false
    var invokedProductsCount = 0
    var invokedProductsParameters: (productIdentifiers: [String], completion: ([StoreProduct]) -> ())?
    var invokedProductsParametersList: [(productIdentifiers: [String], completion: ([StoreProduct]) -> ())] = []

    func getProducts(_ productIdentifiers: [String],
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

    func purchase(product: StoreProduct, completion: @escaping PurchaseCompletedBlock) {
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

    func purchase(package: Package,
                  completion: @escaping PurchaseCompletedBlock) {
        invokedPurchasePackage = true
        invokedPurchasePackageCount += 1
        invokedPurchasePackageParameters = (package, completion)
        invokedPurchasePackageParametersList.append((package, completion))
    }

    var invokedRestoreTransactions = false
    var invokedRestoreTransactionsCount = 0
    var invokedRestoreTransactionsParameters: (completion: ((CustomerInfo?, PublicError?) -> ())?, Void)?
    var invokedRestoreTransactionsParametersList = [(completion: ((CustomerInfo?, PublicError?) -> ())?,
                                                     Void)]()

    func restorePurchases(completion: ((CustomerInfo?, PublicError?) -> ())?) {
        invokedRestoreTransactions = true
        invokedRestoreTransactionsCount += 1
        invokedRestoreTransactionsParameters = (completion, ())
        invokedRestoreTransactionsParametersList.append((completion, ()))
    }

    var invokedSyncPurchases = false
    var invokedSyncPurchasesCount = 0
    var invokedSyncPurchasesParameters: (completion: ((CustomerInfo?, PublicError?) -> ())?, Void)?
    var invokedSyncPurchasesParametersList = [(completion: ((CustomerInfo?, PublicError?) -> ())?,
                                               Void)]()

    func syncPurchases(completion: ((CustomerInfo?, PublicError?) -> ())?) {
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

    func checkTrialOrIntroDiscountEligibility(productIdentifiers: [String],
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
                                               completion: (PromotionalOffer?, PublicError?) -> Void)?
    var invokedGetPromotionalOfferParametersList = [(
        discount: StoreProductDiscount,
        product: StoreProduct,
        completion: (PromotionalOffer?, PublicError?) -> Void)]()

    func getPromotionalOffer(forProductDiscount discount: StoreProductDiscount,
                             product: StoreProduct,
                             completion: @escaping ((PromotionalOffer?, PublicError?) -> Void)) {
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

    func purchase(product: StoreProduct,
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

    func purchase(package: Package,
                  promotionalOffer: PromotionalOffer,
                  completion: @escaping PurchaseCompletedBlock) {
        invokedPurchasePackageWithPromotionalOffer = true
        invokedPurchasePackageWithPromotionalOfferCount += 1
        invokedPurchasePackageWithPromotionalOfferParameters = (package, promotionalOffer, completion)
        invokedPurchasePackageWithPromotionalOfferParametersList.append((package, promotionalOffer, completion))
    }

    var invokedPurchaseParamsCompletion = false
    var invokedPurchaseParamsCompletionCount = 0
    var invokedPurchaseParamsCompletionParameters: (params: PurchaseParams, completion: PurchaseCompletedBlock)?
    var invokedPurchaseParamsCompletionParametersList: [(params: PurchaseParams, completion: PurchaseCompletedBlock)] = []
    func purchase(
        _ params: PurchaseParams,
        completion: @escaping PurchaseCompletedBlock
    ) {
        invokedPurchaseParamsCompletion = true
        invokedPurchaseParamsCompletionCount += 1
        invokedPurchaseParamsCompletionParameters = (params, completion)
        invokedPurchaseParamsCompletionParametersList.append((params, completion))
    }

    var invokedPurchaseWithParamsCompletion = false
    var invokedPurchaseWithParamsCompletionCount = 0
    var invokedPurchaseWithParamsCompletionParameters: (params: PurchaseParams, completion: PurchaseCompletedBlock)?
    var invokedPurchaseWithParamsCompletionParametersList: [(params: PurchaseParams, completion: PurchaseCompletedBlock)] = []
    func purchaseWithParams(_ params: RevenueCat.PurchaseParams, completion: @escaping RevenueCat.PurchaseCompletedBlock) {
        invokedPurchaseWithParamsCompletion = true
        invokedPurchaseWithParamsCompletionCount += 1
        invokedPurchaseWithParamsCompletionParameters = (params, completion)
        invokedPurchaseWithParamsCompletionParametersList.append((params, completion))
    }

    var invokedEligibleWinBackOffersForProductCompletion = false
    var invokedEligibleWinBackOffersForProductCompletionCount = 0
    var invokedEligibleWinBackOffersForProductCompletionParameters: (
        product: StoreProduct,
        completion: ([WinBackOffer]?, PublicError?) -> Void
    )?
    var invokedEligibleWinBackOffersForProductCompletionParametersList: [(
        product: StoreProduct,
        completion: ([WinBackOffer]?, PublicError?) -> Void
    )] = []
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
    func eligibleWinBackOffers(
        forProduct product: StoreProduct,
        completion: @escaping @Sendable ([WinBackOffer]?, PublicError?) -> Void
    ) {
        invokedEligibleWinBackOffersForProductCompletion = true
        invokedEligibleWinBackOffersForProductCompletionCount += 1
        invokedEligibleWinBackOffersForProductCompletionParameters = (product, completion)
        invokedEligibleWinBackOffersForProductCompletionParametersList.append((product, completion))
    }

    var invokedEligibleWinBackOffersForPackageCompletion = false
    var invokedEligibleWinBackOffersForPackageCompletionCount = 0
    var invokedEligibleWinBackOffersForPackageCompletionParameters: (
        package: Package,
        completion: ([WinBackOffer]?, PublicError?) -> Void
    )?
    var invokedEligibleWinBackOffersForPackageCompletionParametersList: [(
        package: Package,
        completion: ([WinBackOffer]?, PublicError?) -> Void
    )] = []
    func eligibleWinBackOffers(
        forPackage package: RevenueCat.Package,
        completion: @escaping @Sendable ([RevenueCat.WinBackOffer]?,
        RevenueCat.PublicError?) -> Void
    ) {
        invokedEligibleWinBackOffersForPackageCompletion = true
        invokedEligibleWinBackOffersForPackageCompletionCount += 1
        invokedEligibleWinBackOffersForPackageCompletionParameters = (package, completion)
        invokedEligibleWinBackOffersForPackageCompletionParametersList.append((package, completion))
    }

    var invokedRedeemWebPurchase = false
    var invokedRedeemWebPurchaseCount = 0
    var invokedRedeemWebPurchaseParameters: (
        webPurchaseRedemption: WebPurchaseRedemption,
        completion: (CustomerInfo?, PublicError?) -> Void)?
    var invokedRedeemWebPurchaseParametersList: [
        (webPurchaseRedemption: WebPurchaseRedemption, completion: (CustomerInfo?, PublicError?) -> Void)
    ] = []
    func redeemWebPurchase(
        webPurchaseRedemption: WebPurchaseRedemption,
        completion: @escaping (CustomerInfo?, PublicError?) -> Void
    ) {
        invokedRedeemWebPurchase = true
        invokedRedeemWebPurchaseCount += 1
        invokedRedeemWebPurchaseParameters = (webPurchaseRedemption, completion)
        invokedRedeemWebPurchaseParametersList.append((webPurchaseRedemption, completion))
    }

    var invokedInvalidateCustomerInfoCache = false
    var invokedInvalidateCustomerInfoCacheCount = 0

    func invalidateCustomerInfoCache() {
        invokedInvalidateCustomerInfoCache = true
        invokedInvalidateCustomerInfoCacheCount += 1
    }

    var invokedPresentCodeRedemptionSheet = false
    var invokedPresentCodeRedemptionSheetCount = 0

    @available(iOS 14.0, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    func presentCodeRedemptionSheet() {
        invokedPresentCodeRedemptionSheet = true
        invokedPresentCodeRedemptionSheetCount += 1
    }

    var invokedSetAttributes = false
    var invokedSetAttributesCount = 0
    var invokedSetAttributesParameters: (attributes: [String: String], Void)?
    var invokedSetAttributesParametersList = [(attributes: [String: String], Void)]()

    func setAttributes(_ attributes: [String: String]) {
        invokedSetAttributes = true
        invokedSetAttributesCount += 1
        invokedSetAttributesParameters = (attributes, ())
        invokedSetAttributesParametersList.append((attributes, ()))
    }

    var invokedSetEmail = false
    var invokedSetEmailCount = 0
    var invokedSetEmailParameters: (email: String?, Void)?
    var invokedSetEmailParametersList = [(email: String?, Void)]()

    func setEmail(_ email: String?) {
        invokedSetEmail = true
        invokedSetEmailCount += 1
        invokedSetEmailParameters = (email, ())
        invokedSetEmailParametersList.append((email, ()))
    }

    var invokedSetPhoneNumber = false
    var invokedSetPhoneNumberCount = 0
    var invokedSetPhoneNumberParameters: (phoneNumber: String?, Void)?
    var invokedSetPhoneNumberParametersList = [(phoneNumber: String?, Void)]()

    func setPhoneNumber(_ phoneNumber: String?) {
        invokedSetPhoneNumber = true
        invokedSetPhoneNumberCount += 1
        invokedSetPhoneNumberParameters = (phoneNumber, ())
        invokedSetPhoneNumberParametersList.append((phoneNumber, ()))
    }

    var invokedSetDisplayName = false
    var invokedSetDisplayNameCount = 0
    var invokedSetDisplayNameParameters: (displayName: String?, Void)?
    var invokedSetDisplayNameParametersList = [(displayName: String?, Void)]()

    func setDisplayName(_ displayName: String?) {
        invokedSetDisplayName = true
        invokedSetDisplayNameCount += 1
        invokedSetDisplayNameParameters = (displayName, ())
        invokedSetDisplayNameParametersList.append((displayName, ()))
    }

    var invokedSetPushToken = false
    var invokedSetPushTokenCount = 0
    var invokedSetPushTokenParameters: (pushToken: Data?, Void)?
    var invokedSetPushTokenParametersList = [(pushToken: Data?, Void)]()

    func setPushToken(_ pushToken: Data?) {
        invokedSetPushToken = true
        invokedSetPushTokenCount += 1
        invokedSetPushTokenParameters = (pushToken, ())
        invokedSetPushTokenParametersList.append((pushToken, ()))
    }

    var invokedSetAdjustID = false
    var invokedSetAdjustIDCount = 0
    var invokedSetAdjustIDParameters: (adjustID: String?, Void)?
    var invokedSetAdjustIDParametersList = [(adjustID: String?, Void)]()

    func setAdjustID(_ adjustID: String?) {
        invokedSetAdjustID = true
        invokedSetAdjustIDCount += 1
        invokedSetAdjustIDParameters = (adjustID, ())
        invokedSetAdjustIDParametersList.append((adjustID, ()))
    }

    var invokedSetAppsflyerID = false
    var invokedSetAppsflyerIDCount = 0
    var invokedSetAppsflyerIDParameters: (appsflyerID: String?, Void)?
    var invokedSetAppsflyerIDParametersList = [(appsflyerID: String?, Void)]()

    func setAppsflyerID(_ appsflyerID: String?) {
        invokedSetAppsflyerID = true
        invokedSetAppsflyerIDCount += 1
        invokedSetAppsflyerIDParameters = (appsflyerID, ())
        invokedSetAppsflyerIDParametersList.append((appsflyerID, ()))
    }

    var invokedSetFBAnonymousID = false
    var invokedSetFBAnonymousIDCount = 0
    var invokedSetFBAnonymousIDParameters: (fbAnonymousID: String?, Void)?
    var invokedSetFBAnonymousIDParametersList = [(fbAnonymousID: String?, Void)]()

    func setFBAnonymousID(_ fbAnonymousID: String?) {
        invokedSetFBAnonymousID = true
        invokedSetFBAnonymousIDCount += 1
        invokedSetFBAnonymousIDParameters = (fbAnonymousID, ())
        invokedSetFBAnonymousIDParametersList.append((fbAnonymousID, ()))
    }

    var invokedSetMparticleID = false
    var invokedSetMparticleIDCount = 0
    var invokedSetMparticleIDParameters: (mparticleID: String?, Void)?
    var invokedSetMparticleIDParametersList = [(mparticleID: String?, Void)]()

    func setMparticleID(_ mparticleID: String?) {
        invokedSetMparticleID = true
        invokedSetMparticleIDCount += 1
        invokedSetMparticleIDParameters = (mparticleID, ())
        invokedSetMparticleIDParametersList.append((mparticleID, ()))
    }

    var invokedSetOnesignalID = false
    var invokedSetOnesignalIDCount = 0
    var invokedSetOnesignalIDParameters: (onesignalID: String?, Void)?
    var invokedSetOnesignalIDParametersList = [(onesignalID: String?, Void)]()

    func setOnesignalID(_ onesignalID: String?) {
        invokedSetOnesignalID = true
        invokedSetOnesignalIDCount += 1
        invokedSetOnesignalIDParameters = (onesignalID, ())
        invokedSetOnesignalIDParametersList.append((onesignalID, ()))
    }

    var invokedSetPostHogUserID = false
    var invokedSetPostHogUserIDCount = 0
    var invokedSetPostHogUserIDParameters: (postHogUserID: String?, Void)?
    var invokedSetPostHogUserIDParametersList = [(postHogUserID: String?, Void)]()

    func setPostHogUserID(_ postHogUserID: String?) {
        invokedSetPostHogUserID = true
        invokedSetPostHogUserIDCount += 1
        invokedSetPostHogUserIDParameters = (postHogUserID, ())
        invokedSetPostHogUserIDParametersList.append((postHogUserID, ()))
    }

    var invokedSetMediaSource = false
    var invokedSetMediaSourceCount = 0
    var invokedSetMediaSourceParameters: (mediaSource: String?, Void)?
    var invokedSetMediaSourceParametersList = [(mediaSource: String?, Void)]()

    func setMediaSource(_ mediaSource: String?) {
        invokedSetMediaSource = true
        invokedSetMediaSourceCount += 1
        invokedSetMediaSourceParameters = (mediaSource, ())
        invokedSetMediaSourceParametersList.append((mediaSource, ()))
    }

    var invokedSetCampaign = false
    var invokedSetCampaignCount = 0
    var invokedSetCampaignParameters: (campaign: String?, Void)?
    var invokedSetCampaignParametersList = [(campaign: String?, Void)]()

    func setCampaign(_ campaign: String?) {
        invokedSetCampaign = true
        invokedSetCampaignCount += 1
        invokedSetCampaignParameters = (campaign, ())
        invokedSetCampaignParametersList.append((campaign, ()))
    }

    var invokedSetAdGroup = false
    var invokedSetAdGroupCount = 0
    var invokedSetAdGroupParameters: (adGroup: String?, Void)?
    var invokedSetAdGroupParametersList = [(adGroup: String?, Void)]()

    func setAdGroup(_ adGroup: String?) {
        invokedSetAdGroup = true
        invokedSetAdGroupCount += 1
        invokedSetAdGroupParameters = (adGroup, ())
        invokedSetAdGroupParametersList.append((adGroup, ()))
    }

    var invokedSetAd = false
    var invokedSetAdCount = 0
    var invokedSetAdParameters: (ad: String?, Void)?
    var invokedSetAdParametersList = [(ad: String?, Void)]()

    func setAd(_ ad: String?) {
        invokedSetAd = true
        invokedSetAdCount += 1
        invokedSetAdParameters = (ad, ())
        invokedSetAdParametersList.append((ad, ()))
    }

    var invokedSetKeyword = false
    var invokedSetKeywordCount = 0
    var invokedSetKeywordParameters: (keyword: String?, Void)?
    var invokedSetKeywordParametersList = [(keyword: String?, Void)]()

    func setKeyword(_ keyword: String?) {
        invokedSetKeyword = true
        invokedSetKeywordCount += 1
        invokedSetKeywordParameters = (keyword, ())
        invokedSetKeywordParametersList.append((keyword, ()))
    }

    var invokedSetCreative = false
    var invokedSetCreativeCount = 0
    var invokedSetCreativeParameters: (creative: String?, Void)?
    var invokedSetCreativeParametersList = [(creative: String?, Void)]()

    func setCreative(_ creative: String?) {
        invokedSetCreative = true
        invokedSetCreativeCount += 1
        invokedSetCreativeParameters = (creative, ())
        invokedSetCreativeParametersList.append((creative, ()))
    }

    var invokedCollectDeviceIdentifiers = false
    var invokedCollectDeviceIdentifiersCount = 0

    func collectDeviceIdentifiers() {
        invokedCollectDeviceIdentifiers = true
        invokedCollectDeviceIdentifiersCount += 1
    }


    var invokedBeginRefundRequestForProduct = false
    var invokedBeginRefundRequestForProductCount = 0
    var invokedBeginRefundRequestForProductParameters: (productId: String,
                                                        (Result<RefundRequestStatus, PublicError>) -> Void)?
    var invokedBeginRefundRequestForProductParametersList = [(productId: String,
                                                              (Result<RefundRequestStatus, PublicError>) -> Void)]()

    func beginRefundRequest(forProduct productID: String,
                            completion: @escaping (Result<RefundRequestStatus, PublicError>) -> Void) {
        invokedBeginRefundRequestForProduct = true
        invokedBeginRefundRequestForProductCount += 1
        invokedBeginRefundRequestForProductParameters = (productID, completion)
        invokedBeginRefundRequestForProductParametersList.append((productID, completion))
    }

    var invokedBeginRefundRequestForEntitlement = false
    var invokedBeginRefundRequestForEntitlementCount = 0
    var invokedBeginRefundRequestForEntitlementParameters: (entitlementId: String,
                                                            (Result<RefundRequestStatus, PublicError>) -> Void)?
    var invokedBeginRefundRequestForEntitlementParametersList = [(entitlementId: String,
                                                                  (Result<RefundRequestStatus, PublicError>) -> Void)]()

    func beginRefundRequest(forEntitlement entitlementID: String,
                            completion: @escaping (Result<RefundRequestStatus, PublicError>) -> Void) {
        invokedBeginRefundRequestForEntitlement = true
        invokedBeginRefundRequestForEntitlementCount += 1
        invokedBeginRefundRequestForEntitlementParameters = (entitlementID, completion)
        invokedBeginRefundRequestForEntitlementParametersList.append((entitlementID, completion))
    }

    var invokedBeginRefundRequestForActiveEntitlement = false
    var invokedBeginRefundRequestForActiveEntitlementCount = 0
    var invokedBeginRefundRequestForActiveEntitlementParameter: ((Result<RefundRequestStatus, PublicError>) -> Void)?
    var invokedBeginRefundRequestForActiveEntitlementParameterList =
        [(Result<RefundRequestStatus, PublicError>) -> Void]()

    func beginRefundRequestForActiveEntitlement(completion: @escaping (Result<RefundRequestStatus, PublicError>) -> Void) {
        invokedBeginRefundRequestForActiveEntitlement = true
        invokedBeginRefundRequestForActiveEntitlementCount += 1
        invokedBeginRefundRequestForActiveEntitlementParameter = completion
        invokedBeginRefundRequestForActiveEntitlementParameterList.append(completion)
    }

    var invokedGetVirtualCurrencies = false
    var invokedGetVirtualCurrenciesCount = 0
    var getVirtualCurrenciesStub: Result<VirtualCurrencies, PublicError> = .failure(NSError(domain: "", code: -1))
    func getVirtualCurrencies(completion: @escaping @Sendable (RevenueCat.VirtualCurrencies?, PublicError?) -> Void) {
        self.invokedGetVirtualCurrencies = true
        self.invokedGetVirtualCurrenciesCount += 1

        switch getVirtualCurrenciesStub {
        case .success(let virtualCurrencies):
            completion(virtualCurrencies, nil)
        case .failure(let error):
            completion(nil, error)
        }
    }

    var invokedInvalidateVirtualCurrenciesCache = false
    var invokedInvalidateVirtualCurrenciesCacheCount = 0
    func invalidateVirtualCurrenciesCache() {
        invokedInvalidateVirtualCurrenciesCache = true
        invokedInvalidateVirtualCurrenciesCacheCount += 1
    }
}

extension MockPurchases {

    func checkTrialOrIntroDiscountEligibility(product: RevenueCat.StoreProduct, completion: @escaping (RevenueCat.IntroEligibilityStatus) -> Void) {
        fatalError("Not mocked")
    }

    func setPushTokenString(_ pushToken: String?) {
        fatalError("Not mocked")
    }

    func setCleverTapID(_ cleverTapID: String?) {
        fatalError("Not mocked")
    }

    func setMixpanelDistinctID(_ mixpanelDistinctID: String?) {
        fatalError("Not mocked")
    }

    func setFirebaseAppInstanceID(_ firebaseAppInstanceID: String?) {
        fatalError("Not mocked")
    }

    var finishTransactions: Bool {
        get { fatalError("Not mocked") }
        set { fatalError("Not mocked") }
    }

    var purchasesAreCompletedBy: RevenueCat.PurchasesAreCompletedBy {
        get { fatalError("Not mocked") }
        set { fatalError("Not mocked") }
    }

    var attribution: Attribution {
        get { fatalError("Not mocked") }
        set { fatalError("Not mocked") }
    }

    var allowSharingAppStoreAccount: Bool {
        get { fatalError("Not mocked") }
        set { fatalError("Not mocked") }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
extension MockPurchases: PurchasesSwiftType {
    var customerInfoStream: AsyncStream<CustomerInfo> {
        fatalError("This method is not mocked")
    }

    func logIn(_ appUserID: String) async throws -> (customerInfo: RevenueCat.CustomerInfo, created: Bool) {
        fatalError("Not mocked")
    }

    func logOut() async throws -> RevenueCat.CustomerInfo {
        fatalError("Not mocked")
    }

    func customerInfo() async throws -> RevenueCat.CustomerInfo {
        fatalError("Not mocked")
    }

    func customerInfo(fetchPolicy: RevenueCat.CacheFetchPolicy) async throws -> RevenueCat.CustomerInfo {
        fatalError("Not mocked")
    }

    func offerings() async throws -> RevenueCat.Offerings {
        fatalError("Not mocked")
    }

    func products(_ productIdentifiers: [String]) async -> [RevenueCat.StoreProduct] {
        fatalError("Not mocked")
    }

    func purchase(product: RevenueCat.StoreProduct) async throws -> RevenueCat.PurchaseResultData {
        fatalError("Not mocked")
    }

    func purchase(package: RevenueCat.Package) async throws -> RevenueCat.PurchaseResultData {
        fatalError("Not mocked")
    }

    func purchase(product: RevenueCat.StoreProduct, promotionalOffer: RevenueCat.PromotionalOffer) async throws -> RevenueCat.PurchaseResultData {
        fatalError("Not mocked")
    }

    func purchase(package: RevenueCat.Package, promotionalOffer: RevenueCat.PromotionalOffer) async throws -> RevenueCat.PurchaseResultData {
        fatalError("Not mocked")
    }

    func restorePurchases() async throws -> RevenueCat.CustomerInfo {
        fatalError("Not mocked")
    }

    func syncPurchases() async throws -> RevenueCat.CustomerInfo {
        fatalError("Not mocked")
    }

    func checkTrialOrIntroDiscountEligibility(productIdentifiers: [String]) async -> [String : RevenueCat.IntroEligibility] {
        fatalError("Not mocked")
    }

    func checkTrialOrIntroDiscountEligibility(product: RevenueCat.StoreProduct) async -> RevenueCat.IntroEligibilityStatus {
        fatalError("Not mocked")
    }

    func promotionalOffer(forProductDiscount discount: RevenueCat.StoreProductDiscount, product: RevenueCat.StoreProduct) async throws -> RevenueCat.PromotionalOffer {
        fatalError("Not mocked")
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func eligiblePromotionalOffers(forProduct product: StoreProduct) async -> [PromotionalOffer] {
        fatalError("This method is not mocked")
    }

    func beginRefundRequest(forProduct productID: String) async throws -> RevenueCat.RefundRequestStatus {
        fatalError("Not mocked")
    }

    func beginRefundRequest(forEntitlement entitlementID: String) async throws -> RevenueCat.RefundRequestStatus {
        fatalError("Not mocked")
    }

    func beginRefundRequestForActiveEntitlement() async throws -> RevenueCat.RefundRequestStatus {
        fatalError("Not mocked")
    }

    func showPriceConsentIfNeeded() {
        fatalError("Not mocked")
    }

    func showManageSubscriptions(completion: @escaping (RevenueCat.PublicError?) -> Void) {
        fatalError("Not mocked")
    }

    func showManageSubscriptions() async throws {
        fatalError("Not mocked")
    }

    func showStoreMessages(for types: Set<StoreMessageType>) async {
        fatalError("Not mocked")
    }

    func syncAttributesAndOfferingsIfNeeded() async throws -> RevenueCat.Offerings? {
        fatalError("Not mocked")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func recordPurchase(
        _ purchaseResult: Product.PurchaseResult
    ) async throws -> RevenueCat.StoreTransaction? {
        fatalError("Not mocked")
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
    func eligibleWinBackOffers(forProduct product: RevenueCat.StoreProduct) async throws -> [RevenueCat.WinBackOffer] {
        fatalError("Not mocked")
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
    func eligibleWinBackOffers(forPackage package: Package) async throws -> [WinBackOffer] {
        fatalError("Not mocked")
    }

    func purchase(
        _ params: PurchaseParams
    ) async throws -> PurchaseResultData {
        fatalError("Not mocked")
    }

    func redeemWebPurchase(_ webPurchaseRedemption: WebPurchaseRedemption) async -> WebPurchaseRedemptionResult {
        fatalError("Not mocked")
    }

    func virtualCurrencies() async throws -> RevenueCat.VirtualCurrencies {
        fatalError("Not mocked")
    }
}
