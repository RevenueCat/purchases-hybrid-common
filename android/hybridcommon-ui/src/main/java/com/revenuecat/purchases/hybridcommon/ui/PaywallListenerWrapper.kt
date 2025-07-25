package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.hybridcommon.mappers.mapAsync
import com.revenuecat.purchases.models.StoreTransaction
import com.revenuecat.purchases.ui.revenuecatui.PaywallListener

abstract class PaywallListenerWrapper : PaywallListener {

    override fun onPurchaseStarted(rcPackage: Package) {
        this.onPurchaseStarted(rcPackage.map())
    }

    override fun onPurchaseCompleted(customerInfo: CustomerInfo, storeTransaction: StoreTransaction) {
        customerInfo.mapAsync { map ->
            this.onPurchaseCompleted(
                customerInfo = map,
                storeTransaction = storeTransaction.map(),
            )
        }
    }

    override fun onPurchaseError(error: PurchasesError) {
        this.onPurchaseError(error = error.map().info)
    }

    override fun onRestoreCompleted(customerInfo: CustomerInfo) {
        customerInfo.mapAsync { map -> this.onRestoreCompleted(map) }
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
