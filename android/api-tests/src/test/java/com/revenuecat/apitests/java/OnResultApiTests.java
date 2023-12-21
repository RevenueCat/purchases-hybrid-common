package com.revenuecat.apitests.java;

import com.revenuecat.purchases.hybridcommon.ErrorContainer;
import com.revenuecat.purchases.hybridcommon.OnResult;

import java.util.Map;

@SuppressWarnings("unused")
class OnResultApiTests {
    private void checkOnSuccess(OnResult onResult,
                                Map<String, Object> result) {
        onResult.onReceived(result);
    }

    private void checkOnError(OnResult onResult,
                              ErrorContainer errorContainer) {
        onResult.onError(errorContainer);
    }
}
