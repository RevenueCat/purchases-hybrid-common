package com.revenuecat.purchases.hybridcommon

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.VisibleForTesting
import com.revenuecat.purchases.AmazonLWAConsentStatus
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.DangerousSettings
import com.revenuecat.purchases.EntitlementVerificationMode
import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI
import com.revenuecat.purchases.LogLevel
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.PurchaseParams
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesAreCompletedBy
import com.revenuecat.purchases.PurchasesConfiguration
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.WebPurchaseRedemption
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.getAmazonLWAConsentStatusWith
import com.revenuecat.purchases.getCustomerInfoWith
import com.revenuecat.purchases.getOfferingsWith
import com.revenuecat.purchases.getProductsWith
import com.revenuecat.purchases.getStorefrontCountryCodeWith
import com.revenuecat.purchases.getVirtualCurrenciesWith
import com.revenuecat.purchases.hybridcommon.mappers.LogHandlerWithMapping
import com.revenuecat.purchases.hybridcommon.mappers.MappedProductCategory
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.hybridcommon.mappers.mapAsync
import com.revenuecat.purchases.interfaces.RedeemWebPurchaseListener
import com.revenuecat.purchases.logInWith
import com.revenuecat.purchases.logOutWith
import com.revenuecat.purchases.models.BillingFeature
import com.revenuecat.purchases.models.GoogleReplacementMode
import com.revenuecat.purchases.models.InAppMessageType
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.models.StoreTransaction
import com.revenuecat.purchases.models.googleProduct
import com.revenuecat.purchases.purchaseWith
import com.revenuecat.purchases.restorePurchasesWith
import com.revenuecat.purchases.syncAttributesAndOfferingsIfNeededWith
import com.revenuecat.purchases.syncPurchasesWith
import com.revenuecat.purchases.virtualcurrencies.VirtualCurrencies
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
    Purchases.sharedInstance.getOfferingsWith(onError = { onResult.onError(it.map()) }) { offerings ->
        offerings.mapAsync { map -> onResult.onReceived(map) }
    }
}

fun getCurrentOfferingForPlacement(
    placementIdentifier: String,
    onResult: OnNullableResult,
) {
    Purchases.sharedInstance.getOfferingsWith(onError = { onResult.onError(it.map()) }) {
        val offering = it.getCurrentOfferingForPlacement(placementIdentifier)

        if (offering != null) {
            offering.mapAsync { map -> onResult.onReceived(map) }
        } else {
            onResult.onReceived(null)
        }
    }
}

fun syncAttributesAndOfferingsIfNeeded(
    onResult: OnResult,
) {
    Purchases.sharedInstance.syncAttributesAndOfferingsIfNeededWith(onError = { onResult.onError(it.map()) }) {
        it.mapAsync { map -> onResult.onReceived(map) }
    }
}

