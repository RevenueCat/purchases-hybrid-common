package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.EntitlementInfos
import com.revenuecat.purchases.hybridcommon.mappers.map

@Suppress("unused", "UNUSED_VARIABLE")
private class EntitlementInfosMapperApiTests {
    fun checkMap(entitlementInfos: EntitlementInfos) {
        val map: Map<String, Any?> = entitlementInfos.map()
    }
}
