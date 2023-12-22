package com.revenuecat.purchases.hybridcommon.ui

import androidx.fragment.app.FragmentActivity

@JvmOverloads
fun presentPaywallFromFragment(
    fragment: FragmentActivity,
    requiredEntitlementIdentifier: String? = null,
    paywallResultListener: PaywallResultListener? = null,
    shouldDisplayDismissButton: Boolean? = null,
) {
    fragment
        .supportFragmentManager
        .beginTransaction()
        .add(
            PaywallFragment.newInstance(
                fragment,
                requiredEntitlementIdentifier,
                paywallResultListener,
                shouldDisplayDismissButton,
            ),
            PaywallFragment.tag,
        )
        .commit()
}
