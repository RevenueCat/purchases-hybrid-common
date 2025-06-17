package com.revenuecat.apitests.kotlin

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener
import com.revenuecat.purchases.hybridcommon.ui.presentPaywallFromFragment
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult

@Suppress("unused", "UNUSED_VARIABLE", "EmptyFunctionBlock")
private class PaywallApiTests {

    fun checkPaywallResultListener() {
        val listener: PaywallResultListener = object : PaywallResultListener {
            override fun onPaywallResult(paywallResult: PaywallResult) {
            }

            override fun onPaywallResult(paywallResult: String) {
            }
        }
    }

    fun checkPresentPaywall(
        fragmentActivity: FragmentActivity,
        requiredEntitlementIdentifier: String?,
        paywallResultListener: PaywallResultListener,
        shouldDisplayDismissButton: Boolean?,
        offering: Offering?,
    ) {
        presentPaywallFromFragment(
            activity = fragmentActivity,
            paywallResultListener = paywallResultListener,
        )
        presentPaywallFromFragment(
            activity = fragmentActivity,
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            paywallResultListener = paywallResultListener,
        )
        presentPaywallFromFragment(
            activity = fragmentActivity,
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            paywallResultListener = paywallResultListener,
            shouldDisplayDismissButton = shouldDisplayDismissButton,
        )
        presentPaywallFromFragment(
            activity = fragmentActivity,
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            paywallResultListener = paywallResultListener,
            shouldDisplayDismissButton = shouldDisplayDismissButton,
            offering = offering,
        )
    }
}
