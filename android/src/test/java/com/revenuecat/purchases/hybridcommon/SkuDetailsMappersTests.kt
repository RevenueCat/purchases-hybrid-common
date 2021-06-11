package com.revenuecat.purchases.hybridcommon

import com.android.billingclient.api.SkuDetails
import com.revenuecat.purchases.hybridcommon.mappers.mapIntroPrice
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

internal class SkuDetailsMapperTests {

    var received: Map<String, Any?> = emptyMap()
    val mockSkuDetails = mockk<SkuDetails>(relaxed = true)

    @BeforeEach
    fun setup() {
        every { mockSkuDetails.priceCurrencyCode } returns "USD"
    }

    @Nested
    @DisplayName("when mapping a SkuDetails with a free trial")
    inner class MappingFreeTrial {
        @Test
        fun `of 7 days, the map has the correct intro price values`() {
            mockCurrencyFormatter(0, "$0.00")
            every { mockSkuDetails.freeTrialPeriod } returns "P7D"
            received = mockSkuDetails.mapIntroPrice()
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
            mockCurrencyFormatter(0, "$0.00")
            every { mockSkuDetails.freeTrialPeriod } returns "P1M"
            received = mockSkuDetails.mapIntroPrice()
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
            mockCurrencyFormatter(0, "$0.00")
            every { mockSkuDetails.freeTrialPeriod } returns "P0D"
            received = mockSkuDetails.mapIntroPrice()

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

        @Test
        fun `with value 365, the map has the correct intro price values`() {
            mockLogError()
            every { mockSkuDetails.freeTrialPeriod } returns "365"
            received = mockSkuDetails.mapIntroPrice()
            val expected = mapOf(
                "price" to null,
                "priceString" to null,
                "period" to null,
                "cycles" to null,
                "periodUnit" to null,
                "periodNumberOfUnits" to null
            )
            assertThat(expected).isEqualTo(received)
        }
    }


    @Nested
    @DisplayName("when mapping a SkuDetails with an intro price")
    inner class MappingIntroPrice {
        @BeforeEach
        fun beforeEachTest() {
            every { mockSkuDetails.introductoryPriceAmountMicros } returns 10000000
            every { mockSkuDetails.introductoryPrice } returns "$10.00"
            every { mockSkuDetails.introductoryPriceCycles } returns 2
            received = mockSkuDetails.mapIntroPrice()
        }

        private val expectedCommon = mapOf(
            "price" to 10.0,
            "priceString" to "$10.00",
            "cycles" to 2
        )

        @Test
        fun `of 7 days, the map has the correct intro price values`() {
            every { mockSkuDetails.introductoryPricePeriod } returns "P7D"
            received = mockSkuDetails.mapIntroPrice()
            val expected = mapOf(
                "period" to "P7D",
                "periodUnit" to "DAY",
                "periodNumberOfUnits" to 7
            ) + expectedCommon
            assertThat(expected).isEqualTo(received)
        }

        @Test
        fun `of 1 month, the map has the correct intro price values`() {
            every { mockSkuDetails.introductoryPricePeriod } returns "P1M"
            received = mockSkuDetails.mapIntroPrice()

            val expected = mapOf(
                "period" to "P1M",
                "periodUnit" to "MONTH",
                "periodNumberOfUnits" to 1
            ) + expectedCommon
            assertThat(expected).isEqualTo(received)
        }

        @Test
        fun `of 0 days, the map has the correct intro price values`() {
            every { mockSkuDetails.introductoryPricePeriod } returns "P0D"
            received = mockSkuDetails.mapIntroPrice()

            val expected = mapOf(
                "period" to "P0D",
                "periodUnit" to "DAY",
                "periodNumberOfUnits" to 0
            ) + expectedCommon
            assertThat(expected).isEqualTo(received)
        }

        @Test
        fun `with a value of 365, the map has the correct intro price values`() {
            mockLogError()
            every { mockSkuDetails.introductoryPricePeriod } returns "365"
            received = mockSkuDetails.mapIntroPrice()

            val expected = mapOf(
                "price" to null,
                "priceString" to null,
                "period" to null,
                "cycles" to null,
                "periodUnit" to null,
                "periodNumberOfUnits" to null
            )
            assertThat(expected).isEqualTo(received)
        }
    }

    @Test
    fun `when mapping a SkuDetails with no free trial nor introductory price, the map has null intro price values`() {
        every { mockSkuDetails.freeTrialPeriod } returns ""
        every { mockSkuDetails.introductoryPrice } returns ""
        received = mockSkuDetails.mapIntroPrice()

        val expected = mapOf(
            "price" to null,
            "priceString" to null,
            "period" to null,
            "cycles" to null,
            "periodUnit" to null,
            "periodNumberOfUnits" to null
        )
        assertThat(expected).isEqualTo(received)
    }
}
