package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
val PaywallResult.name: String
    get() = when (this) {
        PaywallResult.Cancelled -> "CANCELLED"
        is PaywallResult.Error -> "ERROR"
        is PaywallResult.Purchased -> "PURCHASED"
        is PaywallResult.Restored -> "RESTORED"
    }
