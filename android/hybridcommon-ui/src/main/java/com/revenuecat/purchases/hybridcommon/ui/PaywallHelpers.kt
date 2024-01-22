package com.revenuecat.purchases.hybridcommon.ui

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering

@JvmOverloads
@Deprecated(
    message = "Use presentPaywallFromFragment with Options instead",
    replaceWith = ReplaceWith(
        expression = "presentPaywallFromFragment(fragment, options)",
        imports = ["com.revenuecat.purchases.hybridcommon.ui.presentPaywallFromFragment"]
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
            offering = offering,
        )
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
                if (offeringIdentifier != null) {
                    PaywallFragment.newInstance(
                        fragment,
                        requiredEntitlementIdentifier,
                        paywallResultListener,
                        shouldDisplayDismissButton,
                        offeringIdentifier,
                    )
                } else {
                    PaywallFragment.newInstance(
                        fragment,
                        requiredEntitlementIdentifier,
                        paywallResultListener,
                        shouldDisplayDismissButton,
                        offering,
                    )
                },
                PaywallFragment.tag,
            )
            .commit()
    }
}

data class PresentPaywallOptions(
    val requiredEntitlementIdentifier: String? = null,
    val paywallResultListener: PaywallResultListener? = null,
    val shouldDisplayDismissButton: Boolean? = null,
    val offering: Offering? = null,
    val offeringIdentifier: String? = null,
)