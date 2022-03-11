//
// Created by Andrés Boedo on 4/7/21.
// Copyright (c) 2021 RevenueCat. All rights reserved.
//

import Foundation
@testable import RevenueCat

class MockPurchases: Purchases {
    
    init() {
        let systemInfo = try! SystemInfo(platformInfo: nil, finishTransactions: true)
        let deviceCache: DeviceCache = DeviceCache(systemInfo: systemInfo)
        
        let operationDispatcher: OperationDispatcher = OperationDispatcher()
        
        let requestFetcher: StoreKitRequestFetcher = StoreKitRequestFetcher(operationDispatcher: operationDispatcher)
        let receiptFetcher: ReceiptFetcher = ReceiptFetcher(requestFetcher: requestFetcher, systemInfo: systemInfo)
        let attributionFetcher: AttributionFetcher = AttributionFetcher(attributionFactory: AttributionTypeFactory(), systemInfo: systemInfo)
        
        let eTagManager = ETagManager(userDefaults: UserDefaults.standard)
        let backend: Backend = Backend(apiKey: "", systemInfo: systemInfo, eTagManager: eTagManager)
        
        let customerInfoManager: CustomerInfoManager = CustomerInfoManager(operationDispatcher: operationDispatcher, deviceCache: deviceCache, backend: backend, systemInfo: systemInfo)
        
        let identityManager: IdentityManager = IdentityManager(
            deviceCache: deviceCache,
            backend: backend,
            customerInfoManager: customerInfoManager,
            appUserID: nil)
        
        let attributionDataMigrator = AttributionDataMigrator()
        let subscriberAttributesManager = SubscriberAttributesManager(backend: backend, deviceCache: deviceCache, attributionFetcher: attributionFetcher, attributionDataMigrator: attributionDataMigrator)
        
        let attributionPoster: AttributionPoster = AttributionPoster(
            deviceCache: deviceCache,
            identityManager: identityManager,
            backend: backend,
            attributionFetcher: attributionFetcher,
            subscriberAttributesManager: subscriberAttributesManager)
        
        let storeKitWrapper: StoreKitWrapper = StoreKitWrapper()
        let notificationCenter: NotificationCenter = NotificationCenter.default
        
        let offeringsFactory: OfferingsFactory = OfferingsFactory()
        
        
        let productsManager: ProductsManager = ProductsManager(systemInfo: systemInfo)
        let offeringsManager: OfferingsManager = OfferingsManager(deviceCache: deviceCache, operationDispatcher: operationDispatcher, systemInfo: systemInfo, backend: backend, offeringsFactory: offeringsFactory, productsManager: productsManager)
        
        let introEligibilityCalculator: IntroEligibilityCalculator = IntroEligibilityCalculator(productsManager: productsManager, receiptParser: ReceiptParser())
        
        let manageSubscriptionsHelper = ManageSubscriptionsHelper(systemInfo: systemInfo, customerInfoManager: customerInfoManager, identityManager: identityManager)
        
        let beginRefundRequestHelper = BeginRefundRequestHelper(systemInfo: systemInfo, customerInfoManager: customerInfoManager, identityManager: identityManager)
        
        let purchasesOrchestrator: PurchasesOrchestrator = PurchasesOrchestrator(productsManager: productsManager, storeKitWrapper: storeKitWrapper, systemInfo: systemInfo, subscriberAttributesManager: subscriberAttributesManager, operationDispatcher: operationDispatcher, receiptFetcher: receiptFetcher, customerInfoManager: customerInfoManager, backend: backend, identityManager: identityManager, transactionsManager: TransactionsManager(receiptParser: ReceiptParser()), deviceCache: deviceCache, manageSubscriptionsHelper: manageSubscriptionsHelper, beginRefundRequestHelper: beginRefundRequestHelper)
        
        let trialOrIntroPriceEligibilityChecker: TrialOrIntroPriceEligibilityChecker = TrialOrIntroPriceEligibilityChecker(receiptFetcher: receiptFetcher, introEligibilityCalculator: introEligibilityCalculator, backend: backend, identityManager: identityManager, operationDispatcher: operationDispatcher, productsManager: productsManager)
        
        super.init(appUserID: nil,
                   requestFetcher: requestFetcher,
                   receiptFetcher: receiptFetcher,
                   attributionFetcher: attributionFetcher,
                   attributionPoster: attributionPoster,
                   backend: backend,
                   storeKitWrapper: storeKitWrapper,
                   notificationCenter: notificationCenter,
                   systemInfo: systemInfo,
                   offeringsFactory: offeringsFactory,
                   deviceCache: deviceCache,
                   identityManager: identityManager,
                   subscriberAttributesManager: subscriberAttributesManager,
                   operationDispatcher: operationDispatcher,
                   introEligibilityCalculator: introEligibilityCalculator,
                   customerInfoManager: customerInfoManager,
                   productsManager: productsManager,
                   offeringsManager: offeringsManager,
                   purchasesOrchestrator: purchasesOrchestrator,
                   trialOrIntroPriceEligibilityChecker: trialOrIntroPriceEligibilityChecker)
    }
    
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
    
