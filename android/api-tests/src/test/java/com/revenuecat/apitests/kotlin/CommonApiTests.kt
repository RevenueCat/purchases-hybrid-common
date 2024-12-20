package com.revenuecat.apitests.kotlin

import android.app.Activity
import android.content.Context
import com.revenuecat.purchases.DangerousSettings
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.hybridcommon.ErrorContainer
import com.revenuecat.purchases.hybridcommon.OnResult
import com.revenuecat.purchases.hybridcommon.OnResultAny
import com.revenuecat.purchases.hybridcommon.OnResultList
import com.revenuecat.purchases.hybridcommon.canMakePayments
import com.revenuecat.purchases.hybridcommon.checkTrialOrIntroductoryPriceEligibility
import com.revenuecat.purchases.hybridcommon.configure
import com.revenuecat.purchases.hybridcommon.getAppUserID
import com.revenuecat.purchases.hybridcommon.getCustomerInfo
import com.revenuecat.purchases.hybridcommon.getOfferings
import com.revenuecat.purchases.hybridcommon.getProductInfo
import com.revenuecat.purchases.hybridcommon.getPromotionalOffer
import com.revenuecat.purchases.hybridcommon.getProxyURLString
import com.revenuecat.purchases.hybridcommon.invalidateCustomerInfoCache
import com.revenuecat.purchases.hybridcommon.isAnonymous
import com.revenuecat.purchases.hybridcommon.logIn
import com.revenuecat.purchases.hybridcommon.logOut
import com.revenuecat.purchases.hybridcommon.purchasePackage
import com.revenuecat.purchases.hybridcommon.purchaseProduct
import com.revenuecat.purchases.hybridcommon.purchaseSubscriptionOption
import com.revenuecat.purchases.hybridcommon.restorePurchases
import com.revenuecat.purchases.hybridcommon.setAllowSharingAppStoreAccount
import com.revenuecat.purchases.hybridcommon.setDebugLogsEnabled
import com.revenuecat.purchases.hybridcommon.setLogHandler
import com.revenuecat.purchases.hybridcommon.setLogHandlerWithOnResult
import com.revenuecat.purchases.hybridcommon.setLogLevel
import com.revenuecat.purchases.hybridcommon.setProxyURLString
import com.revenuecat.purchases.hybridcommon.setPurchasesAreCompletedBy
import com.revenuecat.purchases.hybridcommon.showInAppMessagesIfNeeded
import com.revenuecat.purchases.hybridcommon.syncPurchases
import com.revenuecat.purchases.models.InAppMessageType

@Suppress("unused", "DEPRECATION", "LongParameterList", "UNUSED_VARIABLE")
private class CommonApiTests {
    fun checkSetAllowSharingAppStoreAccount(allow: Boolean) {
        setAllowSharingAppStoreAccount(allow)
    }

    fun checkGetOfferings(onResult: OnResult) {
        getOfferings(onResult)
    }

    fun checkGetProductInfo(
        productIDs: List<String>,
        type: String,
        onResult: OnResultList,
    ) {
        getProductInfo(productIDs, type, onResult)
    }

    fun checkPurchaseProduct(
        activity: Activity?,
        productIdentifier: String,
        type: String,
        googleBasePlanId: String?,
        googleOldProductId: String?,
        googleReplacementMode: Int?,
        googleIsPersonalizedPrice: Boolean?,
        presentedOfferingContext: Map<String, Any?>?,
        onResult: OnResult,
    ) {
        purchaseProduct(
            activity,
            productIdentifier,
            type,
            googleBasePlanId,
            googleOldProductId,
            googleReplacementMode,
            googleIsPersonalizedPrice,
            presentedOfferingContext,
            onResult,
        )
    }

    fun checkPurchasePackage(
        activity: Activity?,
        packageIdentifier: String,
        presentedOfferingContext: Map<String, Any?>,
        googleOldProductId: String?,
        googleReplacementMode: Int?,
        googleIsPersonalizedPrice: Boolean?,
        onResult: OnResult,
    ) {
        purchasePackage(
            activity,
            packageIdentifier,
            presentedOfferingContext,
            googleOldProductId,
            googleReplacementMode,
            googleIsPersonalizedPrice,
            onResult,
        )
    }

    fun checkPurchaseSubscriptionOption(
        activity: Activity?,
        productIdentifier: String,
        optionIdentifier: String,
        googleOldProductId: String?,
        googleReplacementMode: Int?,
        googleIsPersonalizedPrice: Boolean?,
        presentedOfferingContext: Map<String, Any?>?,
        onResult: OnResult,
    ) {
        purchaseSubscriptionOption(
            activity,
            productIdentifier,
            optionIdentifier,
            googleOldProductId,
            googleReplacementMode,
            googleIsPersonalizedPrice,
            presentedOfferingContext,
            onResult,
        )
    }

