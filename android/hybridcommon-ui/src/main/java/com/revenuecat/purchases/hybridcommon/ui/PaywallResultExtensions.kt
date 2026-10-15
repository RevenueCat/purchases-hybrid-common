package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult

internal const val ERROR_PAYWALL_RESULT = "ERROR"

val PaywallResult.name: String
    get() = when (this) {
        PaywallResult.Cancelled -> "CANCELLED"
        is PaywallResult.Error -> ERROR_PAYWALL_RESULT
        is PaywallResult.Purchased -> "PURCHASED"
        is PaywallResult.Restored -> "RESTORED"
    }
