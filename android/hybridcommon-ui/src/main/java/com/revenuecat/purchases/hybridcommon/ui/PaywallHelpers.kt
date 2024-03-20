package com.revenuecat.purchases.hybridcommon.ui

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.fonts.PaywallFontFamily

@JvmOverloads
@Deprecated(
    message = "Use presentPaywallFromFragment with Options instead",
    replaceWith = ReplaceWith(
        expression = "presentPaywallFromFragment(fragment, options)",
        imports = ["com.revenuecat.purchases.hybridcommon.ui.presentPaywallFromFragment"],
    ),
)
fun presentPaywallFromFragment(
    fragment: FragmentActivity,
    requiredEntitlementIdentifier: String? = null,
    paywallResultListener: PaywallResultListener? = null,
    shouldDisplayDismissButton: Boolean? = null,
    offering: Offering? = null,
) {
    presentPaywallFromFragment(
        fragment,
        PresentPaywallOptions(
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            paywallResultListener = paywallResultListener,
            shouldDisplayDismissButton = shouldDisplayDismissButton,
            paywallSource = offering?.let { PaywallSource.Offering(it) } ?: PaywallSource.DefaultOffering,
        ),
    )
}

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
fun presentPaywallFromFragment(
    fragment: FragmentActivity,
    options: PresentPaywallOptions,
) {
    with(options) {
        fragment
            .supportFragmentManager
            .beginTransaction()
            .add(
                PaywallFragment.newInstance(
                    fragment,
                    requiredEntitlementIdentifier,
                    paywallResultListener,
                    shouldDisplayDismissButton,
                    paywallSource,
                    fontFamily,
                ),
                PaywallFragment.tag,
            )
            .commit()
    }
}

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
data class PresentPaywallOptions(
    val paywallSource: PaywallSource = PaywallSource.DefaultOffering,
    val requiredEntitlementIdentifier: String? = null,
    val paywallResultListener: PaywallResultListener? = null,
    val shouldDisplayDismissButton: Boolean? = null,
    val fontFamily: PaywallFontFamily? = null,
)
