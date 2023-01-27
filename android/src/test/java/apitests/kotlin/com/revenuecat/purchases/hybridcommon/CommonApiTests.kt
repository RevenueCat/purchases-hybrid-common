package apitests.kotlin.com.revenuecat.purchases.hybridcommon

import android.app.Activity
import android.content.Context
import com.revenuecat.purchases.DangerousSettings
import com.revenuecat.purchases.LogHandler
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.hybridcommon.*

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
        onResult: OnResultList
    ) {
        getProductInfo(productIDs, type, onResult)
    }

    fun checkPurchaseProduct(
        activity: Activity?,
        productIdentifier: String,
        oldSku: String?,
        prorationMode: Int?,
        type: String,
        onResult: OnResult
    ) {
        purchaseProduct(activity, productIdentifier, oldSku, prorationMode, type, onResult)
    }

    fun checkPurchasePackage(
        activity: Activity?,
        packageIdentifier: String,
        offeringIdentifier: String,
        oldSku: String?,
        prorationMode: Int?,
        onResult: OnResult
    ) {
        purchasePackage(
            activity,
            packageIdentifier,
            offeringIdentifier,
            oldSku,
            prorationMode,
            onResult
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
        onResult: OnResult
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

    fun checkSetProxyURLString(proxyURLString: String?) {
        setProxyURLString(proxyURLString)
    }

    fun checkGetProxyURLString() {
        val proxyURLString: String? = getProxyURLString()
    }

    fun checkGetCustomerInfo(onResult: OnResult) {
        getCustomerInfo(onResult)
    }

    fun checkSyncPurchases() {
        syncPurchases()
    }

    fun checkIsAnonymous() {
        val isAnonymous: Boolean = isAnonymous()
    }

    fun checkSetFinishTransactions(enabled: Boolean) {
        setFinishTransactions(enabled)
    }

    fun checkCheckTrialOrIntroductoryPriceEligibility(productIdentifiers: List<String>) {
        val result: Map<String, Map<String, Any>> = checkTrialOrIntroductoryPriceEligibility(
            productIdentifiers
        )
    }

    fun checkInvalidateCustomerInfoCache() {
        invalidateCustomerInfoCache()
    }

    fun checkCanMakePayments(
        context: Context,
        features: List<Int>,
        onResult: OnResultAny<Boolean>
    ) {
        canMakePayments(context, features, onResult)
    }

    fun checkConfigure(
        context: Context,
        apiKey: String,
        appUserID: String?,
        observerMode: Boolean?,
        platformInfo: PlatformInfo,
        store: Store,
        dangerousSettings: DangerousSettings
    ) {
        configure(context, apiKey, appUserID, observerMode, platformInfo)
        configure(context, apiKey, appUserID, observerMode, platformInfo, store, dangerousSettings)
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
