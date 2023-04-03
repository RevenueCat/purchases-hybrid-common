package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.hybridcommon.MICROS_MULTIPLIER
import com.revenuecat.purchases.hybridcommon.stubPricingPhase
import com.revenuecat.purchases.hybridcommon.stubStoreProduct
import com.revenuecat.purchases.hybridcommon.stubSubscriptionOption
import com.revenuecat.purchases.models.Period
import com.revenuecat.purchases.models.Price
import com.revenuecat.purchases.models.StoreProduct
import org.assertj.core.api.Assertions.assertThat
import org.json.JSONObject
import org.junit.jupiter.api.Test

internal class StoreProductMapperTest {

    val exptectedProductId = "expected_product_identifier"

    @Test
    fun `maps product identifier correctly`() {
        stubStoreProduct(productId = exptectedProductId).map().let {
            assertThat(it["identifier"]).isEqualTo(exptectedProductId)
        }
    }

    // TODO: Fix stubs for all of these tests
    @Test
    fun `maps product description correctly`() {
        val expected = "Expected Description"
        stubStoreProduct(
            productId = exptectedProductId,
            description = expected
        ).map().let {
            assertThat(it["description"]).isEqualTo(expected)
        }
    }

    @Test
    fun `maps product title correctly`() {
        val expected = "Expected Title"
        stubStoreProduct(
            productId = exptectedProductId,
            title = expected
        ).map().let {
            assertThat(it["title"]).isEqualTo(expected)
        }
    }

    @Test
    fun `maps product price correctly`() {
        val duration = Period(1, Period.Unit.MONTH, "P1M")

        val expected = 2.0
        val expectedFormatted = "$2.00"
        val expectedCurrencyCode = "USD"
        stubStoreProduct(
            productId = exptectedProductId,
            defaultOption = stubSubscriptionOption(
                "monthly_base_plan", exptectedProductId,
                duration,
                pricingPhases = listOf(
                    stubPricingPhase(
                        billingPeriod = duration,
                        priceCurrencyCodeValue = expectedCurrencyCode,
                        priceFormatted = expectedFormatted,
                        price = expected
                    )
                )
            )
        ).map().let {
            assertThat(it["price"]).isEqualTo(expected)
            assertThat(it["priceString"]).isEqualTo(expectedFormatted)
            assertThat(it["currencyCode"]).isEqualTo(expectedCurrencyCode)
        }
    }

    @Test
    fun `maps free introPrice correctly`() {
        val freeTrialDuration = Period(1, Period.Unit.MONTH, "P7D")
        val duration = Period(1, Period.Unit.MONTH, "P1M")

        stubStoreProduct(
            productId = exptectedProductId,
            defaultOption = stubSubscriptionOption(
                "monthly_base_plan", exptectedProductId,
                duration,
                pricingPhases = listOf(
                    stubPricingPhase(
                        billingPeriod = freeTrialDuration,
                        priceFormatted = "$0.00",
                        price = 0.0
                    ),
                    stubPricingPhase(
                        billingPeriod = duration,
                    )
                )
            )
        ).map().let {
            @Suppress("UNCHECKED_CAST")
            val introPriceMap: Map<String, Any> = it["introPrice"] as Map<String, Any>
            assertThat(introPriceMap["period"]).isNotNull
        }
        // Testing for the intro price mapping is performed in StoreProductIntroPriceMapperTest
    }

    @Test
    fun `maps null introPrice correctly`() {
        stubStoreProduct(
            productId = exptectedProductId,
            defaultOption = stubSubscriptionOption(
                "monthly_base_plan", exptectedProductId,
            )
        ).map().let {
            assertThat(it["introPrice"]).isNull()
        }
    }

    @Test
    fun `maps null discounts correctly`() {
        stubStoreProduct(
            productId = exptectedProductId,
            defaultOption = stubSubscriptionOption(
                "monthly_base_plan", exptectedProductId,
            )
        ).map().let {
            assertThat(it["discounts"]).isNull()
        }
    }