fun getProductInfo(
    productIDs: List<String>,
    type: String,
    onResult: OnResultList,
) {
    val onError: (PurchasesError) -> Unit = { onResult.onError(it.map()) }
    val onReceived: (List<StoreProduct>) -> Unit = { it.mapAsync { list -> onResult.onReceived(list) } }

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
    googleReplacementModeInt: Int?,
    googleIsPersonalizedPrice: Boolean?,
    presentedOfferingContext: Map<String, Any?>?,
    onResult: OnResult,
) {
    val googleReplacementMode = try {
        getGoogleReplacementMode(googleReplacementModeInt)
    } catch (e: InvalidReplacementModeException) {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.UnknownError,
                "Invalid google replacement mode passed to purchaseProduct.",
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
            }

            if (productToBuy != null) {
                val purchaseParams = PurchaseParams.Builder(activity, productToBuy)

                presentedOfferingContext?.toPresentedOfferingContext()?.let {
                    purchaseParams.presentedOfferingContext(it)
                }

                // Product upgrade
                if (googleOldProductId != null && googleOldProductId.isNotBlank()) {
                    purchaseParams.oldProductId(googleOldProductId)
                    if (googleReplacementMode != null) {
                        purchaseParams.googleReplacementMode(googleReplacementMode)
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

@Suppress("LongMethod", "LongParameterList")
fun purchasePackage(
    activity: Activity?,
    packageIdentifier: String,
    presentedOfferingContext: Map<String, Any?>,
    googleOldProductId: String?,
    googleReplacementModeInt: Int?,
    googleIsPersonalizedPrice: Boolean?,
    onResult: OnResult,
) {
    val googleReplacementMode = try {
        getGoogleReplacementMode(googleReplacementModeInt)
    } catch (e: InvalidReplacementModeException) {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.UnknownError,
                "Invalid google replacement mode passed to purchasePackage.",
            ).map(),
        )
        return
    }

    if (activity != null) {
        Purchases.sharedInstance.getOfferingsWith(
            { onResult.onError(it.map()) },
            { offerings ->
                val context = presentedOfferingContext.toPresentedOfferingContext()
                if (context == null) {
                    onResult.onError(
                        PurchasesError(
                            PurchasesErrorCode.PurchaseInvalidError,
                            "There is no or invalid presented offering context data provided to make this purchase",
                        ).map(),
                    )
                    return@getOfferingsWith
                }

                val packageToBuy =
                    offerings[context.offeringIdentifier]?.availablePackages?.firstOrNull {
                        it.identifier.equals(packageIdentifier, ignoreCase = true)
                    }
                if (packageToBuy != null) {
                    val purchaseParams = PurchaseParams.Builder(activity, packageToBuy)

                    purchaseParams.presentedOfferingContext(context)

                    // Product upgrade
                    if (googleOldProductId != null && googleOldProductId.isNotBlank()) {
                        purchaseParams.oldProductId(googleOldProductId)
                        if (googleReplacementMode != null) {
                            purchaseParams.googleReplacementMode(googleReplacementMode)
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
    googleReplacementModeInt: Int?,
    googleIsPersonalizedPrice: Boolean?,
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

    val googleReplacementMode = try {
        getGoogleReplacementMode(googleReplacementModeInt)
    } catch (e: InvalidReplacementModeException) {
        onResult.onError(
            PurchasesError(
                PurchasesErrorCode.UnknownError,
                "Invalid google replacement mode passed to purchaseSubscriptionOption.",
            ).map(),
        )
        return
    }

    if (activity != null) {
        val onReceiveStoreProducts: (List<StoreProduct>) -> Unit = { storeProducts ->
            // Iterates over StoreProducts and SubscriptionOptions to find
            // the first matching product id and subscription option id
            val optionToPurchase = storeProducts.firstNotNullOfOrNull { storeProduct ->
                storeProduct.subscriptionOptions?.firstOrNull { subscriptionOption ->
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
                    if (googleReplacementMode != null) {
                        purchaseParams.googleReplacementMode(googleReplacementMode)
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

fun getStorefront(
    callback: (Map<String, Any>?) -> Unit,
) = Purchases.sharedInstance.getStorefrontCountryCodeWith(
    onError = { callback(null) },
    onSuccess = { callback(mapOf("countryCode" to it)) },
)

fun restorePurchases(
    onResult: OnResult,
) {
    Purchases.sharedInstance.restorePurchasesWith(onError = { onResult.onError(it.map()) }) { customerInfo ->
        customerInfo.mapAsync { map -> onResult.onReceived(map) }
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
            customerInfo.mapAsync { map ->
                val resultMap: Map<String, Any?> = mapOf(
                    "customerInfo" to map,
                    "created" to created,
                )

                onResult.onReceived(resultMap)
            }
        },
    )
}

fun logOut(onResult: OnResult) {
    Purchases.sharedInstance.logOutWith(onError = { onResult.onError(it.map()) }) { customerInfo ->
        customerInfo.mapAsync { map -> onResult.onReceived(map) }
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
    Purchases.sharedInstance.getCustomerInfoWith(onError = { onResult.onError(it.map()) }) { customerInfo ->
        customerInfo.mapAsync { map -> onResult.onReceived(map) }
    }
}

fun syncPurchases() {
    Purchases.sharedInstance.syncPurchases()
}

fun syncPurchases(
    onResult: OnResult,
) {
    Purchases.sharedInstance.syncPurchasesWith(onError = { onResult.onError(it.map()) }) { customerInfo ->
        customerInfo.mapAsync { map -> onResult.onReceived(map) }
    }
}

fun isAnonymous(): Boolean {
    return Purchases.sharedInstance.isAnonymous
}

fun setPurchasesAreCompletedBy(
    purchasesAreCompletedBy: String,
) {
    purchasesAreCompletedBy.toPurchasesAreCompletedBy()?.let {
        Purchases.sharedInstance.purchasesAreCompletedBy = it
    }
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

fun overridePreferredLocale(locale: String?) {
    Purchases.sharedInstance.overridePreferredUILocale(locale)
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

fun getAmazonLWAConsentStatus(onResult: OnResultAny<Boolean>) {
    Purchases.sharedInstance.getAmazonLWAConsentStatusWith(onSuccess = {
        onResult.onReceived(
            when (it) {
                AmazonLWAConsentStatus.CONSENTED -> true
                AmazonLWAConsentStatus.UNAVAILABLE -> false
            },
        )
    }, onError = {
        onResult.onError(it.map())
    })
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
    purchasesAreCompletedBy: String? = null,
    platformInfo: PlatformInfo,
    store: Store = Store.PLAY_STORE,
    dangerousSettings: DangerousSettings = DangerousSettings(autoSyncPurchases = true),
    shouldShowInAppMessagesAutomatically: Boolean? = null,
    verificationMode: String? = null,
    pendingTransactionsForPrepaidPlansEnabled: Boolean? = null,
    diagnosticsEnabled: Boolean? = null,
    automaticDeviceIdentifierCollectionEnabled: Boolean? = null,
    preferredLocale: String? = null,
) {
    Purchases.platformInfo = platformInfo

    PurchasesConfiguration.Builder(context, apiKey)
        .appUserID(appUserID)
        .store(store)
        .dangerousSettings(dangerousSettings)
        .apply {
            purchasesAreCompletedBy?.toPurchasesAreCompletedBy()?.let { purchasesAreCompletedBy(it) }
            shouldShowInAppMessagesAutomatically?.let { showInAppMessagesAutomatically(it) }
            verificationMode?.let { verificationMode ->
                try {
                    entitlementVerificationMode(EntitlementVerificationMode.valueOf(verificationMode))
                } catch (e: IllegalArgumentException) {
                    warnLog("Attempted to configure with unknown verification mode: $verificationMode.")
                }
            }
            pendingTransactionsForPrepaidPlansEnabled?.let { pendingTransactionsForPrepaidPlansEnabled(it) }
            diagnosticsEnabled?.let { diagnosticsEnabled(it) }
            automaticDeviceIdentifierCollectionEnabled?.let { automaticDeviceIdentifierCollectionEnabled(it) }
            preferredLocale?.let { preferredUILocaleOverride(it) }
        }.also { Purchases.configure(it.build()) }
}

fun getPromotionalOffer(): ErrorContainer {
    return ErrorContainer(
        PurchasesErrorCode.UnsupportedError.code,
        "Android platform doesn't support promotional offers",
        emptyMap(),
    )
}

@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
fun isWebPurchaseRedemptionURL(urlString: String): Boolean {
    return urlString.toWebPurchaseRedemption() != null
}

@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
fun redeemWebPurchase(
    urlString: String,
    onResult: OnResult,
) {
    val webPurchaseRedemption: WebPurchaseRedemption? = urlString.toWebPurchaseRedemption()
    if (webPurchaseRedemption == null) {
        onResult.onError(
            ErrorContainer(
                PurchasesErrorCode.UnsupportedError.code,
                "Invalid URL for web purchase redemption",
                emptyMap(),
            ),
        )
        return
    }

    Purchases.sharedInstance.redeemWebPurchase(webPurchaseRedemption) { result ->
        when (result) {
            is RedeemWebPurchaseListener.Result.Success -> result.customerInfo.mapAsync { map ->
                onResult.onReceived(
                    mutableMapOf(
                        "result" to result.toResultName(),
                        "customerInfo" to map,
                    ),
                )
            }

            is RedeemWebPurchaseListener.Result.Error -> onResult.onReceived(
                mutableMapOf(
                    "result" to result.toResultName(),
                    "error" to result.error.map(),
                ),
            )

            is RedeemWebPurchaseListener.Result.Expired -> onResult.onReceived(
                mutableMapOf(
                    "result" to result.toResultName(),
                    "obfuscatedEmail" to result.obfuscatedEmail,
                ),
            )

            RedeemWebPurchaseListener.Result.PurchaseBelongsToOtherUser,
            RedeemWebPurchaseListener.Result.InvalidToken,
            -> onResult.onReceived(
                mutableMapOf(
                    "result" to result.toResultName(),
                ),
            )
        }
    }
}

fun getVirtualCurrencies(
    onResult: OnResult,
) {
    Purchases.sharedInstance.getVirtualCurrenciesWith(
        onError = { error: PurchasesError -> onResult.onError(error.map()) },
        onSuccess = { virtualCurrencies: VirtualCurrencies -> onResult.onReceived(virtualCurrencies.map()) },
    )
}

fun invalidateVirtualCurrenciesCache() {
    Purchases.sharedInstance.invalidateVirtualCurrenciesCache()
}

fun getCachedVirtualCurrencies(): Map<String, Any?>? = Purchases.sharedInstance.cachedVirtualCurrencies?.map()

// region private functions

@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
private fun RedeemWebPurchaseListener.Result.toResultName(): String {
    return when (this) {
        is RedeemWebPurchaseListener.Result.Success -> "SUCCESS"
        is RedeemWebPurchaseListener.Result.Error -> "ERROR"
        RedeemWebPurchaseListener.Result.PurchaseBelongsToOtherUser -> "PURCHASE_BELONGS_TO_OTHER_USER"
        RedeemWebPurchaseListener.Result.InvalidToken -> "INVALID_TOKEN"
        is RedeemWebPurchaseListener.Result.Expired -> "EXPIRED"
    }
}

@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
private fun String.toWebPurchaseRedemption(): WebPurchaseRedemption? {
    try {
        // Replace this with parseAsWebPurchaseRedemption overload
        // accepting strings once it's available.
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(this))
        return Purchases.parseAsWebPurchaseRedemption(intent)
    } catch (@Suppress("TooGenericExceptionCaught") e: Throwable) {
        errorLog("Error parsing WebPurchaseRedemption from URL: $this. Error: $e")
        return null
    }
}

private fun String.toPurchasesAreCompletedBy(): PurchasesAreCompletedBy? {
    return try {
        enumValueOf<PurchasesAreCompletedBy>(this)
    } catch (e: IllegalArgumentException) {
        null
    }
}

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
internal class InvalidReplacementModeException : Exception()

@VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
@Throws(InvalidReplacementModeException::class)
internal fun getGoogleReplacementMode(replacementModeInt: Int?): GoogleReplacementMode? {
    return replacementModeInt
        ?.let {
            GoogleReplacementMode.values().find { replacementMode ->
                replacementMode.playBillingClientMode == it
            } ?: run {
                throw InvalidReplacementModeException()
            }
        }
}

private fun getPurchaseErrorFunction(onResult: OnResult): (PurchasesError, Boolean) -> Unit {
    return { error, userCancelled -> onResult.onError(error.map(mapOf("userCancelled" to userCancelled))) }
}

private fun getPurchaseCompletedFunction(onResult: OnResult): (StoreTransaction?, CustomerInfo) -> Unit {
    return { transaction, customerInfo ->
        transaction?.let {
            customerInfo.mapAsync { map ->
                onResult.onReceived(
                    mapOf(
                        "productIdentifier" to transaction.productIds[0],
                        "customerInfo" to map,
                        "transaction" to transaction.map(),
                    ),
                )
            }
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
        val targetingContext = (this["targetingContext"] as? Map<*, *>)?.let { contextMap ->
            val targetingRevision = convertToInt(contextMap["revision"])
            val targetingRuleId = contextMap["ruleId"] as? String

            if (targetingRevision != null && targetingRuleId != null) {
                PresentedOfferingContext.TargetingContext(targetingRevision, targetingRuleId)
            } else {
                null
            }
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

