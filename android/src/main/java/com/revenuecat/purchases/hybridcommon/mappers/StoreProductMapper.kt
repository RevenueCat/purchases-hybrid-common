package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.models.Period
import com.revenuecat.purchases.models.Price
import com.revenuecat.purchases.models.PricingPhase
import com.revenuecat.purchases.models.RecurrenceMode
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.models.SubscriptionOption

val StoreProduct.priceAmountMicros: Long
    get() = this.price.amountMicros
val StoreProduct.priceString: String
    get() = this.price.formatted
val StoreProduct.priceCurrencyCode: String
    get() = this.price.currencyCode
val StoreProduct.freeTrialPeriod: Period?
    get() = this.subscriptionOptions?.freeTrial?.billingPeriod
val StoreProduct.freeTrialCycles: Int?
    get() = this.subscriptionOptions?.freeTrial?.freePhase?.billingCycleCount

private val StoreProduct.introductoryPhase: PricingPhase?
    get() = this.subscriptionOptions?.introOffer?.introPhase
val StoreProduct.introductoryPrice: String?
    get() = this.introductoryPhase?.price?.formatted
val StoreProduct.introductoryPricePeriodNEW: Period?
    get() = this.introductoryPhase?.billingPeriod
val StoreProduct.introductoryPriceAmountMicros: Long
    get() = this.introductoryPhase?.price?.amountMicros ?: 0
val StoreProduct.introductoryPriceCycles: Int
    get() = this.introductoryPhase?.billingCycleCount ?: 0

fun StoreProduct.map(): Map<String, Any?> =
    mapOf(
        "identifier" to id,
        "description" to description,
        "title" to title,
        "price" to priceAmountMicros / 1_000_000.0,
        "priceString" to priceString,
        "currencyCode" to priceCurrencyCode,
        "introPrice" to mapIntroPrice(),
        "discounts" to null,
        "productCategory" to mapProductCategory(),
        "productType" to mapProductType(),
        "subscriptionPeriod" to period?.iso8601,
        "defaultOption" to defaultOption?.mapSubscriptionOption(this),
        "subscriptionOptions" to subscriptionOptions?.map { it.mapSubscriptionOption(this) },
    )

fun List<StoreProduct>.map(): List<Map<String, Any?>> = this.map { it.map() }

internal fun StoreProduct.mapProductCategory(): String {
    return when (type) {
        ProductType.INAPP -> "NON_SUBSCRIPTION"
        ProductType.SUBS -> "SUBSCRIPTION"
        ProductType.UNKNOWN -> "UNKNOWN"
    }
}

internal fun StoreProduct.mapProductType(): String {
    return when (type) {
        ProductType.INAPP -> "CONSUMABLE"
        ProductType.SUBS -> {
            if (defaultOption?.fullPricePhase?.recurrenceMode == RecurrenceMode.NON_RECURRING) {
                "PREPAID_SUBSCRIPTION"
            } else {
                "AUTO_RENEWABLE_SUBSCRIPTION"
            }
        }
        ProductType.UNKNOWN -> "UNKNOWN"
    }
}

internal fun StoreProduct.mapIntroPrice(): Map<String, Any?>? {
    return when {
        freeTrialPeriod != null -> {
            // Check freeTrialPeriod first to give priority to trials
            // Format using device locale. iOS will format using App Store locale, but there's no way
            // to figure out how the price in the SKUDetails is being formatted.
            freeTrialPeriod?.mapPeriod(false)?.let { periodFields ->
                mapOf(
                    "price" to 0,
                    "priceString" to formatUsingDeviceLocale(priceCurrencyCode, 0),
                    "period" to freeTrialPeriod?.iso8601,
                    "cycles" to (freeTrialCycles ?: 1)
                ) + periodFields
            }
        }
        introductoryPrice != null -> {
            introductoryPricePeriodNEW?.mapPeriod(false)?.let { periodFields ->
                mapOf(
                    "price" to introductoryPriceAmountMicros / 1_000_000.0,
                    "priceString" to introductoryPrice,
                    "period" to introductoryPricePeriodNEW?.iso8601,
                    "cycles" to introductoryPriceCycles
                ) + periodFields
            }
        }
        else -> {
            null
        }
    }
}

private fun Period.mapPeriod(forSubscriptionOption: Boolean): Map<String, Any?>? {
    val unitKey = if (forSubscriptionOption) "unit" else "periodUnit";
    val valueKey = if (forSubscriptionOption) "value" else "periodNumberOfUnits"

    return when(this.unit) {
        Period.Unit.DAY -> mapOf(
            unitKey to "DAY",
            valueKey to this.value
        )
        // WEEK was added in Android V6 but converting to days for backwards compatibility
        Period.Unit.WEEK -> mapOf(
            unitKey to "DAY",
            valueKey to this.value * 7
        )
        Period.Unit.MONTH -> mapOf(
            unitKey to "MONTH",
            valueKey to this.value
        )
        Period.Unit.YEAR -> mapOf(
            unitKey to "YEAR",
            valueKey to this.value
        )
        Period.Unit.UNKNOWN -> mapOf(
            unitKey to "DAY",
            valueKey to 0
        )
    }
}

private fun SubscriptionOption.mapSubscriptionOption(storeProduct: StoreProduct): Map<String, Any?> {
    return mapOf(
        // For Google subscriptions, <basePlanId>:<offerId>
        // For Google and Amazon INAPPs, <productId>
        // For Amazon subscriptions, <termSku>
        "id" to id,

        // For Google subscriptions, <productId>:<basePlanId>
        // For Google and Amazon INAPPs, <productId>
        // For Amazon subscriptions, <termSku>
        "storeProductId" to storeProduct.id,

        // For Google subscriptions, <productId>
        // For Google and Amazon INAPPs, <productId>
        // For Amazon subscriptions, <termSku>
        "productId" to storeProduct.purchasingData.productId,

        "pricingPhases" to pricingPhases.map { it.mapPricingPhase() },
        "tags" to tags,
        "isBasePlan" to isBasePlan,
        "billingPeriod" to billingPeriod?.mapPeriod(true),
        "fullPricePhase" to fullPricePhase?.mapPricingPhase(),
        "freePhase" to freePhase?.mapPricingPhase(),
        "introPhase" to introPhase?.mapPricingPhase()
    )
}

private fun PricingPhase.mapPricingPhase(): Map<String, Any?> {
    return mapOf(
        "billingPeriod" to billingPeriod?.mapPeriod(true),
        "recurrenceMode" to recurrenceMode.identifier,
        "billingCycleCount" to billingCycleCount,
        "price" to price.mapPrice(),
    )
}

private fun Price.mapPrice(): Map<String, Any?> {
    return mapOf(
        "formatted" to formatted,
        "amountMicros" to amountMicros,
        "currencyCode" to currencyCode
    )
}