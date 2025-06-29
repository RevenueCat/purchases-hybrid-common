package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.hybridcommon.mappers.mapAsync

@Suppress("unused", "UNUSED_VARIABLE")
private class CustomerInfoMapperApiTests {
    fun checkMapAsync(customerInfo: CustomerInfo, callback: (Map<String, Any?>) -> Unit) {
        val unit: Unit = customerInfo.mapAsync(callback)
    }
}
