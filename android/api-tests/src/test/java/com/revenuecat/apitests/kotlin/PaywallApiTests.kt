package com.revenuecat.apitests.kotlin

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener
import com.revenuecat.purchases.hybridcommon.ui.SingleFirePaywallResultListener
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

    fun checkSingleFirePaywallResultListener() {
        val listener: SingleFirePaywallResultListener = object : SingleFirePaywallResultListener() {
            override fun onPaywallResult(paywallResult: PaywallResult) {
                super.onPaywallResult(paywallResult)
            }

            override fun onPaywallResult(paywallResult: String) {
                super.onPaywallResult(paywallResult)
            }
        }
    }

    fun checkPresentPaywall(
        fragmentActivity: FragmentActivity,
        requiredEntitlementIdentifier: String?,
        paywallResultListener: PaywallResultListener?,
        shouldDisplayDismissButton: Boolean?,
        offering: Offering?,
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
        presentPaywallFromFragment(
            fragment = fragmentActivity,
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            paywallResultListener = paywallResultListener,
            shouldDisplayDismissButton = shouldDisplayDismissButton,
        )
        presentPaywallFromFragment(
            fragment = fragmentActivity,
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            paywallResultListener = paywallResultListener,
            shouldDisplayDismissButton = shouldDisplayDismissButton,
            offering = offering,
        )
    }
}
