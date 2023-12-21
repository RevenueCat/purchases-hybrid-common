package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.hybridcommon.mappers.map

@Suppress("unused", "UNUSED_VARIABLE")
private class CustomerInfoMapperApiTests {
    fun checkMap(customerInfo: CustomerInfo) {
        val map: Map<String, Any?> = customerInfo.map()
    }
}
