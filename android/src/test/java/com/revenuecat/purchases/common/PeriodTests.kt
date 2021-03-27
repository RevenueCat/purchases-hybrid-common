package com.revenuecat.purchases.common

import com.revenuecat.purchases.common.mappers.PurchasesPeriod
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

internal class PeriodTests {

    @Test
    fun `when parsing an invalid PurchasesPeriod, there is no exception`() {
        mockLogError()

        val period = PurchasesPeriod.parse("365")
        assertThat(period).isNull()
    }

    @Test
    fun `when parsing a valid PurchasesPeriod, period is not null`() {
        val period = PurchasesPeriod.parse("P1D")
        assertThat(period).isNotNull
    }
}