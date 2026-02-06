package com.revenuecat.apitests.kotlin

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener
import com.revenuecat.purchases.hybridcommon.ui.PaywallSource
import com.revenuecat.purchases.hybridcommon.ui.PresentPaywallOptions
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

    fun checkPaywallSource(paywallSource: PaywallSource) {
        when (paywallSource) {
            is PaywallSource.Offering -> {
                val offering: Offering = paywallSource.value
            }
            PaywallSource.DefaultOffering -> {
            }
            is PaywallSource.OfferingIdentifier -> {
                val identifier: String = paywallSource.value
            }
            is PaywallSource.OfferingIdentifierWithPresentedOfferingContext -> {
                val identifier: String = paywallSource.offeringIdentifier
                val context: PresentedOfferingContext = paywallSource.presentedOfferingContext
            }
        }
    }

    @Suppress("LongParameterList")
    fun checkPresentPaywall(
        fragmentActivity: FragmentActivity,
        requiredEntitlementIdentifier: String?,
        paywallResultListener: PaywallResultListener,
        shouldDisplayDismissButton: Boolean?,
        offering: Offering?,
        presentPaywallOptions: PresentPaywallOptions,
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
        presentPaywallFromFragment(
            activity = fragmentActivity,
            options = presentPaywallOptions,
        )
    }

    fun checkPresentPaywallOptionsWithCustomVariables(
        paywallResultListener: PaywallResultListener,
    ) {
        val options = PresentPaywallOptions(
            paywallResultListener = paywallResultListener,
            customVariables = mapOf("user_name" to "John", "count" to 42, "enabled" to true),
        )
        val retrievedVariables: Map<String, Any?>? = options.customVariables
    }

    fun checkPresentPaywallOptionsWithCustomVariablesAndContext(
        fragmentActivity: FragmentActivity,
        paywallResultListener: PaywallResultListener,
    ) {
        val options = PresentPaywallOptions(
            paywallResultListener = paywallResultListener,
            paywallSource = PaywallSource.OfferingIdentifierWithPresentedOfferingContext(
                offeringIdentifier = "offering",
                presentedOfferingContext = PresentedOfferingContext("offering"),
            ),
            customVariables = mapOf("user_name" to "John"),
        )
        presentPaywallFromFragment(
            activity = fragmentActivity,
            options = options,
        )
    }
}
