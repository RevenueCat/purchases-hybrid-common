package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.hybridcommon.mappers.mapAsync
import com.revenuecat.purchases.models.StoreProduct

@Suppress("unused", "UNUSED_VARIABLE")
private class StoreProductMapperApiTests {
    fun checkItemMap(product: StoreProduct) {
        val map: Map<String, Any?> = product.map()
    }

    fun checkListMapAsync(products: List<StoreProduct>, callback: (List<Map<String, Any?>>) -> Unit) {
        val unit: Unit = products.mapAsync(callback)
    }
}
