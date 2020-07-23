package com.revenuecat.purchases.common

import android.util.Log
import io.mockk.every
import io.mockk.mockkStatic

fun mockLogError() {
    mockkStatic(Log::class)
    every {
        Log.e(
            any(),
            any()
        )
    } returns 0
}