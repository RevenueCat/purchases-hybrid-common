package apitests.kotlin.com.revenuecat.purchases.hybridcommon

import android.app.Activity
import android.content.Context
import com.revenuecat.purchases.DangerousSettings
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.hybridcommon.*
import com.revenuecat.purchases.models.GoogleProrationMode

@Suppress("unused", "DEPRECATION", "LongParameterList", "UNUSED_VARIABLE")
private class CommonApiTests {
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
        type: String,
        googleOldProductId: String?,
        googleProrationMode: GoogleProrationMode?,
        googleIsPersonalizedPrice: Boolean?,
        onResult: OnResult
    ) {
        purchaseProduct(activity, productIdentifier, type, googleOldProductId, googleProrationMode, googleIsPersonalizedPrice, onResult)
    }

    fun checkPurchasePackage(
        activity: Activity?,
        packageIdentifier: String,
        offeringIdentifier: String,
        googleOldProductId: String?,
        googleProrationMode: GoogleProrationMode?,
        googleIsPersonalizedPrice: Boolean?,
        onResult: OnResult
    ) {
        purchasePackage(
            activity,
            packageIdentifier,
            offeringIdentifier,
            googleOldProductId,
            googleProrationMode,
            googleIsPersonalizedPrice,
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

    fun checkSetLogLevel(level: String) {
        setLogLevel(level)
    }

    fun checkSetLogHandler(callback: (logDetails: Map<String, String>) -> Unit) {
        setLogHandler(callback)
    }

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
