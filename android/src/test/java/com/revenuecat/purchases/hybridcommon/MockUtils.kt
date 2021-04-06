package com.revenuecat.purchases.hybridcommon

import android.util.Log
import io.mockk.Runs
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkStatic
import java.text.NumberFormat
import java.util.Currency

fun mockLogError() {
    mockkStatic(Log::class)
    every {
        Log.e(
            any(),
            any()
        )
    } returns 0
}

fun mockCurrencyFormatter(price: Long, priceString: String) {
    mockkStatic(NumberFormat::class)
    mockkStatic(Currency::class)
    val mockkNumberFormat = mockk<NumberFormat>()
    val mockkCurrency = mockk<Currency>()
    every { NumberFormat.getCurrencyInstance() } returns mockkNumberFormat
    every { Currency.getInstance("USD") } returns mockkCurrency
    every { mockkNumberFormat.currency = any() } just Runs
    every { mockkNumberFormat.format(price) } returns priceString
}