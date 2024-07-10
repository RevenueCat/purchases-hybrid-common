package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.Offering as PurchasesOffering

sealed class PaywallSource {
    class Offering(val value: PurchasesOffering) : PaywallSource()
    object DefaultOffering : PaywallSource()
    class OfferingIdentifier(val value: String) : PaywallSource()
}
