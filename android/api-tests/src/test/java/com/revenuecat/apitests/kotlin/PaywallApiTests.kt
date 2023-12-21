package com.revenuecat.apitests.kotlin

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener
import com.revenuecat.purchases.hybridcommon.ui.presentPaywallFromFragment
import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult

@Suppress("unused", "UNUSED_VARIABLE", "EmptyFunctionBlock")
private class PaywallApiTests {

    @OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
    fun checkPaywallResultListener() {
        val listener: PaywallResultListener = object : PaywallResultListener {
            override fun onPaywallResult(paywallResult: PaywallResult) {
            }
        }
    }

    fun checkPresentPaywall(
        fragmentActivity: FragmentActivity,
        requiredEntitlementIdentifier: String?,
        paywallResultListener: PaywallResultListener?,
    ) {
        presentPaywallFromFragment(
            fragment = fragmentActivity,
        )
        presentPaywallFromFragment(
            fragment = fragmentActivity,
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
        )
        presentPaywallFromFragment(
            fragment = fragmentActivity,
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            paywallResultListener = paywallResultListener,
        )
    }
}
