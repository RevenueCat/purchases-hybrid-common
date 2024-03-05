package com.revenuecat.purchases.hybridcommon

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.VisibleForTesting
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.DangerousSettings
import com.revenuecat.purchases.EntitlementVerificationMode
import com.revenuecat.purchases.LogLevel
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.PurchaseParams
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesConfiguration
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.getCustomerInfoWith
import com.revenuecat.purchases.getOfferingsWith
import com.revenuecat.purchases.getProductsWith
import com.revenuecat.purchases.hybridcommon.mappers.LogHandlerWithMapping
import com.revenuecat.purchases.hybridcommon.mappers.MappedProductCategory
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.logInWith
import com.revenuecat.purchases.logOutWith
import com.revenuecat.purchases.models.BillingFeature
import com.revenuecat.purchases.models.GoogleProrationMode
import com.revenuecat.purchases.models.InAppMessageType
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.models.StoreTransaction
import com.revenuecat.purchases.models.googleProduct
import com.revenuecat.purchases.purchaseWith
import com.revenuecat.purchases.restorePurchasesWith
import com.revenuecat.purchases.syncAttributesAndOfferingsIfNeededWith
import java.net.URL

@Deprecated(
    "Replaced with configuration in the RevenueCat dashboard",
    ReplaceWith("configure through the RevenueCat dashboard"),
)
fun setAllowSharingAppStoreAccount(
    allowSharingAppStoreAccount: Boolean,
) {
    Purchases.sharedInstance.allowSharingPlayStoreAccount = allowSharingAppStoreAccount
}

fun getOfferings(
    onResult: OnResult,
) {
    Purchases.sharedInstance.getOfferingsWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun getCurrentOfferingForPlacement(
    placementIdentifier: String,
    onResult: OnNullableResult,
) {
    Purchases.sharedInstance.getOfferingsWith(onError = { onResult.onError(it.map()) }) {
        val offering = it.getCurrentOfferingForPlacement(placementIdentifier)
        onResult.onReceived(offering?.map())
    }
}

fun syncAttributesAndOfferingsIfNeeded(
    onResult: OnResult,
) {
    Purchases.sharedInstance.syncAttributesAndOfferingsIfNeededWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun getProductInfo(
    productIDs: List<String>,
    type: String,
    onResult: OnResultList,
) {
    val onError: (PurchasesError) -> Unit = { onResult.onError(it.map()) }
    val onReceived: (List<StoreProduct>) -> Unit = { onResult.onReceived(it.map()) }

    if (mapStringToProductType(type) == ProductType.SUBS) {
        Purchases.sharedInstance.getProductsWith(productIDs, ProductType.SUBS, onError, onReceived)
    } else {
        Purchases.sharedInstance.getProductsWith(productIDs, ProductType.INAPP, onError, onReceived)
    }
}

@Suppress("LongParameterList", "LongMethod", "NestedBlockDepth")
fun purchaseProduct(
    activity: Activity?,
    productIdentifier: String,
    type: String,
    googleBasePlanId: String?,
    googleOldProductId: String?,
    googleProrationMode: Int?,
    googleIsPersonalizedPrice: Boolean?,
    presentedOfferingIdentifier: String?,
    presentedOfferingContext: Map<String, Any?>?,
    onResult: OnResult,
) {
    val googleProrationMode = try {
        getGoogleProrationMode(googleProrationMode)
    } catch (e: InvalidProrationModeException) {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.UnknownError,
                "Invalid google proration mode passed to purchaseProduct.",
            ).map(),
        )
        return
    }

    val productType = mapStringToProductType(type)

    if (activity != null) {
        val onReceiveStoreProducts: (List<StoreProduct>) -> Unit = { storeProducts ->
            val productToBuy = storeProducts.firstOrNull {
                // Comparison for when productIdentifier is "subId:basePlanId"
                val foundByProductIdContainingBasePlan =
                    (it.id == productIdentifier && it.type == productType)

                // Comparison for when productIdentifier is "subId" and googleBasePlanId is "basePlanId"
                val foundByProductIdAndGoogleBasePlanId = (
                    it.purchasingData.productId == productIdentifier &&
                        it.googleProduct?.basePlanId == googleBasePlanId &&
                        it.type == productType
                    )

                // Finding the matching StoreProduct two different ways:
                // 1) When productIdentifier is "subId:basePlanId" format (for backwards compatibility with hybrids)
                // 2) When productIdentifier is "subId" and googleBasePlanId is "basePlanId"
                foundByProductIdContainingBasePlan || foundByProductIdAndGoogleBasePlanId
            }?.applyOfferingIdentifier(presentedOfferingIdentifier)

            if (productToBuy != null) {
                val purchaseParams = PurchaseParams.Builder(activity, productToBuy)

                presentedOfferingContext?.toPresentedOfferingContext()?.let {
                    purchaseParams.presentedOfferingContext(it)
                }

                // Product upgrade
                if (googleOldProductId != null && googleOldProductId.isNotBlank()) {
                    purchaseParams.oldProductId(googleOldProductId)
                    if (googleProrationMode != null) {
                        purchaseParams.googleProrationMode(googleProrationMode)
                    }
                }

                // Personalized price
                googleIsPersonalizedPrice?.let {
                    purchaseParams.isPersonalizedPrice(googleIsPersonalizedPrice)
                }

                // Perform purchase
                Purchases.sharedInstance.purchaseWith(
                    purchaseParams.build(),
                    onError = getPurchaseErrorFunction(onResult),
                    onSuccess = getPurchaseCompletedFunction(onResult),
                )
            } else {
                onResult.onError(
                    PurchasesError(
                        PurchasesErrorCode.ProductNotAvailableForPurchaseError,
                        "Couldn't find product $productIdentifier",
                    ).map(),
                )
            }
        }
        if (productType == ProductType.SUBS) {
            // The "productIdentifier"
            val productIdWithoutBasePlanId = productIdentifier.split(":").first()

            Purchases.sharedInstance.getProductsWith(
                listOf(productIdWithoutBasePlanId),
                ProductType.SUBS,
                { onResult.onError(it.map()) },
                onReceiveStoreProducts,
            )
        } else {
            Purchases.sharedInstance.getProductsWith(
                listOf(productIdentifier),
                ProductType.INAPP,
                { onResult.onError(it.map()) },
                onReceiveStoreProducts,
            )
        }
    } else {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.PurchaseInvalidError,
                "There is no current Activity",
            ).map(),
        )
    }
}

