package com.revenuecat.purchases.hybridcommon.ui

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering

@JvmOverloads
fun presentPaywallFromFragment(
    fragment: FragmentActivity,
    requiredEntitlementIdentifier: String? = null,
    paywallResultListener: PaywallResultListener? = null,
    shouldDisplayDismissButton: Boolean? = null,
    offering: Offering? = null,
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
                offering,
            ),
            PaywallFragment.tag,
        )
        .commit()
}
