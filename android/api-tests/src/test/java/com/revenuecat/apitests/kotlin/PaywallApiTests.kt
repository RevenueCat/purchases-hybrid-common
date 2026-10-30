package com.revenuecat.apitests.kotlin

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.hybridcommon.ui.CheckpointErrorCode
import com.revenuecat.purchases.hybridcommon.ui.CheckpointListener
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener
import com.revenuecat.purchases.hybridcommon.ui.PaywallSource
import com.revenuecat.purchases.hybridcommon.ui.PresentPaywallOptions
import com.revenuecat.purchases.hybridcommon.ui.cancelErrorDialogs
import com.revenuecat.purchases.hybridcommon.ui.presentCheckpoint
import com.revenuecat.purchases.hybridcommon.ui.presentPaywallFromFragment
import com.revenuecat.purchases.hybridcommon.ui.resolveErrorDialog
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

    fun checkCheckpoint() {
        val listener: CheckpointListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) {
            }

            override fun onCheckpointError(code: String, message: String) {
            }

            override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                val kind: Any? = error["kind"]
                val code: Any? = error["code"]
                val message: Any? = error["message"]
                resolveErrorDialog(requestId, mapOf(
                    "type" to "show",
                    "dialog" to mapOf("message" to "err", "buttonTitle" to "OK"),
                ))
                resolveErrorDialog(requestId, mapOf("type" to "useDefault"))
                resolveErrorDialog(requestId, mapOf("type" to "suppress"))
                resolveErrorDialog(requestId, null)
            }
        }
        presentCheckpoint("identifier", listener = listener)
        presentCheckpoint("identifier", mapOf("key" to "value"), "MODAL_SHEET", listener)
        presentCheckpoint("identifier", callId = "c1", listener = listener)
        presentCheckpoint("identifier", callId = "c1", customVariables = mapOf("k" to "v"), presentationMode = "MODAL_SHEET", listener = listener)
        val notConfigured: String = CheckpointErrorCode.NOT_CONFIGURED
        cancelErrorDialogs("c1")
        cancelErrorDialogs(null)
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