@Suppress("LongParameterList")
fun purchasePackage(
    activity: Activity?,
    packageIdentifier: String,
    offeringIdentifier: String,
    presentedOfferingContext: Map<String, Any?>?,
    googleOldProductId: String?,
    googleProrationMode: Int?,
    googleIsPersonalizedPrice: Boolean?,
    onResult: OnResult,
) {
    val googleProrationMode = try {
        getGoogleProrationMode(googleProrationMode)
    } catch (e: InvalidProrationModeException) {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.UnknownError,
                "Invalid google proration mode passed to purchasePackage.",
            ).map(),
        )
        return
    }

    if (activity != null) {
        Purchases.sharedInstance.getOfferingsWith(
            { onResult.onError(it.map()) },
            { offerings ->
                val packageToBuy =
                    offerings[offeringIdentifier]?.availablePackages?.firstOrNull {
                        it.identifier.equals(packageIdentifier, ignoreCase = true)
                    }
                if (packageToBuy != null) {
                    val purchaseParams = PurchaseParams.Builder(activity, packageToBuy)

                    presentedOfferingContext?.toPresentedOfferingContext()?.let {
                        purchaseParams.presentedOfferingContext(it)
                    }

                    // Product upgrade
                    if (googleOldProductId != null && googleOldProductId.isNotBlank()) {
                        purchaseParams.oldProductId(googleOldProductId)
                        if (googleProrationMode != null) {
                            purchaseParams.googleProrationMode(googleProrationMode)
                        }
                    }

                    // Personalized price
                    googleIsPersonalizedPrice?.let {
                        purchaseParams.isPersonalizedPrice(googleIsPersonalizedPrice)
                    }

                    // Perform purchase
                    Purchases.sharedInstance.purchaseWith(
                        purchaseParams.build(),
                        onError = getPurchaseErrorFunction(onResult),
                        onSuccess = getPurchaseCompletedFunction(onResult),
                    )
                } else {
                    onResult.onError(
                        PurchasesError(
                            PurchasesErrorCode.ProductNotAvailableForPurchaseError,
                            "Couldn't find product for package $packageIdentifier",
                        ).map(),
                    )
                }
            },
        )
    } else {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.PurchaseInvalidError,
                "There is no current Activity",
            ).map(),
        )
    }
}

