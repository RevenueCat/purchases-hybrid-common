package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.EntitlementInfo
import com.revenuecat.purchases.hybridcommon.mappers.map

@Suppress("unused", "UNUSED_VARIABLE")
private class EntitlementInfoMapperApiTests {
    fun checkMap(entitlementInfo: EntitlementInfo) {
        val map: Map<String, Any?> = entitlementInfo.map()
    }
}
