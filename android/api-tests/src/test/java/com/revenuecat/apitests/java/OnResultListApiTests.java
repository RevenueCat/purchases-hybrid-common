package com.revenuecat.apitests.java;

import com.revenuecat.purchases.hybridcommon.ErrorContainer;
import com.revenuecat.purchases.hybridcommon.OnResultList;

import java.util.List;
import java.util.Map;

@SuppressWarnings("unused")
class OnResultListApiTests {
    private void checkOnSuccess(OnResultList onResult,
                                List<Map<String, ?>> result) {
        onResult.onReceived(result);
    }

    private void checkOnError(OnResultList onResult,
                              ErrorContainer errorContainer) {
        onResult.onError(errorContainer);
    }
}