    typealias ReceiveCustomerInfoBlock = (CustomerInfo?, Error?) -> ()

    var invokedLogOut = false
    var invokedLogOutCount = 0
    var invokedLogOutParameters: (completion: ReceiveCustomerInfoBlock?, Void)?
    var invokedLogOutParametersList = [(completion: ReceiveCustomerInfoBlock?, Void)]()
    var stubbedLogOutCompletionResult: (CustomerInfo?, Error?)?

    override func logOut(completion: ReceiveCustomerInfoBlock?) {
        invokedLogOut = true
        invokedLogOutCount += 1
        invokedLogOutParameters = (completion, ())
        invokedLogOutParametersList.append((completion, ()))
        if let completion = completion, let result = stubbedLogOutCompletionResult {
            completion(result.0, result.1)
        }
    }

//    var invokedCreateAlias = false
//    var invokedCreateAliasCount = 0
//    var invokedCreateAliasParameters: (alias: String, completion: ReceiveCustomerInfoBlock?)?
//    var invokedCreateAliasParametersList = [(alias: String,
//        completion: ReceiveCustomerInfoBlock?)]()
//
//    override func createAlias(_ alias: String, completion: ReceiveCustomerInfoBlock?) {
//        invokedCreateAlias = true
//        invokedCreateAliasCount += 1
//        invokedCreateAliasParameters = (alias, completion)
//        invokedCreateAliasParametersList.append((alias, completion))
//    }
//
//    var invokedIdentify = false
//    var invokedIdentifyCount = 0
//    var invokedIdentifyParameters: (appUserID: String, completion: ReceiveCustomerInfoBlock?)?
//    var invokedIdentifyParametersList = [(appUserID: String,
//        completion: ReceiveCustomerInfoBlock?)]()
//
//    func identify(_ appUserID: String,
//                           _ completion: ReceiveCustomerInfoBlock?) {
//        invokedIdentify = true
//        invokedIdentifyCount += 1
//        invokedIdentifyParameters = (appUserID, completion)
//        invokedIdentifyParametersList.append((appUserID, completion))
//    }
//
//    var invokedReset = false
//    var invokedResetCount = 0
//    var invokedResetParameters: (completion: ReceiveCustomerInfoBlock?, Void)?
//    var invokedResetParametersList = [(completion: ReceiveCustomerInfoBlock?, Void)]()
//
//    func reset(_ completion: ReceiveCustomerInfoBlock?) {
//        invokedReset = true
//        invokedResetCount += 1
//        invokedResetParameters = (completion, ())
//        invokedResetParametersList.append((completion, ()))
//    }

    var invokedCustomerInfo = false
    var invokedCustomerInfoCount = 0
    var invokedCustomerInfoParameters: (completion: ReceiveCustomerInfoBlock, Void)?
    var invokedCustomerInfoParametersList = [(completion: ReceiveCustomerInfoBlock,
        Void)]()
    
    override func getCustomerInfo(completion: @escaping ReceiveCustomerInfoBlock) {
        invokedCustomerInfo = true
        invokedCustomerInfoCount += 1
        invokedCustomerInfoParameters = (completion, ())
        invokedCustomerInfoParametersList.append((completion, ()))
    }
    
    typealias ReceiveOfferingsBlock = (Offerings?, Error?) -> ()

    var invokedOfferings = false
    var invokedOfferingsCount = 0
    var invokedOfferingsParameters: (completion: ReceiveOfferingsBlock, Void)?
    var invokedOfferingsParametersList = [(completion: ReceiveOfferingsBlock, Void)]()

    override func getOfferings(completion: @escaping ReceiveOfferingsBlock) {
        invokedOfferings = true
        invokedOfferingsCount += 1
        invokedOfferingsParameters = (completion, ())
        invokedOfferingsParametersList.append((completion, ()))
    }
    
    typealias ReceiveProductsBlock = ([StoreProduct]) -> ()

    var invokedProducts = false
    var invokedProductsCount = 0
    var invokedProductsParameters: (productIdentifiers: [String], completion: ReceiveProductsBlock)?
    var invokedProductsParametersList = [(productIdentifiers: [String],
        completion: ReceiveProductsBlock)]()
    
