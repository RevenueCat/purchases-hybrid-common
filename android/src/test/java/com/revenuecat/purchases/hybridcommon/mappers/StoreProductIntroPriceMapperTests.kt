package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.models.Period
import com.revenuecat.purchases.models.StoreProduct
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

internal class StoreProductIntroPriceMapperTests {

    var received: Map<String, Any?>? = emptyMap()
    val mockStoreProduct = mockk<StoreProduct>(relaxed = true)

    @BeforeEach
    fun setup() {
        every { mockStoreProduct.priceCurrencyCode } returns "USD"
    }

    @Nested
    @DisplayName("when mapping a StoreProduct with a free trial")
    inner class MappingFreeTrial {
        @Test
        fun `of 7 days, the map has the correct intro price values`() {
            every { mockStoreProduct.freeTrialPeriod } returns Period(7, Period.Unit.DAY, "P7D")
            every { mockStoreProduct.freeTrialCycles } returns 1
            received = mockStoreProduct.mapIntroPrice()
            val expected = mapOf(
                "price" to 0,
                "priceString" to "$0.00",
                "period" to "P7D",
                "cycles" to 1,
                "periodUnit" to "DAY",
                "periodNumberOfUnits" to 7
            )
            assertThat(expected).isEqualTo(received)
        }

        @Test
        fun `of 1 month, the map has the correct intro price values`() {
            every { mockStoreProduct.freeTrialPeriod } returns Period(1, Period.Unit.MONTH, "P1M")
            every { mockStoreProduct.freeTrialCycles } returns 1
            received = mockStoreProduct.mapIntroPrice()
            val expected = mapOf(
                "price" to 0,
                "priceString" to "$0.00",
                "period" to "P1M",
                "cycles" to 1,
                "periodUnit" to "MONTH",
                "periodNumberOfUnits" to 1
            )
            assertThat(expected).isEqualTo(received)
        }

        @Test
        fun `of 0 days, the map has the correct intro price values`() {
            every { mockStoreProduct.freeTrialPeriod } returns Period(0, Period.Unit.DAY, "P0D")
            every { mockStoreProduct.freeTrialCycles } returns 1
            received = mockStoreProduct.mapIntroPrice()

            val expected = mapOf(
                "price" to 0,
                "priceString" to "$0.00",
                "period" to "P0D",
                "cycles" to 1,
                "periodUnit" to "DAY",
                "periodNumberOfUnits" to 0
            )
            assertThat(expected).isEqualTo(received)
        }
    }

    @Nested
    @DisplayName("when mapping a StoreProduct with an intro price")
    inner class MappingIntroPrice {
        @BeforeEach
        fun beforeEachTest() {
            every { mockStoreProduct.freeTrialPeriod?.iso8601 } returns null
            every { mockStoreProduct.introductoryPriceAmountMicros } returns 10_000_000
            every { mockStoreProduct.introductoryPrice } returns "$10.00"
            every { mockStoreProduct.introductoryPriceCycles } returns 2
        }

        private val expectedCommon = mapOf(
            "price" to 10.0,
            "priceString" to "$10.00",
            "cycles" to 2
        )

        @Test
        fun `of 7 days, the map has the correct intro price values`() {
            every { mockStoreProduct.freeTrialPeriod } returns null
            every { mockStoreProduct.introductoryPricePeriod } returns Period(7, Period.Unit.DAY, "P7D")
            received = mockStoreProduct.mapIntroPrice()
            val expected = mapOf(
                "period" to "P7D",
                "periodUnit" to "DAY",
                "periodNumberOfUnits" to 7
            ) + expectedCommon
            assertThat(expected).isEqualTo(received)
        }

        @Test
        fun `of 1 month, the map has the correct intro price values`() {
            every { mockStoreProduct.freeTrialPeriod } returns null
            every { mockStoreProduct.introductoryPricePeriod } returns Period(1, Period.Unit.MONTH, "P1M")
            received = mockStoreProduct.mapIntroPrice()

            val expected = mapOf(
                "period" to "P1M",
                "periodUnit" to "MONTH",
                "periodNumberOfUnits" to 1
            ) + expectedCommon
            assertThat(expected).isEqualTo(received)
        }

        @Test
        fun `of 0 days, the map has the correct intro price values`() {
            every { mockStoreProduct.freeTrialPeriod } returns null
            every { mockStoreProduct.introductoryPricePeriod } returns Period(0, Period.Unit.DAY, "P0D")
            received = mockStoreProduct.mapIntroPrice()

            val expected = mapOf(
                "period" to "P0D",
                "periodUnit" to "DAY",
                "periodNumberOfUnits" to 0
            ) + expectedCommon
            assertThat(expected).isEqualTo(received)
        }
    }

    @Test
    fun `when mapping a StoreProduct with no free trial nor introductory price, intro price is null`() {
        every { mockStoreProduct.freeTrialPeriod } returns null
        every { mockStoreProduct.introductoryPrice } returns null
        received = mockStoreProduct.mapIntroPrice()
        assertThat(received).isEqualTo(null)
    }
}
