package apitests.kotlin.com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.hybridcommon.mappers.map

@Suppress("unused", "UNUSED_VARIABLE")
private class OfferingsMapperApiTests {
    fun checkMap(offerings: Offerings) {
        val map: Map<String, Any?> = offerings.map()
    }
}
