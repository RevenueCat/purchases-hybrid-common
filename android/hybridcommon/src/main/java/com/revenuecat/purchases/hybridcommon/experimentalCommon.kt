package com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.ads.events.types.AdDisplayedData
import com.revenuecat.purchases.ads.events.types.AdFailedToLoadData
import com.revenuecat.purchases.ads.events.types.AdFormat
import com.revenuecat.purchases.ads.events.types.AdLoadedData
import com.revenuecat.purchases.ads.events.types.AdMediatorName
import com.revenuecat.purchases.ads.events.types.AdOpenedData
import com.revenuecat.purchases.ads.events.types.AdRevenueData
import com.revenuecat.purchases.ads.events.types.AdRevenuePrecision

// region Ad Tracking

@ExperimentalPreviewHybridCommonAPI
@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
@Suppress("ComplexCondition")
fun trackAdDisplayed(adData: Map<String, Any?>) {
    val networkName = adData["networkName"] as? String
    val mediatorNameString = adData["mediatorName"] as? String
    val adFormatString = adData["adFormat"] as? String
    val adUnitId = adData["adUnitId"] as? String
    val impressionId = adData["impressionId"] as? String

    if (mediatorNameString == null ||
        adFormatString == null ||
        adUnitId == null ||
        impressionId == null
    ) {
        errorLog(
            "trackAdDisplayed: Missing required parameters - " +
                "mediatorName, adFormat, adUnitId, or impressionId",
        )
        return
    }

    val placement = adData["placement"] as? String
    val displayedData = AdDisplayedData(
        networkName = networkName,
        mediatorName = AdMediatorName.fromString(mediatorNameString),
        adFormat = AdFormat.fromString(adFormatString),
        placement = placement,
        adUnitId = adUnitId,
        impressionId = impressionId,
    )

    Purchases.sharedInstance.adTracker.trackAdDisplayed(displayedData)
}

@ExperimentalPreviewHybridCommonAPI
@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
@Suppress("ComplexCondition")
fun trackAdOpened(adData: Map<String, Any?>) {
    val networkName = adData["networkName"] as? String
    val mediatorNameString = adData["mediatorName"] as? String
    val adFormatString = adData["adFormat"] as? String
    val adUnitId = adData["adUnitId"] as? String
    val impressionId = adData["impressionId"] as? String

    if (mediatorNameString == null ||
        adFormatString == null ||
        adUnitId == null ||
        impressionId == null
    ) {
        errorLog(
            "trackAdOpened: Missing required parameters - " +
                "mediatorName, adFormat, adUnitId, or impressionId",
        )
        return
    }

    val placement = adData["placement"] as? String
    val openedData = AdOpenedData(
        networkName = networkName,
        mediatorName = AdMediatorName.fromString(mediatorNameString),
        adFormat = AdFormat.fromString(adFormatString),
        placement = placement,
        adUnitId = adUnitId,
        impressionId = impressionId,
    )

    Purchases.sharedInstance.adTracker.trackAdOpened(openedData)
}

@ExperimentalPreviewHybridCommonAPI
@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
@Suppress("ComplexCondition")
fun trackAdRevenue(adData: Map<String, Any?>) {
    val networkName = adData["networkName"] as? String
    val mediatorNameString = adData["mediatorName"] as? String
    val adFormatString = adData["adFormat"] as? String
    val adUnitId = adData["adUnitId"] as? String
    val impressionId = adData["impressionId"] as? String
    val revenueMicros = (adData["revenueMicros"] as? Number)?.toLong()
    val currency = adData["currency"] as? String
    val precisionString = adData["precision"] as? String

    if (mediatorNameString == null ||
        adFormatString == null ||
        adUnitId == null ||
        impressionId == null ||
        revenueMicros == null ||
        currency == null ||
        precisionString == null
    ) {
        errorLog(
            "trackAdRevenue: Missing required parameters - " +
                "mediatorName, adFormat, adUnitId, impressionId, revenueMicros, currency, or precision",
        )
        return
    }

    val placement = adData["placement"] as? String
    val revenueData = AdRevenueData(
        networkName = networkName,
        mediatorName = AdMediatorName.fromString(mediatorNameString),
        adFormat = AdFormat.fromString(adFormatString),
        placement = placement,
        adUnitId = adUnitId,
        impressionId = impressionId,
        revenueMicros = revenueMicros,
        currency = currency,
        precision = AdRevenuePrecision.fromString(precisionString),
    )

    Purchases.sharedInstance.adTracker.trackAdRevenue(revenueData)
}

@ExperimentalPreviewHybridCommonAPI
@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
@Suppress("ComplexCondition")
fun trackAdLoaded(adData: Map<String, Any?>) {
    val networkName = adData["networkName"] as? String
    val mediatorNameString = adData["mediatorName"] as? String
    val adFormatString = adData["adFormat"] as? String
    val adUnitId = adData["adUnitId"] as? String
    val impressionId = adData["impressionId"] as? String

    if (mediatorNameString == null ||
        adFormatString == null ||
        adUnitId == null ||
        impressionId == null
    ) {
        errorLog(
            "trackAdLoaded: Missing required parameters - " +
                "mediatorName, adFormat, adUnitId, or impressionId",
        )
        return
    }

    val placement = adData["placement"] as? String
    val loadedData = AdLoadedData(
        networkName = networkName,
        mediatorName = AdMediatorName.fromString(mediatorNameString),
        adFormat = AdFormat.fromString(adFormatString),
        placement = placement,
        adUnitId = adUnitId,
        impressionId = impressionId,
    )

    Purchases.sharedInstance.adTracker.trackAdLoaded(loadedData)
}

@ExperimentalPreviewHybridCommonAPI
@OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
@Suppress("ComplexCondition")
fun trackAdFailedToLoad(adData: Map<String, Any?>) {
    val mediatorNameString = adData["mediatorName"] as? String
    val adFormatString = adData["adFormat"] as? String
    val adUnitId = adData["adUnitId"] as? String

    if (mediatorNameString == null ||
        adFormatString == null ||
        adUnitId == null
    ) {
        errorLog(
            "trackAdFailedToLoad: Missing required parameters - " +
                "mediatorName, adFormat, or adUnitId",
        )
        return
    }

    val placement = adData["placement"] as? String
    val mediatorErrorCode = (adData["mediatorErrorCode"] as? Number)?.toInt()
    val failedToLoadData = AdFailedToLoadData(
        mediatorName = AdMediatorName.fromString(mediatorNameString),
        adFormat = AdFormat.fromString(adFormatString),
        placement = placement,
        adUnitId = adUnitId,
        mediatorErrorCode = mediatorErrorCode,
    )

    Purchases.sharedInstance.adTracker.trackAdFailedToLoad(failedToLoadData)
}

// endregion
