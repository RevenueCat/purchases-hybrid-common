package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.models.Period
import com.revenuecat.purchases.models.PricingPhase
import com.revenuecat.purchases.models.StoreProduct

val StoreProduct.priceAmountMicros: Long
    get() = this.price.amountMicros
val StoreProduct.priceString: String
    get() = this.price.formatted
val StoreProduct.priceCurrencyCode: String
    get() = this.price.currencyCode
val StoreProduct.freeTrialPeriodNEW: Period?
    get() = this.subscriptionOptions?.freeTrial?.billingPeriod

private val StoreProduct.introductoryPhase: PricingPhase?
    get() = this.subscriptionOptions?.introTrial?.introPhase
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
        "subscriptionPeriod" to period?.iso8601
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
        ProductType.SUBS -> "AUTO_RENEWABLE_SUBSCRIPTION" // TODO: Add a new string here prepaid (check recurrence mode)
        ProductType.UNKNOWN -> "UNKNOWN"
    }
}

// TODO: This can actually cause issues now with BC5 because there could be an free price and an intro price
internal fun StoreProduct.mapIntroPrice(): Map<String, Any?>? {
    return when {
        freeTrialPeriodNEW != null -> {
            // Check freeTrialPeriod first to give priority to trials
            // Format using device locale. iOS will format using App Store locale, but there's no way
            // to figure out how the price in the SKUDetails is being formatted.
            freeTrialPeriodNEW?.mapPeriod()?.let { periodFields ->
                mapOf(
                    "price" to 0,
                    "priceString" to formatUsingDeviceLocale(priceCurrencyCode, 0),
                    "period" to freeTrialPeriodNEW?.iso8601,
                    "cycles" to 1 // TODO: I don't think this should be hardcoded to 1
                ) + periodFields
            }
        }
        introductoryPrice != null -> {
            introductoryPricePeriodNEW?.mapPeriod()?.let { periodFields ->
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

private fun Period.mapPeriod(): Map<String, Any?>? {
    return when(this.unit) {
        Period.Unit.DAY -> mapOf(
            "periodUnit" to "DAY",
            "periodNumberOfUnits" to this.value
        )
        // TODO: Is week not a thing that we can use? Does this ened to be days (old method didn't have week)
        Period.Unit.WEEK -> mapOf(
            "periodUnit" to "WEEK",
            "periodNumberOfUnits" to this.value
        )
        Period.Unit.MONTH -> mapOf(
            "periodUnit" to "MONTH",
            "periodNumberOfUnits" to this.value
        )
        Period.Unit.YEAR -> mapOf(
            "periodUnit" to "YEAR",
            "periodNumberOfUnits" to this.value
        )
        Period.Unit.UNKNOWN -> mapOf(
            "periodUnit" to "DAY",
            "periodNumberOfUnits" to 0
        )
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