package com.revenuecat.apitests.java;

import com.revenuecat.purchases.hybridcommon.ExperimentalCommonKt;

import java.util.Map;

@SuppressWarnings("unused")
class ExperimentalCommonApiTests {
    private void checkTrackAdDisplayed(Map<String, Object> adData) {
        ExperimentalCommonKt.trackAdDisplayed(adData);
    }

    private void checkTrackAdOpened(Map<String, Object> adData) {
        ExperimentalCommonKt.trackAdOpened(adData);
    }

    private void checkTrackAdRevenue(Map<String, Object> adData) {
        ExperimentalCommonKt.trackAdRevenue(adData);
    }

    private void checkTrackAdLoaded(Map<String, Object> adData) {
        ExperimentalCommonKt.trackAdLoaded(adData);
    }

    private void checkTrackAdFailedToLoad(Map<String, Object> adData) {
        ExperimentalCommonKt.trackAdFailedToLoad(adData);
    }
}
