package com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
interface PaywallResultListener {
    fun onPaywallResult(paywallResult: PaywallResult)
}
