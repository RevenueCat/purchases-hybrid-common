package com.revenuecat.purchases.common

import android.os.Build
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.assertj.core.api.Assertions.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.annotation.Config

@RunWith(AndroidJUnit4::class)
@Config(sdk = [Build.VERSION_CODES.P])
class PeriodTests {
    @Test
    fun `there is no exception when parsing an invalid PurchasesPeriod`() {
        val period = PurchasesPeriod.parse("365")
        assertThat(period).isNull()
    }

    @Test
    fun `parsing works`() {
        val period = PurchasesPeriod.parse("P1D")
        assertThat(period).isNotNull
    }
}