package com.revenuecat.purchases.hybridcommon

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity

fun presentPaywallFromFragment(fragment: FragmentActivity, requiredEntitlementIdentifier: String?) {
    fragment
        .supportFragmentManager
        .beginTransaction()
        .add(PaywallFragment(requiredEntitlementIdentifier), PaywallFragment.tag)
        .commit()
}
