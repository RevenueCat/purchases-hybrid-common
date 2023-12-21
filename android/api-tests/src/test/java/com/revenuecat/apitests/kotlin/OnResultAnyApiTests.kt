package com.revenuecat.apitests.kotlin

import com.revenuecat.purchases.hybridcommon.ErrorContainer
import com.revenuecat.purchases.hybridcommon.OnResultAny

@Suppress("unused")
private class OnResultAnyApiTests<T> {
    fun checkOnSuccess(
        onResult: OnResultAny<T>,
        result: T,
    ) {
        onResult.onReceived(result)
    }

    fun checkOnError(
        onResult: OnResultAny<T>,
        errorContainer: ErrorContainer,
    ) {
        onResult.onError(errorContainer)
    }
}
