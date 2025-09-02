package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.models.StoreTransaction
import com.revenuecat.purchases.ui.revenuecatui.PaywallListener

@OptIn(InternalRevenueCatAPI::class)
abstract class PaywallListenerWrapper : PaywallListener {

    override fun onPurchaseStarted(rcPackage: Package) {
        this.onPurchaseStarted(rcPackage.map())
    }

    override fun onPurchaseCompleted(customerInfo: CustomerInfo, storeTransaction: StoreTransaction) {
        this.onPurchaseCompleted(
            customerInfo = customerInfo.map(),
            storeTransaction = storeTransaction.map(),
        )
    }

    override fun onPurchaseError(error: PurchasesError) {
        this.onPurchaseError(error = error.map().info)
    }

    override fun onRestoreCompleted(customerInfo: CustomerInfo) {
        this.onRestoreCompleted(customerInfo.map())
    }

    override fun onRestoreError(error: PurchasesError) {
        this.onRestoreError(error = error.map().info)
    }

    abstract fun onPurchaseStarted(rcPackage: Map<String, Any?>)
    abstract fun onPurchaseCompleted(customerInfo: Map<String, Any?>, storeTransaction: Map<String, Any?>)
    abstract fun onPurchaseError(error: Map<String, Any?>)
    abstract fun onRestoreCompleted(customerInfo: Map<String, Any?>)
    abstract fun onRestoreError(error: Map<String, Any?>)
}
