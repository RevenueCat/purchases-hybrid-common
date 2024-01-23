package com.revenuecat.purchases.hybridcommon.ui

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering

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
                ),
                PaywallFragment.tag,
            )
            .commit()
    }
}

data class PresentPaywallOptions(
    val paywallSource: PaywallSource = PaywallSource.DefaultOffering,
    val requiredEntitlementIdentifier: String? = null,
    val paywallResultListener: PaywallResultListener? = null,
    val shouldDisplayDismissButton: Boolean? = null,
)
