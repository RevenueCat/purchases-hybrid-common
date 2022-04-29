package com.revenuecat.purchases.hybridcommon

import android.app.Activity
import android.content.Context
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesConfiguration
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.UpgradeInfo
import com.revenuecat.purchases.BillingFeature
import com.revenuecat.purchases.DangerousSettings
import com.revenuecat.purchases.LogHandler
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.getNonSubscriptionSkusWith
import com.revenuecat.purchases.getOfferingsWith
import com.revenuecat.purchases.getCustomerInfoWith
import com.revenuecat.purchases.getSubscriptionSkusWith
import com.revenuecat.purchases.purchasePackageWith
import com.revenuecat.purchases.purchaseProductWith
import com.revenuecat.purchases.logInWith
import com.revenuecat.purchases.logOutWith
import com.revenuecat.purchases.restorePurchasesWith
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.models.StoreTransaction

import java.net.URL

@Deprecated(
    "Replaced with configuration in the RevenueCat dashboard",
    ReplaceWith("configure through the RevenueCat dashboard")
)
fun setAllowSharingAppStoreAccount(
    allowSharingAppStoreAccount: Boolean
) {
    Purchases.sharedInstance.allowSharingPlayStoreAccount = allowSharingAppStoreAccount
}

fun getOfferings(
    onResult: OnResult
) {
    Purchases.sharedInstance.getOfferingsWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun getProductInfo(
    productIDs: List<String>,
    type: String,
    onResult: OnResultList
) {
    val onError: (PurchasesError) -> Unit = { onResult.onError(it.map()) }
    val onReceived: (List<StoreProduct>) -> Unit = { onResult.onReceived(it.map()) }

    if (type.equals("subs", ignoreCase = true)) {
        Purchases.sharedInstance.getSubscriptionSkusWith(productIDs, onError, onReceived)
    } else {
        Purchases.sharedInstance.getNonSubscriptionSkusWith(productIDs, onError, onReceived)
    }
}

fun purchaseProduct(
    activity: Activity?,
    productIdentifier: String,
    oldSku: String?,
    prorationMode: Int?,
    type: String,
    onResult: OnResult
) {
    if (activity != null) {
        val onReceiveSkus: (List<StoreProduct>) -> Unit = { skus ->
            val productToBuy = skus.firstOrNull {
                it.sku == productIdentifier && it.type.name.equals(type, ignoreCase = true)
            }
            if (productToBuy != null) {
                if (oldSku == null || oldSku.isBlank()) {
                    Purchases.sharedInstance.purchaseProductWith(
                        activity,
                        productToBuy,
                        onError = getPurchaseErrorFunction(onResult),
                        onSuccess = getPurchaseCompletedFunction(onResult)
                    )
                } else {
                    Purchases.sharedInstance.purchaseProductWith(
                        activity,
                        productToBuy,
                        UpgradeInfo(oldSku, prorationMode),
                        onError = getPurchaseErrorFunction(onResult),
                        onSuccess = getProductChangeCompletedFunction(onResult)
                    )
                }
            } else {
                onResult.onError(
                    PurchasesError(
                        PurchasesErrorCode.ProductNotAvailableForPurchaseError,
                        "Couldn't find product."
                    ).map()
                )
            }

        }
        if (type.equals("subs", ignoreCase = true)) {
            Purchases.sharedInstance.getSubscriptionSkusWith(
                listOf(productIdentifier),
                { onResult.onError(it.map()) },
                onReceiveSkus
            )
        } else {
            Purchases.sharedInstance.getNonSubscriptionSkusWith(
                listOf(productIdentifier),
                { onResult.onError(it.map()) },
                onReceiveSkus
            )
        }
    } else {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.PurchaseInvalidError,
                "There is no current Activity"
            ).map()
        )
    }
}


fun purchasePackage(
    activity: Activity?,
    packageIdentifier: String,
    offeringIdentifier: String,
    oldSku: String?,
    prorationMode: Int?,
    onResult: OnResult
) {
    if (activity != null) {
        Purchases.sharedInstance.getOfferingsWith(
            { onResult.onError(it.map()) },
            { offerings ->
                val packageToBuy =
                    offerings[offeringIdentifier]?.availablePackages?.firstOrNull {
                        it.identifier.equals(packageIdentifier, ignoreCase = true)
                    }
                if (packageToBuy != null) {
                    if (oldSku == null || oldSku.isBlank()) {
                        Purchases.sharedInstance.purchasePackageWith(
                            activity,
                            packageToBuy,
                            onError = getPurchaseErrorFunction(onResult),
                            onSuccess = getPurchaseCompletedFunction(onResult)
                        )
                    } else {
                        Purchases.sharedInstance.purchasePackageWith(
                            activity,
                            packageToBuy,
                            UpgradeInfo(oldSku, prorationMode),
                            onError = getPurchaseErrorFunction(onResult),
                            onSuccess = getProductChangeCompletedFunction(onResult)
                        )
                    }
                } else {
                    onResult.onError(
                        PurchasesError(
                            PurchasesErrorCode.ProductNotAvailableForPurchaseError,
                            "Couldn't find product."
                        ).map()
                    )
                }
            }
        )
    } else {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.PurchaseInvalidError,
                "There is no current Activity"
            ).map()
        )
    }
}

