package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI
import com.revenuecat.purchases.ads.AdRewardConfiguration
import com.revenuecat.purchases.ads.ConfiguredAdRewards
import kotlin.time.DurationUnit

@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
fun ConfiguredAdRewards.map(): Map<String, Any?> = mapOf(
    "reward" to reward?.map(),
    "moreRewards" to moreRewards.map { it.map() },
)

@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
fun AdRewardConfiguration.map(): Map<String, Any> = when (this) {
    is AdRewardConfiguration.VirtualCurrency -> mapOf(
        "type" to "virtual_currency",
        "code" to code,
        "amount" to amount,
    )
    is AdRewardConfiguration.Entitlement -> mapOf(
        "type" to "entitlement",
        "identifier" to identifier,
        "durationSeconds" to duration.toDouble(DurationUnit.SECONDS),
    )
    else -> mapOf("type" to "unsupported_reward")
}
