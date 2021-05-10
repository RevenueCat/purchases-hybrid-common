package com.revenuecat.purchases.hybridcommon

import android.app.Activity
import android.content.Context
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.SkuDetails
import com.revenuecat.purchases.*
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.interfaces.Callback

import java.net.URL

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
    val onReceived: (List<SkuDetails>) -> Unit = { onResult.onReceived(it.map()) }

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
        val onReceiveSkus: (List<SkuDetails>) -> Unit = { skus ->
            val productToBuy = skus.firstOrNull {
                it.sku == productIdentifier && it.type.equals(type, ignoreCase = true)
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
                        onSuccess = getPurchaseCompletedFunction(onResult)
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
                            onSuccess = getPurchaseCompletedFunction(onResult)
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

fun reset(
    onResult: OnResult
) {
    Purchases.sharedInstance.resetWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun identify(
    appUserID: String,
    onResult: OnResult
) {
    Purchases.sharedInstance.identifyWith(appUserID, onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun createAlias(
    newAppUserID: String,
    onResult: OnResult
) {
    Purchases.sharedInstance.createAliasWith(
        newAppUserID,
        onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun setDebugLogsEnabled(
    enabled: Boolean
) {
    Purchases.debugLogsEnabled = enabled
}

fun setProxyURLString(proxyURLString: String?) {
    Purchases.proxyURL = if (proxyURLString != null) URL(proxyURLString) else null
}

fun getProxyURLString(): String? {
    return Purchases.proxyURL.toString()
}

fun getPurchaserInfo(
    onResult: OnResult
) {
    Purchases.sharedInstance.getPurchaserInfoWith(onError = { onResult.onError(it.map()) }) {
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

fun invalidatePurchaserInfoCache() {
    Purchases.sharedInstance.invalidatePurchaserInfoCache()
}

fun canMakePayments(context: Context,
                    features: List<String>,
                    onResult: OnResultAny<Boolean>) {
    var billingFeatures = mutableListOf<BillingFeature>()
    try {
        billingFeatures.addAll(features.map { BillingFeature.valueOf(it) })
    } catch (e: IllegalArgumentException) {
        onResult.onError(PurchasesError(
                PurchasesErrorCode.UnknownError,
                "Invalid feature type passed to canMakePayments."
        ).map())
        return
    }

    Purchases.Companion.canMakePayments(context, billingFeatures, Callback {
        onResult.onReceived(it)
    })
}

// region Subscriber Attributes

fun configure(
    context: Context,
    apiKey: String,
    appUserID: String?,
    observerMode: Boolean?,
    platformInfo: PlatformInfo
) {
    Purchases.platformInfo = platformInfo
    if (observerMode != null) {
        Purchases.configure(context, apiKey, appUserID, observerMode)
    } else {
        Purchases.configure(context, apiKey, appUserID)
    }
}

// region private functions

private fun getPurchaseErrorFunction(onResult: OnResult): (PurchasesError, Boolean) -> Unit {
    return { error, userCancelled -> onResult.onError(error.map(mapOf("userCancelled" to userCancelled))) }
}

private fun getPurchaseCompletedFunction(onResult: OnResult): (Purchase?, PurchaserInfo) -> Unit {
    return { purchase, purchaserInfo ->
        onResult.onReceived(
            mapOf(
                "productIdentifier" to purchase?.sku,
                "purchaserInfo" to purchaserInfo.map()
            )
        )
    }
}

internal fun PurchasesError.map(
    extra: Map<String, Any?> = mapOf()
): ErrorContainer =
    ErrorContainer(
        code.ordinal,
        message,
        mapOf(
            "code" to code.ordinal,
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
