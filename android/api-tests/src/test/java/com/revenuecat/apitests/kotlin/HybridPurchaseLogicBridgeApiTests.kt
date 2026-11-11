package com.revenuecat.apitests.kotlin

import android.app.Activity
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.hybridcommon.ui.HybridPurchaseLogicBridge
import com.revenuecat.purchases.ui.revenuecatui.PaywallPurchaseLogic
import com.revenuecat.purchases.ui.revenuecatui.PaywallPurchaseLogicParams
import com.revenuecat.purchases.ui.revenuecatui.PurchaseLogic
import com.revenuecat.purchases.ui.revenuecatui.PurchaseLogicResult

@Suppress("unused", "UNUSED_VARIABLE", "EmptyFunctionBlock")
private class HybridPurchaseLogicBridgeApiTests {

    fun checkConstants() {
        val requestIdKey: String = HybridPurchaseLogicBridge.EVENT_KEY_REQUEST_ID
        val packageKey: String = HybridPurchaseLogicBridge.EVENT_KEY_PACKAGE_BEING_PURCHASED
        val subscriptionOptionKey: String = HybridPurchaseLogicBridge.EVENT_KEY_SUBSCRIPTION_OPTION
        val oldProductIdKey: String = HybridPurchaseLogicBridge.EVENT_KEY_OLD_PRODUCT_ID
        val replacementModeKey: String = HybridPurchaseLogicBridge.EVENT_KEY_STORE_REPLACEMENT_MODE

        val success: String = HybridPurchaseLogicBridge.RESULT_SUCCESS
        val cancellation: String = HybridPurchaseLogicBridge.RESULT_CANCELLATION
        val error: String = HybridPurchaseLogicBridge.RESULT_ERROR
    }

    fun checkConstructor() {
        val bridge = HybridPurchaseLogicBridge(
            onPerformPurchase = { eventData -> },
            onPerformRestore = { eventData -> },
        )

        val bridgeWithNulls = HybridPurchaseLogicBridge(
            onPerformPurchase = null,
            onPerformRestore = null,
        )
    }

    fun checkImplementsPurchaseLogic() {
        val bridge = HybridPurchaseLogicBridge(null, null)
        val purchaseLogic: PurchaseLogic = bridge
        val paywallPurchaseLogic: PaywallPurchaseLogic = bridge
    }

    suspend fun checkPurchaseOverloads(activity: Activity, rcPackage: Package, params: PaywallPurchaseLogicParams) {
        val bridge = HybridPurchaseLogicBridge(null, null)
        val legacyResult: PurchaseLogicResult = bridge.performPurchase(activity, rcPackage)
        val result: PurchaseLogicResult = bridge.performPurchase(activity, params)
    }

    fun checkResolveResult() {
        HybridPurchaseLogicBridge.resolveResult("requestId", HybridPurchaseLogicBridge.RESULT_SUCCESS)
        HybridPurchaseLogicBridge.resolveResult("requestId", HybridPurchaseLogicBridge.RESULT_ERROR, "error message")
    }

    fun checkCancelPending() {
        val bridge = HybridPurchaseLogicBridge(null, null)
        bridge.cancelPending()
    }
}
