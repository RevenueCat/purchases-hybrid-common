package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI
import com.revenuecat.purchases.VirtualCurrencyInfo
import com.revenuecat.purchases.hybridcommon.mappers.map

@Suppress("unused", "UNUSED_VARIABLE")
private class VirtualCurrencyInfoMapperApiTests {

    @OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
    fun checkMap(virtualCurrencyInfo: VirtualCurrencyInfo) {
        val map: Map<String, Any?> = virtualCurrencyInfo.map()
    }
}
