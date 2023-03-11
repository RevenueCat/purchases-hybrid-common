package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.hybridcommon.stubStoreProduct
import com.revenuecat.purchases.models.StoreProduct
import org.assertj.core.api.Assertions.assertThat
import org.json.JSONObject
import org.junit.jupiter.api.Test

internal class StoreProductMapperTest {

    @Test
    fun `maps product identifier correctly`() {
        val expected = "expected_product_identifier"
        stubStoreProduct(productId = expected).map().let {
            assertThat(it["identifier"]).isEqualTo(expected)
        }
    }

    // TODO: Fix stubs for all of these tests
//    @Test
//    fun `maps product description correctly`() {
//        val expected = "Expected Description"
//        stubStoreProduct(description = expected).map().let {
//            assertThat(it["description"]).isEqualTo(expected)
//        }
//    }
//
//    @Test
//    fun `maps product title correctly`() {
//        val expected = "Expected Title"
//        stubStoreProduct(title = expected).map().let {
//            assertThat(it["title"]).isEqualTo(expected)
//        }
//    }
//
//    @Test
//    fun `maps product price correctly`() {
//        val expected = 2.0
//        stubStoreProduct(priceAmountMicros = (expected * 1_000_000).toLong()).map().let {
//            assertThat(it["price"]).isEqualTo(expected)
//        }
//    }
//
//    @Test
//    fun `maps product price string correctly`() {
//        val expected = "$2.00"
//        stubStoreProduct(price = expected).map().let {
//            assertThat(it["priceString"]).isEqualTo(expected)
//        }
//    }
//
//    @Test
//    fun `maps currency code correctly`() {
//        val expected = "CAD"
//        stubStoreProduct(priceCurrencyCode = expected).map().let {
//            assertThat(it["currencyCode"]).isEqualTo(expected)
//        }
//    }
//
//    @Test
//    fun `maps introPrice correctly`() {
//        stubStoreProduct(freeTrialPeriod = "P7D").map().let {
//            @Suppress("UNCHECKED_CAST")
//            val introPriceMap: Map<String, Any> = it["introPrice"] as Map<String, Any>
//            assertThat(introPriceMap["period"]).isNotNull
//        }
//        // Testing for the intro price mapping is performed in StoreProductIntroPriceMapperTest
//    }
//
//    @Test
//    fun `maps null introPrice correctly`() {
//        stubStoreProduct(freeTrialPeriod = null, introductoryPrice = null).map().let {
//            assertThat(it["introPrice"]).isNull()
//        }
//    }
//
//    @Test
//    fun `maps null discounts correctly`() {
//        stubStoreProduct().map().let {
//            assertThat(it["discounts"]).isNull()
//        }
//    }
//
//    @Test
//    fun `maps product category correctly`() {
//        stubStoreProduct(type = ProductType.SUBS).map().let {
//            assertThat(it["productCategory"]).isEqualTo("SUBSCRIPTION")
//        }
//        stubStoreProduct(type = ProductType.INAPP).map().let {
//            assertThat(it["productCategory"]).isEqualTo("NON_SUBSCRIPTION")
//        }
//        stubStoreProduct(type = ProductType.UNKNOWN).map().let {
//            assertThat(it["productCategory"]).isEqualTo("UNKNOWN")
//        }
//    }
//
//    @Test
//    fun `maps product type correctly`() {
//        stubStoreProduct(type = ProductType.SUBS).map().let {
//            assertThat(it["productType"]).isEqualTo("AUTO_RENEWABLE_SUBSCRIPTION")
//        }
//        stubStoreProduct(type = ProductType.INAPP).map().let {
//            assertThat(it["productType"]).isEqualTo("CONSUMABLE")
//        }
//        stubStoreProduct(type = ProductType.UNKNOWN).map().let {
//            assertThat(it["productType"]).isEqualTo("UNKNOWN")
//        }
//    }
//
//    @Test
//    fun `maps subscription period correctly`() {
//        stubStoreProduct().map().let {
//            assertThat(it["subscriptionPeriod"]).isNull()
//        }
//        stubStoreProduct(subscriptionPeriod = "P1M").map().let {
//            assertThat(it["subscriptionPeriod"]).isEqualTo("P1M")
//        }
//        stubStoreProduct(subscriptionPeriod = "P1Y").map().let {
//            assertThat(it["subscriptionPeriod"]).isEqualTo("P1Y")
//        }
//    }

    @Test
    fun `map has correct size`() {
        stubStoreProduct("monthly_product").map().let {
            assertThat(it.size).isEqualTo(11)
        }
    }
}

//fun stubStoreProduct(
//    sku: String = "monthly_product",
//    type: ProductType = ProductType.SUBS,
//    price: String = "$1.00",
//    priceAmountMicros: Long = 1_000_000,
//    priceCurrencyCode: String = "USD",
//    originalPrice: String? = "$1.00",
//    originalPriceAmountMicros: Long = 0,
//    title: String = "A product title",
//    description: String = "A product description",
//    subscriptionPeriod: String? = null,
//    freeTrialPeriod: String? = "P7D",
//    introductoryPrice: String? = null,
//    introductoryPriceAmountMicros: Long = 0,
//    introductoryPricePeriod: String? = null,
//    introductoryPriceCycles: Int = 0,
//    iconUrl: String = "http://url.com",
//    originalJson: JSONObject = JSONObject("{}")
//) = StoreProduct(
//    sku = sku,
//    type = type,
//    price = price,
//    priceAmountMicros = priceAmountMicros,
//    priceCurrencyCode = priceCurrencyCode,
//    originalPrice = originalPrice,
//    originalPriceAmountMicros = originalPriceAmountMicros,
//    title = title,
//    description = description,
//    subscriptionPeriod = subscriptionPeriod,
//    freeTrialPeriod = freeTrialPeriod,
//    introductoryPrice = introductoryPrice,
//    introductoryPriceAmountMicros = introductoryPriceAmountMicros,
//    introductoryPricePeriod = introductoryPricePeriod,
//    introductoryPriceCycles = introductoryPriceCycles,
//    iconUrl = iconUrl,
//    originalJson = originalJson
//)
