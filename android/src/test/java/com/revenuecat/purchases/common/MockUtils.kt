package com.revenuecat.purchases.common

import android.util.Log
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import java.text.NumberFormat

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
    val mockkNumberFormat = mockk<NumberFormat>()
    every { NumberFormat.getCurrencyInstance() } returns mockkNumberFormat
    every { mockkNumberFormat.format(price) } returns priceString
}