package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.models.PricingPhase
import com.revenuecat.purchases.models.StoreProduct

// TODOBC5: JOSH's temporary (???) extensions to support what was already there
val StoreProduct.priceAmountMicros: Long
    get() = this.oneTimeProductPrice?.priceAmountMicros ?: this.defaultOption?.pricingPhases?.lastOrNull()?.priceAmountMicros ?: 0
val StoreProduct.price: String
    get() = this.oneTimeProductPrice?.formattedPrice ?: this.defaultOption?.pricingPhases?.lastOrNull()?.formattedPrice ?: ""
val StoreProduct.priceCurrencyCode: String
    get() = this.oneTimeProductPrice?.currencyCode ?: this.defaultOption?.pricingPhases?.lastOrNull()?.priceCurrencyCode ?: ""
val StoreProduct.freeTrialPeriod: String?
    get() = this.defaultOption?.pricingPhases?.lastOrNull()?.billingPeriod

private val StoreProduct.introductoryPhase: PricingPhase?
    get() = this.defaultOption?.pricingPhases
        ?.takeIf { it.size > 1 }
        ?.firstOrNull()
        ?.takeIf { it.priceAmountMicros > 0 }
val StoreProduct.introductoryPrice: String?
    get() = this.introductoryPhase?.formattedPrice
val StoreProduct.introductoryPricePeriod: String?
    get() = this.introductoryPhase?.billingPeriod
val StoreProduct.introductoryPriceAmountMicros: Long
    get() = this.introductoryPhase?.priceAmountMicros ?: 0
val StoreProduct.introductoryPriceCycles: Int
    get() = this.introductoryPhase?.billingCycleCount ?: 0

fun StoreProduct.map(): Map<String, Any?> =
    mapOf(
        "identifier" to productId,
        "description" to description,
        "title" to title,
        "price" to priceAmountMicros / 1_000_000.0,
        "priceString" to price,
        "currencyCode" to priceCurrencyCode,
        "introPrice" to mapIntroPrice(),
        "discounts" to null,
        "productCategory" to mapProductCategory(),
        "productType" to mapProductType(),
        "subscriptionPeriod" to subscriptionPeriod
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
        ProductType.SUBS -> "AUTO_RENEWABLE_SUBSCRIPTION"
        ProductType.UNKNOWN -> "UNKNOWN"
    }
}

internal fun StoreProduct.mapIntroPrice(): Map<String, Any?>? {
    return when {
        freeTrialPeriod != null -> {
            // Check freeTrialPeriod first to give priority to trials
            // Format using device locale. iOS will format using App Store locale, but there's no way
            // to figure out how the price in the SKUDetails is being formatted.
            freeTrialPeriod!!.mapPeriod()?.let { periodFields ->
                mapOf(
                    "price" to 0,
                    "priceString" to formatUsingDeviceLocale(priceCurrencyCode, 0),
                    "period" to freeTrialPeriod,
                    "cycles" to 1
                ) + periodFields
            } ?: null
        }
        introductoryPrice != null -> {
            introductoryPricePeriod!!.mapPeriod()?.let { periodFields ->
                mapOf(
                    "price" to introductoryPriceAmountMicros / 1_000_000.0,
                    "priceString" to introductoryPrice,
                    "period" to introductoryPricePeriod,
                    "cycles" to introductoryPriceCycles
                ) + periodFields
            } ?: null
        }
        else -> {
            null
        }
    }
}

private fun String.mapPeriod(): Map<String, Any?>? {
    return this.takeUnless { this.isBlank() }
        ?.let { PurchasesPeriod.parse(it) }
        ?.let { period ->
            when {
                period.years > 0 -> mapOf(
                    "periodUnit" to "YEAR",
                    "periodNumberOfUnits" to period.years
                )
                period.months > 0 -> mapOf(
                    "periodUnit" to "MONTH",
                    "periodNumberOfUnits" to period.months
                )
                period.days > 0 -> mapOf(
                    "periodUnit" to "DAY",
                    "periodNumberOfUnits" to period.days
                )
                else -> mapOf(
                    "periodUnit" to "DAY",
                    "periodNumberOfUnits" to 0
                )
            }
        }
}