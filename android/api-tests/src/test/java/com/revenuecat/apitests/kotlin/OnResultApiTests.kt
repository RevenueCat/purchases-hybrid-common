package com.revenuecat.apitests.kotlin

import com.revenuecat.purchases.hybridcommon.ErrorContainer
import com.revenuecat.purchases.hybridcommon.OnResult

@Suppress("unused")
private class OnResultApiTests {
    fun checkOnReceived(
        onResult: OnResult,
        resultMap: Map<String, Any>,
    ) {
        onResult.onReceived(resultMap)
    }

    fun checkOnError(
        onResult: OnResult,
        errorContainer: ErrorContainer,
    ) {
        onResult.onError(errorContainer)
    }
}
