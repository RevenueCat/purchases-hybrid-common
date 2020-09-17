package com.revenuecat.purchases.common

import com.revenuecat.purchases.common.mappers.PurchasesPeriod
import org.assertj.core.api.Assertions.assertThat
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe

object PeriodTests : Spek({
    describe("when parsing an invalid PurchasesPeriod") {
        beforeEachTest {
            mockLogError()
        }
        it("there is no exception") {
            val period = PurchasesPeriod.parse("365")
            assertThat(period).isNull()
        }
    }
    describe("when parsing a valid PurchasesPeriod") {
        it("should work") {
            val period = PurchasesPeriod.parse("P1D")
            assertThat(period).isNotNull
        }
    }
})