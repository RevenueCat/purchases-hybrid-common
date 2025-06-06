package com.revenuecat.purchases.hybridcommon.ui

import androidx.annotation.CallSuper
import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult
import java.util.concurrent.atomic.AtomicBoolean

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
interface PaywallResultListener {
    // Keeping for now to avoid a breaking change but will be unused.
    @Deprecated(
        "Use onPaywallResult(paywallResult: String) instead",
        ReplaceWith("onPaywallResult(paywallResult: String)"),
    )
    fun onPaywallResult(paywallResult: PaywallResult) {}

    // This is used by the hybrids with the result of presenting the paywall as a string. It's mapped to an enum
    // in the hybrids.
    fun onPaywallResult(paywallResult: String)
}

/**
 * A [PaywallResultListener] who's [onPaywallResult] is only called once.
 */
abstract class SingleFirePaywallResultListener : PaywallResultListener {
    private val hasFired = AtomicBoolean(false)

    @CallSuper
    override fun onPaywallResult(paywallResult: String) {
        if (hasFired.getAndSet(true)) return
    }

    @CallSuper
    @Suppress("OVERRIDE_DEPRECATION")
    override fun onPaywallResult(paywallResult: PaywallResult) {
        if (hasFired.getAndSet(true)) return
    }
}
