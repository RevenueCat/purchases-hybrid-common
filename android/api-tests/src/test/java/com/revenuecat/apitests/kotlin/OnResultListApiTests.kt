package com.revenuecat.apitests.kotlin

import com.revenuecat.purchases.hybridcommon.ErrorContainer
import com.revenuecat.purchases.hybridcommon.OnResultList

@Suppress("unused")
class OnResultListApiTests {
    fun checkOnReceived(
        onResult: OnResultList,
        resultMap: List<Map<String, Any>>,
    ) {
        onResult.onReceived(resultMap)
    }

    fun checkOnError(
        onResult: OnResultList,
        errorContainer: ErrorContainer,
    ) {
        onResult.onError(errorContainer)
    }
}
