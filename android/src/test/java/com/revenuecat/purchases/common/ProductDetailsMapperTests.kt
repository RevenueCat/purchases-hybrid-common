package com.revenuecat.purchases.common

import com.revenuecat.purchases.common.mappers.mapIntroPrice
import com.revenuecat.purchases.models.ProductDetails
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe

object SkuDetailsMapperTests : Spek({

    describe("when mapping intro price") {
        var received: Map<String, Any?> = emptyMap()
        val mockProductDetails by memoized { mockk<ProductDetails>() }
        beforeEachTest {
            every { mockProductDetails.priceCurrencyCode } returns "USD"
        }

        describe("with a free trial") {
            describe("7 days") {

                beforeEachTest {
                    mockCurrencyFormatter(0, "$0.00")
                    every { mockProductDetails.freeTrialPeriod } returns "P7D"
                    received = mockProductDetails.mapIntroPrice()
                }

                it("maps correctly") {
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
            }

            describe("1 month") {

                beforeEachTest {
                    mockCurrencyFormatter(0, "$0.00")
                    every { mockProductDetails.freeTrialPeriod } returns "P1M"
                    received = mockProductDetails.mapIntroPrice()
                }

                it("maps correctly") {
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
            }

            describe("0 days") {

                beforeEachTest {
                    mockCurrencyFormatter(0, "$0.00")
                    every { mockProductDetails.freeTrialPeriod } returns "P0D"
                    received = mockProductDetails.mapIntroPrice()
                }

                it("maps correctly") {
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

            describe("365") {

                beforeEachTest {
                    mockLogError()
                    every { mockProductDetails.freeTrialPeriod } returns "365"
                    received = mockProductDetails.mapIntroPrice()
                }

                it("returns map with nulls") {
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
        }

        describe("with an introductory price") {
            beforeEachTest {
                every { mockProductDetails.freeTrialPeriod } returns null
                every { mockProductDetails.introductoryPriceAmountMicros } returns 10000000
                every { mockProductDetails.introductoryPrice } returns "$10.00"
                every { mockProductDetails.introductoryPriceCycles } returns 2
            }
            val expectedCommon = mapOf(
                "price" to 10.0,
                "priceString" to "$10.00",
                "cycles" to 2
            )
            describe("7 days") {

                beforeEachTest {
                    every { mockProductDetails.introductoryPricePeriod } returns "P7D"
                    received = mockProductDetails.mapIntroPrice()
                }

                it("maps correctly") {
                    val expected = mapOf(
                        "period" to "P7D",
                        "periodUnit" to "DAY",
                        "periodNumberOfUnits" to 7
                    ) + expectedCommon
                    assertThat(expected).isEqualTo(received)
                }
            }

            describe("1 month") {

                beforeEachTest {
                    every { mockProductDetails.introductoryPricePeriod } returns "P1M"
                    received = mockProductDetails.mapIntroPrice()
                }

                it("maps correctly") {
                    val expected = mapOf(
                        "period" to "P1M",
                        "periodUnit" to "MONTH",
                        "periodNumberOfUnits" to 1
                    ) + expectedCommon
                    assertThat(expected).isEqualTo(received)
                }
            }

            describe("0 days") {

                beforeEachTest {
                    every { mockProductDetails.introductoryPricePeriod } returns "P0D"
                    received = mockProductDetails.mapIntroPrice()
                }

                it("maps correctly") {
                    val expected = mapOf(
                        "period" to "P0D",
                        "periodUnit" to "DAY",
                        "periodNumberOfUnits" to 0
                    ) + expectedCommon
                    assertThat(expected).isEqualTo(received)
                }
            }

            describe("365") {

                beforeEachTest {
                    mockLogError()
                    every { mockProductDetails.introductoryPricePeriod } returns "365"
                    received = mockProductDetails.mapIntroPrice()
                }

                it("returns map with nulls") {
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
        }

        describe("with no free trial nor introductory price") {
            beforeEachTest {
                every { mockProductDetails.freeTrialPeriod } returns ""
                every { mockProductDetails.introductoryPrice } returns ""
                received = mockProductDetails.mapIntroPrice()
            }

            it("maps correctly") {
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

    }

})