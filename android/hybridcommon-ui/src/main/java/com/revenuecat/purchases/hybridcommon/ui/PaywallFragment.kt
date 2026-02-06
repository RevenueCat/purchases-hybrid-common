package com.revenuecat.purchases.hybridcommon.ui

import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import androidx.fragment.app.setFragmentResult
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.ui.revenuecatui.CustomVariableValue
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallActivityLauncher
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallDisplayCallback
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResultHandler
import com.revenuecat.purchases.ui.revenuecatui.fonts.CustomParcelizableFontProvider
import com.revenuecat.purchases.ui.revenuecatui.fonts.PaywallFontFamily

@OptIn(InternalRevenueCatAPI::class)
internal class PaywallFragment : Fragment(), PaywallResultHandler {
    enum class ResultKey(val key: String) {
        PAYWALL_RESULT("paywall_result"),
    }

    companion object {
        enum class OptionKey(val key: String) {
            REQUEST_KEY("requestKey"),
            REQUIRED_ENTITLEMENT_IDENTIFIER("requiredEntitlementIdentifier"),
            SHOULD_DISPLAY_DISMISS_BUTTON("shouldDisplayDismissButton"),
            OFFERING_IDENTIFIER("offeringIdentifier"),
            PRESENTED_OFFERING_CONTEXT("presentedOfferingContext"),
            FONT_FAMILY("fontProvider"),
            CUSTOM_VARIABLES("customVariables"),
        }

        private const val notPresentedPaywallResult = "NOT_PRESENTED"
        const val tag: String = "revenuecat-paywall-fragment"

        @Suppress("LongParameterList", "NestedBlockDepth")
        @JvmStatic
        fun newInstance(
            requestKey: String,
            requiredEntitlementIdentifier: String? = null,
            shouldDisplayDismissButton: Boolean? = null,
            paywallSource: PaywallSource,
            fontFamily: PaywallFontFamily? = null,
            customVariables: Map<String, Any?>? = null,
        ): PaywallFragment {
            return PaywallFragment().apply {
                arguments = Bundle().apply {
                    putString(OptionKey.REQUEST_KEY.key, requestKey)
                    putString(OptionKey.REQUIRED_ENTITLEMENT_IDENTIFIER.key, requiredEntitlementIdentifier)
                    shouldDisplayDismissButton?.let { putBoolean(OptionKey.SHOULD_DISPLAY_DISMISS_BUTTON.key, it) }
                    @Suppress("DEPRECATION")
                    when (paywallSource) {
                        is PaywallSource.Offering -> {
                            putString(
                                OptionKey.OFFERING_IDENTIFIER.key,
                                paywallSource.value.identifier,
                            )
                            paywallSource.presentedOfferingContext?.let {
                                putParcelable(
                                    OptionKey.PRESENTED_OFFERING_CONTEXT.key,
                                    it,
                                )
                            }
                        }

                        is PaywallSource.OfferingIdentifier -> putString(
                            OptionKey.OFFERING_IDENTIFIER.key,
                            paywallSource.value,
                        )

                        is PaywallSource.OfferingIdentifierWithPresentedOfferingContext -> {
                            putString(OptionKey.OFFERING_IDENTIFIER.key, paywallSource.offeringIdentifier)
                            putParcelable(
                                OptionKey.PRESENTED_OFFERING_CONTEXT.key,
                                paywallSource.presentedOfferingContext,
                            )
                        }

                        is PaywallSource.DefaultOffering -> Unit
                    }
                    fontFamily?.let { putParcelable(OptionKey.FONT_FAMILY.key, it) }
                    customVariables?.let { putSerializable(OptionKey.CUSTOM_VARIABLES.key, HashMap(it)) }
                }
            }
        }
    }

    private lateinit var launcher: PaywallActivityLauncher

    private val requestKey: String
        get() = arguments?.getString(OptionKey.REQUEST_KEY.key) ?: error("requestKey argument not provided")

    private val requiredEntitlementIdentifier: String?
        get() = arguments?.getString(OptionKey.REQUIRED_ENTITLEMENT_IDENTIFIER.key)