@Suppress("LongParameterList", "LongMethod", "NestedBlockDepth")
fun purchaseSubscriptionOption(
    activity: Activity?,
    productIdentifier: String,
    optionIdentifier: String,
    googleOldProductId: String?,
    googleProrationMode: Int?,
    googleIsPersonalizedPrice: Boolean?,
    presentedOfferingIdentifier: String?,
    presentedOfferingContext: Map<String, Any?>?,
    onResult: OnResult,
) {
    if (Purchases.sharedInstance.store != Store.PLAY_STORE) {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.UnknownError,
                "purchaseSubscriptionOption() is only supported on the Play Store.",
            ).map(),
        )
        return
    }

    val googleProrationMode = try {
        getGoogleProrationMode(googleProrationMode)
    } catch (e: InvalidProrationModeException) {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.UnknownError,
                "Invalid google proration mode passed to purchaseSubscriptionOption.",
            ).map(),
        )
        return
    }

    if (activity != null) {
        val onReceiveStoreProducts: (List<StoreProduct>) -> Unit = { storeProducts ->
            // Iterates over StoreProducts and SubscriptionOptions to find
            // the first matching product id and subscription option id
            val optionToPurchase = storeProducts.firstNotNullOfOrNull { storeProduct ->
                // Create StoreProduct copy with presentedOfferingIdentifier if exists
                // This will give all SubscriptionOption the presentedOfferingIdentifier
                storeProduct.applyOfferingIdentifier(presentedOfferingIdentifier)
                    .subscriptionOptions?.firstOrNull { subscriptionOption ->
                        storeProduct.purchasingData.productId == productIdentifier &&
                            subscriptionOption.id == optionIdentifier
                    }
            }

            if (optionToPurchase != null) {
                val purchaseParams = PurchaseParams.Builder(activity, optionToPurchase)

                presentedOfferingContext?.toPresentedOfferingContext()?.let {
                    purchaseParams.presentedOfferingContext(it)
                }

                // Product upgrade
                googleOldProductId.takeUnless { it.isNullOrBlank() }?.let {
                    purchaseParams.oldProductId(it)
                    if (googleProrationMode != null) {
                        purchaseParams.googleProrationMode(googleProrationMode)
                    }
                }

                // Personalized price
                googleIsPersonalizedPrice?.let {
                    purchaseParams.isPersonalizedPrice(googleIsPersonalizedPrice)
                }

                // Perform purchase
                Purchases.sharedInstance.purchaseWith(
                    purchaseParams.build(),
                    onError = getPurchaseErrorFunction(onResult),
                    onSuccess = getPurchaseCompletedFunction(onResult),
                )
            } else {
                onResult.onError(
                    PurchasesError(
                        PurchasesErrorCode.ProductNotAvailableForPurchaseError,
                        "Couldn't find product $productIdentifier:$optionIdentifier",
                    ).map(),
                )
            }
        }

        Purchases.sharedInstance.getProductsWith(
            listOf(productIdentifier),
            ProductType.SUBS,
            { onResult.onError(it.map()) },
            onReceiveStoreProducts,
        )
    } else {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.PurchaseInvalidError,
                "There is no current Activity",
            ).map(),
        )
    }
}

fun getAppUserID() = Purchases.sharedInstance.appUserID

