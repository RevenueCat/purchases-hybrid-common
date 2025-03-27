package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI
import com.revenuecat.purchases.VirtualCurrencyInfo

@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
fun VirtualCurrencyInfo.map(): Map<String, Any?> =
    mapOf(
        "balance" to balance,
    )