    private val presentedOfferingContextArg: PresentedOfferingContext?
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arguments?.getParcelable(
                OptionKey.PRESENTED_OFFERING_CONTEXT.key,
                PresentedOfferingContext::class.java,
            )
        } else {
            @Suppress("DEPRECATION")
            arguments?.getParcelable(OptionKey.PRESENTED_OFFERING_CONTEXT.key)
        }

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

    private val customVariablesArg: Map<String, Any?>?
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            @Suppress("UNCHECKED_CAST")
            arguments?.getSerializable(OptionKey.CUSTOM_VARIABLES.key, HashMap::class.java) as? Map<String, Any?>
        } else {
            @Suppress("DEPRECATION", "UNCHECKED_CAST")
            arguments?.getSerializable(OptionKey.CUSTOM_VARIABLES.key) as? Map<String, Any?>
        }

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

        requiredEntitlementIdentifier?.let { requiredEntitlementIdentifier ->
            launchPaywallIfNeeded(requiredEntitlementIdentifier)
        } ?: launchPaywall()
    }

    override fun onActivityResult(result: PaywallResult) {
        setFragmentResult(result)
        removeFragment()
    }

    private fun removeFragment() {
        parentFragmentManager.beginTransaction().remove(this).commit()
    }

    private fun convertToCustomVariableValues(
        customVariables: Map<String, Any?>?,
    ): Map<String, CustomVariableValue>? {
        // Currently only String values are supported. Other types will be supported in a future release.
        return customVariables
            ?.mapNotNull { (key, value) ->
                when (value) {
                    is String -> key to CustomVariableValue.String(value)
                    null -> null
                    else -> {
                        Log.w(
                            "Purchases",
                            "Custom variable '$key' has unsupported type ${value::class.simpleName}. " +
                                "Only String values are currently supported. This variable will be ignored.",
                        )
                        null
                    }
                }
            }
            ?.toMap()
            ?.takeIf { it.isNotEmpty() }
    }

    private fun launchPaywallIfNeeded(requiredEntitlementIdentifier: String) {
        val displayDismissButton = shouldDisplayDismissButtonArg
        val offering = offeringIdentifierArg
        val presentedOfferingContext = presentedOfferingContextArg ?: offering?.let { PresentedOfferingContext(it) }
        val fontProvider = fontFamily?.let { CustomParcelizableFontProvider(it) }

        val paywallDisplayCallback = object : PaywallDisplayCallback {
            override fun onPaywallDisplayResult(wasDisplayed: Boolean) {
                if (!wasDisplayed) {
                    setFragmentResult(notPresentedPaywallResult)
                    removeFragment()
                }
            }
        }

        if (displayDismissButton != null && offering != null && presentedOfferingContext != null) {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                shouldDisplayDismissButton = displayDismissButton,
                offeringIdentifier = offering,
                presentedOfferingContext = presentedOfferingContext,
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
        } else if (offering != null && presentedOfferingContext != null) {
            launcher.launchIfNeeded(
                requiredEntitlementIdentifier = requiredEntitlementIdentifier,
                offeringIdentifier = offering,
                presentedOfferingContext = presentedOfferingContext,
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
        val presentedOfferingContext = presentedOfferingContextArg ?: offering?.let { PresentedOfferingContext(it) }
        val displayDismissButton = shouldDisplayDismissButtonArg
        val fontProvider = fontFamily?.let { CustomParcelizableFontProvider(it) }
        val customVariables = convertToCustomVariableValues(customVariablesArg) ?: emptyMap()

        if (displayDismissButton != null && offering != null && presentedOfferingContext != null) {
            launcher.launch(
                shouldDisplayDismissButton = displayDismissButton,
                offeringIdentifier = offering,
                presentedOfferingContext = presentedOfferingContext,
                fontProvider = fontProvider,
            )
        } else if (displayDismissButton != null) {
            launcher.launch(
                shouldDisplayDismissButton = displayDismissButton,
                fontProvider = fontProvider,
                customVariables = customVariables,
            )
        } else if (offering != null && presentedOfferingContext != null) {
            launcher.launch(
                offeringIdentifier = offering,
                presentedOfferingContext = presentedOfferingContext,
                fontProvider = fontProvider,
            )
        } else {
            launcher.launch(fontProvider = fontProvider, customVariables = customVariables)
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
