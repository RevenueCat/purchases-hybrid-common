package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.models.Transaction

@Suppress("unused", "UNUSED_VARIABLE")
private class TransactionMapperApiTests {
    fun checkMap(transaction: Transaction) {
        val map: Map<String, Any?> = transaction.map()
    }
}
