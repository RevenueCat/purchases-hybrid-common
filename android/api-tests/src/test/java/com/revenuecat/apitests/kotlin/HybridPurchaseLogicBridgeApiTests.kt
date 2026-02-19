package com.revenuecat.apitests.kotlin

import com.revenuecat.purchases.hybridcommon.ui.HybridPurchaseLogicBridge
import com.revenuecat.purchases.ui.revenuecatui.PurchaseLogic

@Suppress("unused", "UNUSED_VARIABLE", "EmptyFunctionBlock")
private class HybridPurchaseLogicBridgeApiTests {

    fun checkConstants() {
        val requestIdKey: String = HybridPurchaseLogicBridge.EVENT_KEY_REQUEST_ID
        val packageKey: String = HybridPurchaseLogicBridge.EVENT_KEY_PACKAGE_BEING_PURCHASED

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
