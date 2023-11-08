package com.revenuecat.purchases.hybridcommon

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity

@JvmOverloads
fun presentPaywallFromFragment(
    fragment: FragmentActivity,
    requiredEntitlementIdentifier: String? = null
) {
    fragment
        .supportFragmentManager
        .beginTransaction()
        .add(PaywallFragment(requiredEntitlementIdentifier), PaywallFragment.tag)
        .commit()
}