fun getAppUserID() = Purchases.sharedInstance.appUserID

fun restoreTransactions(
    onResult: OnResult
) {
    Purchases.sharedInstance.restorePurchasesWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun logIn(
    appUserID: String,
    onResult: OnResult
) {
    Purchases.sharedInstance.logInWith(appUserID,
        onError = { onResult.onError(it.map()) },
        onSuccess = { customerInfo, created ->
            val resultMap: Map<String, Any?> = mapOf(
                "customerInfo" to customerInfo.map(),
                "created" to created
            )
            onResult.onReceived(resultMap)
        })
}

fun logOut(onResult: OnResult) {
    Purchases.sharedInstance.logOutWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun setDebugLogsEnabled(
    enabled: Boolean
) {
    Purchases.debugLogsEnabled = enabled
}

fun setLogHandler(
    logHandler: LogHandler
) {
    Purchases.logHandler = logHandler
}

fun setProxyURLString(proxyURLString: String?) {
    Purchases.proxyURL = if (proxyURLString != null) URL(proxyURLString) else null
}

fun getProxyURLString(): String? {
    return Purchases.proxyURL.toString()
}

fun getCustomerInfo(
    onResult: OnResult
) {
    Purchases.sharedInstance.getCustomerInfoWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun syncPurchases() {
    Purchases.sharedInstance.syncPurchases()
}

fun isAnonymous(): Boolean {
    return Purchases.sharedInstance.isAnonymous
}

fun setFinishTransactions(
    enabled: Boolean
) {
    Purchases.sharedInstance.finishTransactions = enabled
}

// Returns Unknown for all since it's not available in Android
fun checkTrialOrIntroductoryPriceEligibility(
    productIdentifiers: List<String>
): Map<String, Map<String, Any>> {
    // INTRO_ELIGIBILITY_STATUS_UNKNOWN = 0
    return productIdentifiers.map {
        it to mapOf("status" to 0, "description" to "Status indeterminate.")
    }.toMap()
}

fun invalidateCustomerInfoCache() {
    Purchases.sharedInstance.invalidateCustomerInfoCache()
}

fun canMakePayments(context: Context,
                    features: List<Int>,
                    onResult: OnResultAny<Boolean>) {
    val billingFeatures = mutableListOf<BillingFeature>()
    try {
        val billingFeatureEnumValues = BillingFeature.values()
        billingFeatures.addAll(features.map { billingFeatureEnumValues[it] })
    } catch (e: IndexOutOfBoundsException) {
        onResult.onError(PurchasesError(PurchasesErrorCode.UnknownError,
                "Invalid feature type passed to canMakePayments.").map())
        return
    }

    Purchases.canMakePayments(context, billingFeatures) {
        onResult.onReceived(it)
    }
}

@JvmOverloads
fun configure(
    context: Context,
    apiKey: String,
    appUserID: String?,
    observerMode: Boolean?,
    platformInfo: PlatformInfo,
    store: Store = Store.PLAY_STORE,
    dangerousSettings: DangerousSettings = DangerousSettings(autoSyncPurchases = true)
) {
    Purchases.platformInfo = platformInfo
    val builder =
        PurchasesConfiguration.Builder(context, apiKey)
            .appUserID(appUserID)
            .store(store)
            .dangerousSettings(dangerousSettings)
    if (observerMode != null) {
        builder.observerMode(observerMode)
    }

    Purchases.configure(builder.build())
}

fun getPaymentDiscount() : ErrorContainer {
    return ErrorContainer(PurchasesErrorCode.UnsupportedError.code,
        "Android platform doesn't support subscription offers", emptyMap())
}

// region private functions

private fun getPurchaseErrorFunction(onResult: OnResult): (PurchasesError, Boolean) -> Unit {
    return { error, userCancelled -> onResult.onError(error.map(mapOf("userCancelled" to userCancelled))) }
}

private fun getPurchaseCompletedFunction(onResult: OnResult): (StoreTransaction, CustomerInfo) -> Unit {
    return { purchase, customerInfo ->
        onResult.onReceived(
            mapOf(
                "productIdentifier" to purchase.skus[0],
                "customerInfo" to customerInfo.map()
            )
        )
    }
}

private fun getProductChangeCompletedFunction(onResult: OnResult): (StoreTransaction?, CustomerInfo) -> Unit {
    return { purchase, customerInfo ->
        onResult.onReceived(
            mapOf(
                // Get first productIdentifier until we have full support of multi-line subscriptions
                "productIdentifier" to purchase?.skus?.get(0),
                "customerInfo" to customerInfo.map()
            )
        )
    }
}

internal fun PurchasesError.map(
    extra: Map<String, Any?> = mapOf()
): ErrorContainer =
    ErrorContainer(
        code.code,
        message,
        mapOf(
            "code" to code.code,
            "message" to message,
            "readableErrorCode" to code.name,
            "readable_error_code" to code.name,
            "underlyingErrorMessage" to (underlyingErrorMessage ?: "")
        ) + extra
    )

data class ErrorContainer(
    val code: Int,
    val message: String,
    val info: Map<String, Any?>
)
