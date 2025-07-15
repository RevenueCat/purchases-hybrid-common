package com.revenuecat.purchases.hybridcommon.ui

import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import androidx.fragment.app.setFragmentResult
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallActivityLauncher
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallDisplayCallback
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResultHandler
import com.revenuecat.purchases.ui.revenuecatui.fonts.CustomParcelizableFontProvider
import com.revenuecat.purchases.ui.revenuecatui.fonts.PaywallFontFamily

internal class PaywallFragment : Fragment(), PaywallResultHandler {
    private var requiredEntitlementIdentifierForDismiss: String? = null
    enum class ResultKey(val key: String) {
        PAYWALL_RESULT("paywall_result"),
    }

    companion object {
        enum class OptionKey(val key: String) {
            REQUEST_KEY("requestKey"),
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
            requestKey: String,
            requiredEntitlementIdentifier: String? = null,
            shouldDisplayDismissButton: Boolean? = null,
            paywallSource: PaywallSource,
            fontFamily: PaywallFontFamily? = null,
        ): PaywallFragment {
            return PaywallFragment().apply {
                arguments = Bundle().apply {
                    putString(OptionKey.REQUEST_KEY.key, requestKey)
                    putString(OptionKey.REQUIRED_ENTITLEMENT_IDENTIFIER.key, requiredEntitlementIdentifier)
                    shouldDisplayDismissButton?.let { putBoolean(OptionKey.SHOULD_DISPLAY_DISMISS_BUTTON.key, it) }
                    when (paywallSource) {
                        is PaywallSource.Offering -> putString(
                            OptionKey.OFFERING_IDENTIFIER.key,
                            paywallSource.value.identifier,
                        )

                        is PaywallSource.OfferingIdentifier -> putString(
                            OptionKey.OFFERING_IDENTIFIER.key,
                            paywallSource.value,
                        )

                        is PaywallSource.DefaultOffering -> Unit
                    }
                    fontFamily?.let { putParcelable(OptionKey.FONT_FAMILY.key, it) }
                }
            }
        }
    }

    private lateinit var launcher: PaywallActivityLauncher

    private val requestKey: String
        get() = arguments?.getString(OptionKey.REQUEST_KEY.key) ?: error("requestKey argument not provided")

    private val requiredEntitlementIdentifier: String?
        get() = arguments?.getString(OptionKey.REQUIRED_ENTITLEMENT_IDENTIFIER.key)

    private val shouldDisplayDismissButtonArg: Boolean?
        get() {
            return arguments?.let {
                if (it.containsKey(OptionKey.SHOULD_DISPLAY_DISMISS_BUTTON.key)) {
                    it.getBoolean(OptionKey.SHOULD_DISPLAY_DISMISS_BUTTON.key)
                } else {
                    null
                }
            }
        }

    private val fontFamily: PaywallFontFamily?
        get() = arguments?.takeIf { it.containsKey(OptionKey.FONT_FAMILY.key) }?.let {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                it.getParcelable(OptionKey.FONT_FAMILY.key, PaywallFontFamily::class.java)
            } else {
                @Suppress("DEPRECATION")
                it.getParcelable(OptionKey.FONT_FAMILY.key)
            }
        }

    private val offeringIdentifierArg: String?
        get() = arguments?.getString(OptionKey.OFFERING_IDENTIFIER.key)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // This should normally never happen, but just in case, we don't want to try to present the paywall
        // if the SDK is not configured.
        if (!Purchases.isConfigured) {
            Log.e(
                "PaywallFragment",
                "Purchases is not configured. " +
                    "Make sure to call Purchases.configure() before launching the paywall. Dismissing.",
            )
            removeFragment()
            return
        }

        launcher = PaywallActivityLauncher(
            this,
            this,
        )
        
        // Store the required entitlement identifier for auto-dismiss logic
        requiredEntitlementIdentifierForDismiss = requiredEntitlementIdentifier

        requiredEntitlementIdentifier?.let { requiredEntitlementIdentifier ->
            launchPaywallIfNeeded(requiredEntitlementIdentifier)
        } ?: launchPaywall()
    }

    override fun onActivityResult(result: PaywallResult) {
        // Check if entitlement was granted and auto-dismiss if needed
        when (result) {
            is PaywallResult.Purchased -> {
                checkEntitlementAndDismissIfNeeded(result.customerInfo) {
                    setFragmentResult(result)
                    removeFragment()
                }
            }
            is PaywallResult.Restored -> {
                checkEntitlementAndDismissIfNeeded(result.customerInfo) {
                    setFragmentResult(result)
                    removeFragment()
                }
            }
            else -> {
                setFragmentResult(result)
                removeFragment()
            }
        }
    }
    
    private fun checkEntitlementAndDismissIfNeeded(customerInfo: CustomerInfo, fallback: () -> Unit) {
        val requiredEntitlement = requiredEntitlementIdentifierForDismiss
        if (requiredEntitlement != null) {
            val hasEntitlement = customerInfo.entitlements.active.containsKey(requiredEntitlement)
            if (hasEntitlement) {
                // Auto-dismiss the paywall since the required entitlement is now active
                activity?.finish()
                removeFragment()
            } else {
                // Entitlement not granted, handle normally
                fallback()
            }
        } else {
            // No required entitlement specified, handle normally
            fallback()
        }
    }

    private fun removeFragment() {
        parentFragmentManager.beginTransaction().remove(this).commit()
    }

    private fun launchPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        val displayDismissButton = shouldDisplayDismissButtonArg
        val offering = offeringIdentifierArg
        val fontProvider = fontFamily?.let { CustomParcelizableFontProvider(it) }

        val paywallDisplayCallback = object : PaywallDisplayCallback {
            override fun onPaywallDisplayResult(wasDisplayed: Boolean) {
                if (!wasDisplayed) {
                    setFragmentResult(notPresentedPaywallResult)
                    removeFragment()
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

    private fun setFragmentResult(paywallResult: PaywallResult) =
        setFragmentResult(paywallResult = paywallResult.name)

    private fun setFragmentResult(paywallResult: String) =
        setFragmentResult(
            requestKey = requestKey,
            result = Bundle().apply {
                putString(ResultKey.PAYWALL_RESULT.key, paywallResult)
            },
        )

}
