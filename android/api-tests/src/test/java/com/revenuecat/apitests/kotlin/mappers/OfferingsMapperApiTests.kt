package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.hybridcommon.mappers.mapAsync

@Suppress("unused", "UNUSED_VARIABLE")
private class OfferingsMapperApiTests {
    fun checkMap(offerings: Offerings) {
        val map: Map<String, Any?> = offerings.map()
    }

    fun checkMapAsync(offerings: Offerings, callback: (Map<String, Any?>) -> Unit) {
        val unit: Unit = offerings.mapAsync(callback)
    }
}