fun restorePurchases(
    onResult: OnResult,
) {
    Purchases.sharedInstance.restorePurchasesWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

fun logIn(
    appUserID: String,
    onResult: OnResult,
) {
    Purchases.sharedInstance.logInWith(
        appUserID,
        onError = { onResult.onError(it.map()) },
        onSuccess = { customerInfo, created ->
            val resultMap: Map<String, Any?> = mapOf(
                "customerInfo" to customerInfo.map(),
                "created" to created,
            )
            onResult.onReceived(resultMap)
        },
    )
}

fun logOut(onResult: OnResult) {
    Purchases.sharedInstance.logOutWith(onError = { onResult.onError(it.map()) }) {
        onResult.onReceived(it.map())
    }
}

@Deprecated(message = "Use setLogLevel instead")
fun setDebugLogsEnabled(
    enabled: Boolean,
) {
    Purchases.debugLogsEnabled = enabled
}

fun setLogLevel(level: String) {
    try {
        Purchases.logLevel = LogLevel.valueOf(level)
    } catch (e: IllegalArgumentException) {
        warnLog("Unrecognized log level: $level")
    }
}

/**
 * Sets a log handler and forwards all logs to completion function.
 *
 * @param callback Gets a map with two keys, a `logLevel` which  is one of the ``LogLevel`` name uppercased,
 * and a `message`, with the log message.
 */
fun setLogHandler(callback: (logDetails: Map<String, String>) -> Unit) {
    Purchases.logHandler = LogHandlerWithMapping(callback)
}

/**
 * Sets a log handler and forwards all logs to completion function. Accepts an OnResult so it can be used from
 * SDKs that don't have Kotlin configured, since they would error because Kotlin's Function1 would not be found.
 * Function1 is what Kotlin lambdas are converted to. It has a different name than setLogHandler because naming it
 * the same also gives errors due of missing Function1.
 *
 * @param onResult Gets a map with two keys, a `logLevel` which  is one of the ``LogLevel`` name uppercased,
 * and a `message`, with the log message. The onError of OnResult will never be called.
 */
fun setLogHandlerWithOnResult(onResult: OnResult) {
    setLogHandler { logDetails ->
        onResult.onReceived(logDetails)
    }
}

fun setProxyURLString(proxyURLString: String?) {
    Purchases.proxyURL = if (proxyURLString != null) URL(proxyURLString) else null
}

fun getProxyURLString(): String? {
    return Purchases.proxyURL.toString()
}

fun getCustomerInfo(
    onResult: OnResult,
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
    enabled: Boolean,
) {
    Purchases.sharedInstance.finishTransactions = enabled
}

// Returns Unknown for all since it's not available in Android
fun checkTrialOrIntroductoryPriceEligibility(
    productIdentifiers: List<String>,
): Map<String, Map<String, Any>> {
    // INTRO_ELIGIBILITY_STATUS_UNKNOWN = 0
    return productIdentifiers.map {
        it to mapOf("status" to 0, "description" to "Status indeterminate.")
    }.toMap()
}

fun invalidateCustomerInfoCache() {
    Purchases.sharedInstance.invalidateCustomerInfoCache()
}

fun canMakePayments(
    context: Context,
    features: List<Int>,
    onResult: OnResultAny<Boolean>,
) {
    val billingFeatures = mutableListOf<BillingFeature>()
    try {
        val billingFeatureEnumValues = BillingFeature.values()
        billingFeatures.addAll(features.map { billingFeatureEnumValues[it] })
    } catch (e: IndexOutOfBoundsException) {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.UnknownError,
                "Invalid feature type passed to canMakePayments.",
            ).map(),
        )
        return
    }

    Purchases.canMakePayments(context, billingFeatures) {
        onResult.onReceived(it)
    }
}

@JvmOverloads
fun showInAppMessagesIfNeeded(activity: Activity?, inAppMessageTypes: List<InAppMessageType>? = null) {
    if (activity == null) {
        errorLog("showInAppMessages called with null activity")
        return
    }
    if (inAppMessageTypes == null) {
        Purchases.sharedInstance.showInAppMessagesIfNeeded(activity)
    } else {
        Purchases.sharedInstance.showInAppMessagesIfNeeded(activity, inAppMessageTypes)
    }
}

@Suppress("LongParameterList")
@JvmOverloads
fun configure(
    context: Context,
    apiKey: String,
    appUserID: String?,
    observerMode: Boolean?,
    platformInfo: PlatformInfo,
    store: Store = Store.PLAY_STORE,
    dangerousSettings: DangerousSettings = DangerousSettings(autoSyncPurchases = true),
    shouldShowInAppMessagesAutomatically: Boolean? = null,
    verificationMode: String? = null,
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
    if (shouldShowInAppMessagesAutomatically != null) {
        builder.showInAppMessagesAutomatically(shouldShowInAppMessagesAutomatically)
    }
    if (verificationMode != null) {
        try {
            builder.entitlementVerificationMode(EntitlementVerificationMode.valueOf(verificationMode))
        } catch (e: IllegalArgumentException) {
            warnLog("Attempted to configure with unknown verification mode: $verificationMode.")
        }
    }

    Purchases.configure(builder.build())
}