    fun checkGetAppUserId() {
        val appUserId: String = getAppUserID()
    }

    fun checkRestorePurchases(onResult: OnResult) {
        restorePurchases(onResult)
    }

    fun checkLogIn(
        appUserID: String,
        onResult: OnResult,
    ) {
        logIn(appUserID, onResult)
    }

    fun checkLogOut(onResult: OnResult) {
        logOut(onResult)
    }

    fun checkSetDebugLogsEnabled(enabled: Boolean) {
        setDebugLogsEnabled(enabled)
    }

    fun checkSetLogLevel(level: String) {
        setLogLevel(level)
    }

    fun checkSetLogHandler(callback: (logDetails: Map<String, String>) -> Unit) {
        setLogHandler(callback)
    }

    @Suppress("EmptyFunctionBlock")
    fun checkSetLogHandlerWithOnResult() {
        setLogHandlerWithOnResult(object : OnResult {
            override fun onReceived(map: Map<String, *>) {}
            override fun onError(errorContainer: ErrorContainer) {}
        })
    }

    fun checkSetProxyURLString(proxyURLString: String?) {
        setProxyURLString(proxyURLString)
    }

    fun checkGetProxyURLString() {
        val proxyURLString: String? = getProxyURLString()
    }

    fun checkGetCustomerInfo(onResult: OnResult) {
        getCustomerInfo(onResult)
    }

    fun checkSyncPurchases(onResult: OnResult) {
        syncPurchases()
        syncPurchases(onResult)
    }

    fun checkIsAnonymous() {
        val isAnonymous: Boolean = isAnonymous()
    }

    fun checkSetPurchasesAreCompletedBy(purchasesAreCompletedBy: String) {
        setPurchasesAreCompletedBy(purchasesAreCompletedBy)
    }

    fun checkCheckTrialOrIntroductoryPriceEligibility(productIdentifiers: List<String>) {
        val result: Map<String, Map<String, Any>> = checkTrialOrIntroductoryPriceEligibility(
            productIdentifiers,
        )
    }

    fun checkInvalidateCustomerInfoCache() {
        invalidateCustomerInfoCache()
    }

    fun checkCanMakePayments(
        context: Context,
        features: List<Int>,
        onResult: OnResultAny<Boolean>,
    ) {
        canMakePayments(context, features, onResult)
    }

    fun checkShowInAppMessagesIfNeeded(activity: Activity?) {
        showInAppMessagesIfNeeded(activity)
        showInAppMessagesIfNeeded(activity, listOf(InAppMessageType.BILLING_ISSUES))
        showInAppMessagesIfNeeded(activity, null)
    }

    fun checkConfigure(
        context: Context,
        apiKey: String,
        appUserID: String?,
        purchasesAreCompletedBy: String?,
        platformInfo: PlatformInfo,
        store: Store,
        dangerousSettings: DangerousSettings,
        shouldShowInAppMessagesAutomatically: Boolean?,
        verificationMode: String?,
        pendingTransactionsForPrepaidPlansEnabled: Boolean?,
        diagnosticsEnabled: Boolean?,
    ) {
        configure(context, apiKey, appUserID, purchasesAreCompletedBy, platformInfo)
        configure(context, apiKey, appUserID, purchasesAreCompletedBy, platformInfo, store, dangerousSettings)
        configure(
            context,
            apiKey,
            appUserID,
            purchasesAreCompletedBy,
            platformInfo,
            store,
            dangerousSettings,
            shouldShowInAppMessagesAutomatically,
        )
        configure(
            context,
            apiKey,
            appUserID,
            purchasesAreCompletedBy,
            platformInfo,
            store,
            dangerousSettings,
            shouldShowInAppMessagesAutomatically,
            verificationMode,
            pendingTransactionsForPrepaidPlansEnabled = pendingTransactionsForPrepaidPlansEnabled,
            diagnosticsEnabled = diagnosticsEnabled,
        )
    }

    fun checkGetPromotionalOffer() {
        val errorContainer: ErrorContainer = getPromotionalOffer()
    }

    fun checkErrorContainer(code: Int, message: String, info: Map<String, Any?>) {
        val errorContainer = ErrorContainer(code, message, info)
        val storedCode = errorContainer.code
        val storedMessage = errorContainer.message
        val storedInfo = errorContainer.info
    }
}
