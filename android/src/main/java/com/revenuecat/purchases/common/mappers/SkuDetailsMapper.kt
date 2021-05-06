package com.revenuecat.purchases.hybridcommon.mappers

import com.android.billingclient.api.SkuDetails
import java.text.NumberFormat
import java.util.Currency

fun SkuDetails.map(): Map<String, Any?> =
    mapOf(
        "identifier" to sku,
        "description" to description,
        "title" to title,
        "price" to priceAmountMicros / 1000000.0,
        "price_string" to price,
        "currency_code" to priceCurrencyCode,
        "introPrice" to mapIntroPrice(),
        "discounts" to null
    ) + mapIntroPriceDeprecated()

fun List<SkuDetails>.map(): List<Map<String, Any?>> = this.map { it.map() }

internal fun SkuDetails.mapIntroPriceDeprecated(): Map<String, Any?> {
    // isNullOrBlank() gives issues with older Kotlin stdlib versions
    return if (freeTrialPeriod.isNotBlank()) {
        // Check freeTrialPeriod first to give priority to trials
        // Format using device locale. iOS will format using App Store locale, but there's no way
        // to figure out how the price in the SKUDetails is being formatted.
        freeTrialPeriod.mapPeriodDeprecated()?.let { periodFields ->
            mapOf(
                "intro_price" to 0,
                "intro_price_string" to formatUsingDeviceLocale(0),
                "intro_price_period" to freeTrialPeriod,
                "intro_price_cycles" to 1
            ) + periodFields
        } ?: mapNullDeprecatedPeriod()
    } else if (introductoryPrice.isNotBlank()) {
        introductoryPricePeriod.mapPeriodDeprecated()?.let { periodFields ->
            mapOf(
                "intro_price" to introductoryPriceAmountMicros / 1000000.0,
                "intro_price_string" to introductoryPrice,
                "intro_price_period" to introductoryPricePeriod,
                "intro_price_cycles" to introductoryPriceCycles
            ) + periodFields
        } ?: mapNullDeprecatedPeriod()
    } else {
        mapNullDeprecatedPeriod()
    }
}

private fun SkuDetails.formatUsingDeviceLocale(number: Long): String {
    return NumberFormat.getCurrencyInstance().apply {
        currency = Currency.getInstance(priceCurrencyCode)
    }.format(number)
}

internal fun SkuDetails.mapIntroPrice(): Map<String, Any?> {
    // isNullOrBlank() gives issues with older Kotlin stdlib versions
    return if (freeTrialPeriod.isNotBlank()) {
        // Check freeTrialPeriod first to give priority to trials
        // Format using device locale. iOS will format using App Store locale, but there's no way
        // to figure out how the price in the SKUDetails is being formatted.
        freeTrialPeriod.mapPeriod()?.let { periodFields ->
            mapOf(
                "price" to 0,
                "priceString" to formatUsingDeviceLocale(0),
                "period" to freeTrialPeriod,
                "cycles" to 1
            ) + periodFields
        } ?: mapNullPeriod()
    } else if (introductoryPrice.isNotBlank()) {
        introductoryPricePeriod.mapPeriod()?.let { periodFields ->
            mapOf(
                "price" to introductoryPriceAmountMicros / 1000000.0,
                "priceString" to introductoryPrice,
                "period" to introductoryPricePeriod,
                "cycles" to introductoryPriceCycles
            ) + periodFields
        } ?: mapNullPeriod()
    } else {
        mapNullPeriod()
    }
}

private fun mapNullDeprecatedPeriod(): Map<String, Nothing?> {
    return mapOf(
        "intro_price" to null,
        "intro_price_string" to null,
        "intro_price_period" to null,
        "intro_price_cycles" to null,
        "intro_price_period_unit" to null,
        "intro_price_period_number_of_units" to null
    )
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

private fun String?.mapPeriodDeprecated(): Map<String, Any?>? {
    return this.takeUnless { this == null || this.isBlank() }
        ?.let { PurchasesPeriod.parse(it) }
        ?.let { period ->
            when {
                period.years > 0 -> mapOf(
                    "intro_price_period_unit" to "YEAR",
                    "intro_price_period_number_of_units" to period.years
                )
                period.months > 0 -> mapOf(
                    "intro_price_period_unit" to "MONTH",
                    "intro_price_period_number_of_units" to period.months
                )
                period.days > 0 -> mapOf(
                    "intro_price_period_unit" to "DAY",
                    "intro_price_period_number_of_units" to period.days
                )
                else -> mapOf(
                    "intro_price_period_unit" to "DAY",
                    "intro_price_period_number_of_units" to 0
                )
            }
        }
}

private fun String?.mapPeriod(): Map<String, Any?>? {
    return this.takeUnless { this == null || this.isBlank() }
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