fun getPromotionalOffer(): ErrorContainer {
    return ErrorContainer(
        PurchasesErrorCode.UnsupportedError.code,
        "Android platform doesn't support promotional offers",
        emptyMap(),
    )
}

// region private functions

@VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
internal fun mapStringToProductType(type: String): ProductType {
    MappedProductCategory.values()
        .firstOrNull { it.value.equals(type, ignoreCase = true) }
        ?.let {
            return it.toProductType
        }

    // Maps strings used in deprecated hybrid methods to native ProductType enum
    // "subs" and "inapp" are legacy purchase types used in v4 and below
    return when (type.lowercase()) {
        "subs" -> ProductType.SUBS
        "inapp" -> ProductType.INAPP
        else -> {
            warnLog("Unrecognized product type: $type... Defaulting to INAPP")
            ProductType.INAPP
        }
    }
}

@VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
internal class InvalidProrationModeException : Exception()

@VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
@Throws(InvalidProrationModeException::class)
internal fun getGoogleProrationMode(prorationModeInt: Int?): GoogleProrationMode? {
    return prorationModeInt
        ?.let {
            GoogleProrationMode.values().find { prorationMode ->
                prorationMode.playBillingClientMode == it
            } ?: run {
                throw InvalidProrationModeException()
            }
        }
}

private fun StoreProduct.applyOfferingIdentifier(presentedOfferingIdentifier: String?): StoreProduct {
    return presentedOfferingIdentifier?.let {
        this.copyWithOfferingId(it)
    } ?: this
}

private fun getPurchaseErrorFunction(onResult: OnResult): (PurchasesError, Boolean) -> Unit {
    return { error, userCancelled -> onResult.onError(error.map(mapOf("userCancelled" to userCancelled))) }
}

private fun getPurchaseCompletedFunction(onResult: OnResult): (StoreTransaction?, CustomerInfo) -> Unit {
    return { transaction, customerInfo ->
        transaction?.let {
            onResult.onReceived(
                mapOf(
                    "productIdentifier" to transaction.productIds[0],
                    "customerInfo" to customerInfo.map(),
                    "transaction" to transaction.map(),
                ),
            )
        } ?: run {
            // TODO Figure out how to properly handle a null StoreTransaction (doing this for now
            onResult.onError(
                ErrorContainer(
                    PurchasesErrorCode.UnsupportedError.code,
                    "Error purchasing. Null transaction returned from a successful non-upgrade purchase.",
                    emptyMap(),
                ),
            )
        }
    }
}

data class ErrorContainer(
    val code: Int,
    val message: String,
    val info: Map<String, Any?>,
)

internal fun warnLog(message: String) {
    if (Purchases.logLevel <= LogLevel.WARN) {
        Log.w("PurchasesHybridCommon", message)
    }
}

internal fun errorLog(message: String) {
    if (Purchases.logLevel <= LogLevel.ERROR) {
        Log.e("PurchasesHybridCommon", message)
    }
}

internal fun Map<String, Any?>.toPresentedOfferingContext(): PresentedOfferingContext? {
    val offeringIdentifier = this["offeringIdentifier"] as? String

    return offeringIdentifier?.let {
        val placementIdentifier = this["placementIdentifier"] as? String
        val targetingRevision = convertToInt(this["targetingRevision"])
        val targetingRuleId = this["targetingRuleId"] as? String

        val targetingContext = if (targetingRevision != null && targetingRuleId != null) {
            PresentedOfferingContext.TargetingContext(targetingRevision, targetingRuleId)
        } else {
            null
        }

        PresentedOfferingContext(it, placementIdentifier, targetingContext)
    } ?: run {
        null
    }
}

internal fun convertToInt(value: Any?): Int? {
    return when (value) {
        is Int -> value
        is Double -> value.toInt()
        else -> null
    }
}