    @Test
    fun `maps product category correctly`() {
        stubStoreProduct(
            productId = exptectedProductId,
            type = ProductType.SUBS
        ).map().let {
            assertThat(it["productCategory"]).isEqualTo("SUBSCRIPTION")
        }
        stubStoreProduct(
            productId = exptectedProductId,
            type = ProductType.INAPP
        ).map().let {
            assertThat(it["productCategory"]).isEqualTo("NON_SUBSCRIPTION")
        }
        stubStoreProduct(
            productId = exptectedProductId,
            type = ProductType.UNKNOWN
        ).map().let {
            assertThat(it["productCategory"]).isEqualTo("UNKNOWN")
        }
    }

    @Test
    fun `maps product type correctly`() {
        val duration = Period(1, Period.Unit.MONTH, "P1M")

        stubStoreProduct(
            productId = exptectedProductId,
            type = ProductType.SUBS
        ).map().let {
            assertThat(it["productType"]).isEqualTo("AUTO_RENEWABLE_SUBSCRIPTION")
        }
        stubStoreProduct(
            productId = exptectedProductId,
            type = ProductType.SUBS,
            defaultOption = stubSubscriptionOption(
                "monthly_base_plan", exptectedProductId,
                duration,
                pricingPhases = listOf(
                    stubPricingPhase(
                        billingPeriod = duration,
                        recurrenceMode = 3
                    )
                )
            )
        ).map().let {
            assertThat(it["productType"]).isEqualTo("PREPAID_SUBSCRIPTION")
        }
        stubStoreProduct(
            productId = exptectedProductId,
            type = ProductType.INAPP
        ).map().let {
            assertThat(it["productType"]).isEqualTo("CONSUMABLE")
        }
        stubStoreProduct(
            productId = exptectedProductId,
            type = ProductType.UNKNOWN
        ).map().let {
            assertThat(it["productType"]).isEqualTo("UNKNOWN")
        }
    }

    @Test
    fun `maps subscription period correctly`() {
        stubStoreProduct(
            productId = exptectedProductId,
            type = ProductType.INAPP,
            defaultOption = null,
            subscriptionOptions = emptyList(),
            price = Price("$1.99", 19900000, "USD")
        ).map().let {
            assertThat(it["subscriptionPeriod"]).isNull()
        }
        stubStoreProduct(
            productId = exptectedProductId,
            defaultOption = stubSubscriptionOption(
                "monthly_base_plan", exptectedProductId,
                Period(1, Period.Unit.MONTH, "P1M")
            )
        ).map().let {
            assertThat(it["subscriptionPeriod"]).isEqualTo("P1M")
        }
        stubStoreProduct(
            productId = exptectedProductId,
            defaultOption = stubSubscriptionOption(
                "monthly_base_plan", exptectedProductId,
                Period(1, Period.Unit.MONTH, "P1Y")
            )
        ).map().let {
            assertThat(it["subscriptionPeriod"]).isEqualTo("P1Y")
        }
    }

    @Test
    fun `map has correct size`() {
        stubStoreProduct("monthly_product").map().let {
            assertThat(it.size).isEqualTo(13)
        }
    }

    @Test
    fun `map has default option as base plan`() {
        stubStoreProduct(
            productId = exptectedProductId,
            defaultOption = stubSubscriptionOption(
                "monthly_base_plan", exptectedProductId,
            )
        ).map().let {
            val defaultOption = it["defaultOption"] as Map<String, Any?>
            testBasePlanOption(defaultOption)
        }
    }

