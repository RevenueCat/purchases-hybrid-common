package com.revenuecat.purchases.hybridcommon

import androidx.fragment.app.FragmentActivity

@JvmOverloads
fun presentPaywallFromFragment(
    fragment: FragmentActivity,
    requiredEntitlementIdentifier: String? = null,
    paywallResultListener: PaywallResultListener? = null,
) {
    fragment
        .supportFragmentManager
        .beginTransaction()
        .add(
            PaywallFragment.newInstance(
                fragment,
                requiredEntitlementIdentifier,
                paywallResultListener,
            ),
            PaywallFragment.tag,
        )
        .commit()
}
