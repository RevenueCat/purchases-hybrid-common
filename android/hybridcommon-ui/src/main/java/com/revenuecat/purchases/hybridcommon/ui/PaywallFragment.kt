package com.revenuecat.purchases.hybridcommon.ui

import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModelProvider
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallActivityLauncher
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResultHandler

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
internal class PaywallFragment : Fragment(), PaywallResultHandler {
    companion object {
        private const val requiredEntitlementIdentifierKey = "requiredEntitlementIdentifier"
        private const val shouldDisplayDismissButtonKey = "shouldDisplayDismissButton"
        private const val offeringIdentifierKey = "offeringIdentifier"
        const val tag: String = "revenuecat-paywall-fragment"

        @JvmStatic
        fun newInstance(
            activity: FragmentActivity,
            requiredEntitlementIdentifier: String? = null,
            paywallResultListener: PaywallResultListener? = null,
            shouldDisplayDismissButton: Boolean? = null,
            offering: Offering? = null,
        ): PaywallFragment {
            val paywallFragmentViewModel = ViewModelProvider(activity)[PaywallFragmentViewModel::class.java]
            paywallFragmentViewModel.paywallResultListener = paywallResultListener
            return PaywallFragment().apply {
                arguments = Bundle().apply {
                    putString(requiredEntitlementIdentifierKey, requiredEntitlementIdentifier)
                    shouldDisplayDismissButton?.let { putBoolean(shouldDisplayDismissButtonKey, it) }
                    offering?.let { putString(offeringIdentifierKey, it.identifier) }
                }
            }
        }
    }

    private lateinit var launcher: PaywallActivityLauncher
    private lateinit var viewModel: PaywallFragmentViewModel

    private val requiredEntitlementIdentifier: String?
        get() = arguments?.getString(requiredEntitlementIdentifierKey)

    private val shouldDisplayDismissButton: Boolean?
        get() {
            return arguments?.let {
                if (it.containsKey(shouldDisplayDismissButtonKey)) {
                    it.getBoolean(shouldDisplayDismissButtonKey)
                } else {
                    null
                }
            }
        }

    private val offeringIdentifier: String?
        get() = arguments?.getString(offeringIdentifierKey)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        launcher = PaywallActivityLauncher(
            this,
            this,
        )
        viewModel = ViewModelProvider(requireActivity())[PaywallFragmentViewModel::class.java]

        requiredEntitlementIdentifier?.let { requiredEntitlementIdentifier ->
            launchPaywallIfNeeded(requiredEntitlementIdentifier)
        } ?: launchPaywall()
    }

    override fun onActivityResult(result: PaywallResult) {
        viewModel.paywallResultListener?.onPaywallResult(result)
    }

    private fun launchPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        val displayDismissButton = shouldDisplayDismissButton
        val offering = offeringIdentifier

        if (displayDismissButton != null && offering != null) {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                shouldDisplayDismissButton = displayDismissButton,
                offeringIdentifier = offering,
            )
        } else if (displayDismissButton != null) {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                shouldDisplayDismissButton = displayDismissButton,
            )
        } else if (offering != null) {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                offeringIdentifier = offering,
            )
        } else {
            launcher.launchIfNeeded(requiredEntitlementIdentifier = requiredEntitlementIdentifier)
        }
    }

    private fun launchPaywall() {
        val offering = offeringIdentifier
        val displayDismissButton = shouldDisplayDismissButton

        if (displayDismissButton != null && offering != null) {
            launcher.launch(
                shouldDisplayDismissButton = displayDismissButton,
                offeringIdentifier = offering,
            )
        } else if (displayDismissButton != null) {
            launcher.launch(shouldDisplayDismissButton = displayDismissButton)
        } else if (offering != null) {
            launcher.launch(offeringIdentifier = offering)
        } else {
            launcher.launch()
        }
    }
}
