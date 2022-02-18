package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.models.StoreProduct

fun StoreProduct.map(): Map<String, Any?> =
    mapOf(
        "identifier" to sku,
        "description" to description,
        "title" to title,
        "price" to priceAmountMicros / 1000000.0,
        "price_string" to price,
        "currency_code" to priceCurrencyCode,
        "introPrice" to mapIntroPrice(),
        "discounts" to null
    )

fun List<StoreProduct>.map(): List<Map<String, Any?>> = this.map { it.map() }

internal fun StoreProduct.mapIntroPrice(): Map<String, Any?> {
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
            } ?: mapNullPeriod()
        }
        introductoryPrice != null -> {
            introductoryPricePeriod!!.mapPeriod()?.let { periodFields ->
                mapOf(
                    "price" to introductoryPriceAmountMicros / 1000000.0,
                    "priceString" to introductoryPrice,
                    "period" to introductoryPricePeriod,
                    "cycles" to introductoryPriceCycles
                ) + periodFields
            } ?: mapNullPeriod()
        }
        else -> {
            mapNullPeriod()
        }
    }
}

private fun mapNullPeriod(): Map<String, Nothing?> {
    return mapOf(
        "price" to null,
        "priceString" to null,
        "period" to null,
        "cycles" to null,
        "periodUnit" to null,
        "periodNumberOfUnits" to null
    )
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