    @Test
    fun `map has default option with free trial and intro trial`() {
        val freeTrialDuration = Period(7, Period.Unit.DAY, "P7D")
        val introTrialDuration = Period(1, Period.Unit.MONTH, "P1M")
        val duration = Period(1, Period.Unit.MONTH, "P1M")

        val basePlan = stubSubscriptionOption(
            "monthly_base_plan", exptectedProductId,
            duration,
            pricingPhases = listOf(
                stubPricingPhase(
                    billingPeriod = duration,
                )
            )
        )
        val multiPricingPhaseOption = stubSubscriptionOption(
            "monthly_base_plan", exptectedProductId,
            duration,
            pricingPhases = listOf(
                stubPricingPhase(
                    billingPeriod = freeTrialDuration,
                    priceFormatted = "$0.00",
                    price = 0.0
                ),
                stubPricingPhase(
                    billingPeriod = introTrialDuration,
                    priceFormatted = "$2.99",
                    price = 2.99
                ),
                stubPricingPhase(
                    billingPeriod = duration,
                )
            )
        )

        stubStoreProduct(
            productId = exptectedProductId,
            defaultOption = multiPricingPhaseOption,
            subscriptionOptions = listOf(basePlan, multiPricingPhaseOption)
        ).map().let {
            val defaultOption = it["defaultOption"] as Map<String, Any?>
            testMultiPhaseOption(defaultOption)

            val subscriptionOptions = it["subscriptionOptions"] as List<Map<String, Any?>>
            testBasePlanOption(subscriptionOptions[0])
            testMultiPhaseOption(subscriptionOptions[1])
        }
    }

    private fun testBasePlanOption(option: Map<String, Any?>) {
        val billingPeriod = mapOf(
            "unit" to "MONTH",
            "value" to 1
        )

        assertThat(option).isNotNull
        assertThat(option["tags"]).isEqualTo(listOf("tag"))
        assertThat(option["isBasePlan"]).isEqualTo(true)

        assertThat(option["billingPeriod"]).isEqualTo(billingPeriod)
        assertThat(option["fullPricePhase"]).isEqualTo(
            mapOf(
                "billingPeriod" to billingPeriod,
                "recurrenceMode" to 1,
                "billingCycleCount" to 0,
                "price" to mapOf(
                    "formatted" to "$4.99",
                    "amountMicros" to (4.99 * MICROS_MULTIPLIER).toLong(),
                    "currencyCode" to "USD"
                ),
            )
        )
        assertThat(option["freePhase"]).isNull()
        assertThat(option["introPhase"]).isNull()
    }

    private fun testMultiPhaseOption(option: Map<String, Any?>) {
        val billingPeriod = mapOf(
            "unit" to "MONTH",
            "value" to 1
        )
        val freeBillingPeriod = mapOf(
            "unit" to "DAY",
            "value" to 7
        )
        val introBillingPeriod = mapOf(
            "unit" to "MONTH",
            "value" to 1
        )

        assertThat(option).isNotNull
        assertThat(option["tags"]).isEqualTo(listOf("tag"))
        assertThat(option["isBasePlan"]).isEqualTo(false)

        assertThat(option["billingPeriod"]).isEqualTo(billingPeriod)
        assertThat(option["fullPricePhase"]).isEqualTo(
            mapOf(
                "billingPeriod" to billingPeriod,
                "recurrenceMode" to 1,
                "billingCycleCount" to 0,
                "price" to mapOf(
                    "formatted" to "$4.99",
                    "amountMicros" to (4.99 * MICROS_MULTIPLIER).toLong(),
                    "currencyCode" to "USD"
                ),
            )
        )
        assertThat(option["freePhase"]).isEqualTo(
            mapOf(
                "billingPeriod" to freeBillingPeriod,
                "recurrenceMode" to 1,
                "billingCycleCount" to 0,
                "price" to mapOf(
                    "formatted" to "$0.00",
                    "amountMicros" to 0L,
                    "currencyCode" to "USD"
                ),
            )
        )
        assertThat(option["introPhase"]).isEqualTo(
            mapOf(
                "billingPeriod" to introBillingPeriod,
                "recurrenceMode" to 1,
                "billingCycleCount" to 0,
                "price" to mapOf(
                    "formatted" to "$2.99",
                    "amountMicros" to (2.99 * MICROS_MULTIPLIER).toLong(),
                    "currencyCode" to "USD"
                ),
            )
        )
    }
}