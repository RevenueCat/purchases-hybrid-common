package com.revenuecat.apitests.java;

import com.revenuecat.purchases.hybridcommon.ErrorContainer;
import com.revenuecat.purchases.hybridcommon.OnResultAny;

@SuppressWarnings("unused")
class OnResultAnyApiTests<T> {
    private void checkOnSuccess(OnResultAny<T> onResult,
                                T result) {
        onResult.onReceived(result);
    }

    private void checkOnError(OnResultAny<T> onResult,
                              ErrorContainer errorContainer) {
        onResult.onError(errorContainer);
    }
}
