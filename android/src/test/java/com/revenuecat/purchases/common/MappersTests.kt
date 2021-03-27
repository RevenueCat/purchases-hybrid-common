package com.revenuecat.purchases.common

import com.revenuecat.purchases.common.mappers.toMillis
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import java.text.SimpleDateFormat
import java.util.*

internal class MappersHelpersTests {

    @Test
    fun `PurchasesPeriod gets parsed correctly`() {
        val dateFormat = SimpleDateFormat("dd-MM-yyyy")
        dateFormat.timeZone = TimeZone.getTimeZone("UTC")

        val date1: Date? = dateFormat.parse("14-01-2021")
        assertThat(date1?.toMillis()).isEqualTo(1610582400000L)

        val date2: Date? = dateFormat.parse("03-03-2019")
        assertThat(date2?.toMillis()).isEqualTo(1551571200000L)

        val date3: Date? = dateFormat.parse("31-07-1990")
        assertThat(date3?.toMillis()).isEqualTo(649382400000L)
    }

}
