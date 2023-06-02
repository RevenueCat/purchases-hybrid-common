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