package com.revenuecat.purchases.hybridcommon.ui

import android.os.Build
import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModelProvider
import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallActivityLauncher
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallDisplayCallback
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResultHandler
import com.revenuecat.purchases.ui.revenuecatui.fonts.CustomParcelizableFontProvider
import com.revenuecat.purchases.ui.revenuecatui.fonts.PaywallFontFamily

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
internal class PaywallFragment : Fragment(), PaywallResultHandler {
    companion object {
        enum class Key(val key: String) {
            REQUIRED_ENTITLEMENT_IDENTIFIER("requiredEntitlementIdentifier"),
            SHOULD_DISPLAY_DISMISS_BUTTON("shouldDisplayDismissButton"),
            OFFERING_IDENTIFIER("offeringIdentifier"),
            FONT_FAMILY("fontProvider"),
        }

        private const val notPresentedPaywallResult = "NOT_PRESENTED"
        const val tag: String = "revenuecat-paywall-fragment"

        @Suppress("LongParameterList")
        @JvmStatic
        fun newInstance(
            activity: FragmentActivity,
            requiredEntitlementIdentifier: String? = null,
            paywallResultListener: PaywallResultListener? = null,
            shouldDisplayDismissButton: Boolean? = null,
            paywallSource: PaywallSource,
            fontFamily: PaywallFontFamily? = null,
        ): PaywallFragment {
            val paywallFragmentViewModel = ViewModelProvider(activity)[PaywallFragmentViewModel::class.java]
            paywallFragmentViewModel.paywallResultListener = paywallResultListener
            return PaywallFragment().apply {
                arguments = Bundle().apply {
                    putString(Key.REQUIRED_ENTITLEMENT_IDENTIFIER.key, requiredEntitlementIdentifier)
                    shouldDisplayDismissButton?.let { putBoolean(Key.SHOULD_DISPLAY_DISMISS_BUTTON.key, it) }
                    when (paywallSource) {
                        is PaywallSource.Offering -> putString(
                            Key.OFFERING_IDENTIFIER.key,
                            paywallSource.value.identifier,
                        )

                        is PaywallSource.OfferingIdentifier -> putString(
                            Key.OFFERING_IDENTIFIER.key,
                            paywallSource.value,
                        )

                        is PaywallSource.DefaultOffering -> Unit
                    }
                    fontFamily?.let { putParcelable(Key.FONT_FAMILY.key, it) }
                }
            }
        }
    }

    private lateinit var launcher: PaywallActivityLauncher
    private lateinit var viewModel: PaywallFragmentViewModel

    private val requiredEntitlementIdentifier: String?
        get() = arguments?.getString(Key.REQUIRED_ENTITLEMENT_IDENTIFIER.key)

    private val shouldDisplayDismissButtonArg: Boolean?
        get() {
            return arguments?.let {
                if (it.containsKey(Key.SHOULD_DISPLAY_DISMISS_BUTTON.key)) {
                    it.getBoolean(Key.SHOULD_DISPLAY_DISMISS_BUTTON.key)
                } else {
                    null
                }
            }
        }

    private val fontFamily: PaywallFontFamily?
        get() = arguments?.takeIf { it.containsKey(Key.FONT_FAMILY.key) }?.let {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                it.getParcelable(Key.FONT_FAMILY.key, PaywallFontFamily::class.java)
            } else {
                @Suppress("DEPRECATION")
                it.getParcelable(Key.FONT_FAMILY.key)
            }
        }

    private val offeringIdentifierArg: String?
        get() = arguments?.getString(Key.OFFERING_IDENTIFIER.key)

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
        viewModel.paywallResultListener?.onPaywallResult(result.name)
    }

    private fun launchPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        val displayDismissButton = shouldDisplayDismissButtonArg
        val offering = offeringIdentifierArg
        val fontProvider = fontFamily?.let { CustomParcelizableFontProvider(it) }

        val paywallDisplayCallback = object : PaywallDisplayCallback {
            override fun onPaywallDisplayResult(wasDisplayed: Boolean) {
                if (!wasDisplayed) {
                    viewModel.paywallResultListener?.onPaywallResult(notPresentedPaywallResult)
                }
            }
        }

        if (displayDismissButton != null && offering != null) {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                shouldDisplayDismissButton = displayDismissButton,
                offeringIdentifier = offering,
                paywallDisplayCallback = paywallDisplayCallback,
                fontProvider = fontProvider,
            )
        } else if (displayDismissButton != null) {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                shouldDisplayDismissButton = displayDismissButton,
                paywallDisplayCallback = paywallDisplayCallback,
                fontProvider = fontProvider,
            )
        } else if (offering != null) {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                offeringIdentifier = offering,
                paywallDisplayCallback = paywallDisplayCallback,
                fontProvider = fontProvider,
            )
        } else {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                paywallDisplayCallback = paywallDisplayCallback,
                fontProvider = fontProvider,
            )
        }
    }

    private fun launchPaywall() {
        val offering = offeringIdentifierArg
        val displayDismissButton = shouldDisplayDismissButtonArg
        val fontProvider = fontFamily?.let { CustomParcelizableFontProvider(it) }

        if (displayDismissButton != null && offering != null) {
            launcher.launch(
                shouldDisplayDismissButton = displayDismissButton,
                offeringIdentifier = offering,
                fontProvider = fontProvider,
            )
        } else if (displayDismissButton != null) {
            launcher.launch(
                shouldDisplayDismissButton = displayDismissButton,
                fontProvider = fontProvider,
            )
        } else if (offering != null) {
            launcher.launch(
                offeringIdentifier = offering,
                fontProvider = fontProvider,
            )
        } else {
            launcher.launch(fontProvider = fontProvider)
        }
    }
}