    override func getProducts(_ productIdentifiers: [String],
                           completion: @escaping ReceiveProductsBlock) {
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

    override func purchase(package: Package, completion: @escaping PurchaseCompletedBlock) {
        invokedPurchasePackage = true
        invokedPurchasePackageCount += 1
        invokedPurchasePackageParameters = (package, completion)
        invokedPurchasePackageParametersList.append((package, completion))
    }
    
    var invokedRestorePurchases = false
    var invokedRestorePurchasesCount = 0
    var invokedRestorePurchasesParameters: (completion: ReceiveCustomerInfoBlock?, Void)?
    var invokedRestorePurchasesParametersList = [(completion: ReceiveCustomerInfoBlock?,
        Void)]()
    
    override func restorePurchases(completion: ReceiveCustomerInfoBlock? = nil) {
        invokedRestorePurchases = true
        invokedRestorePurchasesCount += 1
        invokedRestorePurchasesParameters = (completion, ())
        invokedRestorePurchasesParametersList.append((completion, ()))
    }

    var invokedSyncPurchases = false
    var invokedSyncPurchasesCount = 0
    var invokedSyncPurchasesParameters: (completion: ReceiveCustomerInfoBlock?, Void)?
    var invokedSyncPurchasesParametersList = [(completion: ReceiveCustomerInfoBlock?,
        Void)]()

    override func syncPurchases(completion: ReceiveCustomerInfoBlock?) {
        invokedSyncPurchases = true
        invokedSyncPurchasesCount += 1
        invokedSyncPurchasesParameters = (completion, ())
        invokedSyncPurchasesParametersList.append((completion, ()))
    }
    
    typealias ReceiveIntroEligibilityBlock = ([String : IntroEligibility]) -> Void

    var invokedCheckTrialOrIntroductoryPriceEligibility = false
    var invokedCheckTrialOrIntroductoryPriceEligibilityCount = 0
    var invokedCheckTrialOrIntroductoryPriceEligibilityParameters: (productIdentifiers: [String], receiveEligibility: ReceiveIntroEligibilityBlock)?
    var invokedCheckTrialOrIntroductoryPriceEligibilityParametersList = [(
        productIdentifiers: [String],
        receiveEligibility: ReceiveIntroEligibilityBlock)]()
    
    override func checkTrialOrIntroDiscountEligibility(_ productIdentifiers: [String], completion: @escaping ([String : IntroEligibility]) -> Void) {
        invokedCheckTrialOrIntroductoryPriceEligibility = true
        invokedCheckTrialOrIntroductoryPriceEligibilityCount += 1
        invokedCheckTrialOrIntroductoryPriceEligibilityParameters = (
            productIdentifiers,
            completion)
        invokedCheckTrialOrIntroductoryPriceEligibilityParametersList.append(
            (productIdentifiers, completion))
    }

//    var invokedPaymentDiscount = false
//    var invokedPaymentDiscountCount = 0
//    var invokedPaymentDiscountParameters: (discount: SKProductDiscount, product: SKProduct, completion: Purchases.PaymentDiscountBlock)?
//    var invokedPaymentDiscountParametersList = [(
//        discount: SKProductDiscount,
//        product: SKProduct,
//        completion: Purchases.PaymentDiscountBlock)]()
//
//    override func paymentDiscount(for discount: SKProductDiscount,
//                                  product: SKProduct,
//                                  completion: @escaping Purchases.PaymentDiscountBlock) {
//        invokedPaymentDiscount = true
//        invokedPaymentDiscountCount += 1
//        invokedPaymentDiscountParameters = (discount,
//            product,
//            completion)
//        invokedPaymentDiscountParametersList.append(
//            (discount, product, completion))
//    }

    var invokedPurchaseProductWithDiscount = false
    var invokedPurchaseProductWithDiscountCount = 0
    var invokedPurchaseProductWithDiscountParameters: (product: StoreProduct, promotionalOffer: PromotionalOffer, completion: PurchaseCompletedBlock)?
    var invokedPurchaseProductWithDiscountParametersList = [(product: StoreProduct,
                                                             promotionalOffer: PromotionalOffer,
                                                             completion: PurchaseCompletedBlock)]()
    
    override func purchase(product: StoreProduct, promotionalOffer: PromotionalOffer, completion: @escaping PurchaseCompletedBlock) {
        invokedPurchaseProductWithDiscount = true
        invokedPurchaseProductWithDiscountCount += 1
        invokedPurchaseProductWithDiscountParameters = (product,
            promotionalOffer,
            completion)
        invokedPurchaseProductWithDiscountParametersList.append((product,
                                                                    promotionalOffer,
                                                                    completion))
    }

    var invokedPurchasePackageWithDiscount = false
    var invokedPurchasePackageWithDiscountCount = 0
    var invokedPurchasePackageWithDiscountParameters: (package: Package, promotionalOffer: PromotionalOffer, completion: PurchaseCompletedBlock)?
    var invokedPurchasePackageWithDiscountParametersList = [(package: Package,
                                                             promotionalOffer: PromotionalOffer,
                                                             completion: PurchaseCompletedBlock)]()
    
    override func purchase(package: Package, promotionalOffer: PromotionalOffer, completion: @escaping PurchaseCompletedBlock) {
        invokedPurchasePackageWithDiscount = true
        invokedPurchasePackageWithDiscountCount += 1
        invokedPurchasePackageWithDiscountParameters = (package, promotionalOffer, completion)
        invokedPurchasePackageWithDiscountParametersList.append((package, promotionalOffer, completion))
    }

    var invokedInvalidateCustomerInfoCache = false
    var invokedInvalidateCustomerInfoCacheCount = 0

    override func invalidateCustomerInfoCache() {
        invokedInvalidateCustomerInfoCache = true
        invokedInvalidateCustomerInfoCacheCount += 1
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
