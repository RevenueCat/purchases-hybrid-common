package com.revenuecat.purchases.hybridcommon.ui

import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModelProvider
import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallActivityLauncher
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResultHandler

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
internal class PaywallFragment : Fragment(), PaywallResultHandler {
    companion object {
        private const val requiredEntitlementIdentifierKey = "requiredEntitlementIdentifier"
        private const val shouldDisplayDismissButtonKey = "shouldDisplayDismissButton"
        const val tag: String = "revenuecat-paywall-fragment"

        @JvmStatic
        fun newInstance(
            activity: FragmentActivity,
            requiredEntitlementIdentifier: String? = null,
            paywallResultListener: PaywallResultListener? = null,
            shouldDisplayDismissButton: Boolean? = null,
        ): PaywallFragment {
            val paywallFragmentViewModel = ViewModelProvider(activity)[PaywallFragmentViewModel::class.java]
            paywallFragmentViewModel.paywallResultListener = paywallResultListener
            return PaywallFragment().apply {
                arguments = Bundle().apply {
                    putString(requiredEntitlementIdentifierKey, requiredEntitlementIdentifier)
                    shouldDisplayDismissButton?.let { putBoolean(shouldDisplayDismissButtonKey, it) }
                }
            }
        }
    }

    private lateinit var launcher: PaywallActivityLauncher
    private lateinit var viewModel: PaywallFragmentViewModel

    private val requiredEntitlementIdentifier: String?
        get() = arguments?.getString(requiredEntitlementIdentifierKey)

    private val shouldDisplayDismissButton: Boolean?
        get() = arguments?.getBoolean(shouldDisplayDismissButtonKey)

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
        shouldDisplayDismissButton?.let { shouldDisplayDismissButton ->
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                shouldDisplayDismissButton = shouldDisplayDismissButton,
            )
        } ?: launcher.launchIfNeeded(requiredEntitlementIdentifier = requiredEntitlementIdentifier)
    }

    private fun launchPaywall() {
        shouldDisplayDismissButton?.let {
            launcher.launch(shouldDisplayDismissButton = it)
        } ?: launcher.launch()
    }
}
