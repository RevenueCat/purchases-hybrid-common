package com.revenuecat.apitests.kotlin

import com.revenuecat.purchases.hybridcommon.ExperimentalPreviewHybridCommonAPI
import com.revenuecat.purchases.hybridcommon.trackAdDisplayed
import com.revenuecat.purchases.hybridcommon.trackAdFailedToLoad
import com.revenuecat.purchases.hybridcommon.trackAdLoaded
import com.revenuecat.purchases.hybridcommon.trackAdOpened
import com.revenuecat.purchases.hybridcommon.trackAdRevenue

@Suppress("unused")
@OptIn(ExperimentalPreviewHybridCommonAPI::class)
private class ExperimentalCommonApiTests {
    fun checkTrackAdDisplayed(adData: Map<String, Any?>) {
        trackAdDisplayed(adData)
    }

    fun checkTrackAdOpened(adData: Map<String, Any?>) {
        trackAdOpened(adData)
    }

    fun checkTrackAdRevenue(adData: Map<String, Any?>) {
        trackAdRevenue(adData)
    }

    fun checkTrackAdLoaded(adData: Map<String, Any?>) {
        trackAdLoaded(adData)
    }

    fun checkTrackAdFailedToLoad(adData: Map<String, Any?>) {
        trackAdFailedToLoad(adData)
    }
}
