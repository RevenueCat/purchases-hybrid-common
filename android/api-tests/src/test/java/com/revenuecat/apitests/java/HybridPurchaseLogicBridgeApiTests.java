package com.revenuecat.apitests.java;

import com.revenuecat.purchases.hybridcommon.ui.HybridPurchaseLogicBridge;
import com.revenuecat.purchases.ui.revenuecatui.PurchaseLogic;

import kotlin.Unit;

@SuppressWarnings({"unused"})
class HybridPurchaseLogicBridgeApiTests {

    private void checkConstants() {
        String requestIdKey = HybridPurchaseLogicBridge.EVENT_KEY_REQUEST_ID;
        String packageKey = HybridPurchaseLogicBridge.EVENT_KEY_PACKAGE_BEING_PURCHASED;

        String success = HybridPurchaseLogicBridge.RESULT_SUCCESS;
        String cancellation = HybridPurchaseLogicBridge.RESULT_CANCELLATION;
        String error = HybridPurchaseLogicBridge.RESULT_ERROR;
    }

    private void checkConstructor() {
        HybridPurchaseLogicBridge bridge = new HybridPurchaseLogicBridge(
                eventData -> { return Unit.INSTANCE; },
                eventData -> { return Unit.INSTANCE; }
        );

        HybridPurchaseLogicBridge bridgeWithNulls = new HybridPurchaseLogicBridge(null, null);
    }

    private void checkImplementsPurchaseLogic() {
        HybridPurchaseLogicBridge bridge = new HybridPurchaseLogicBridge(null, null);
        PurchaseLogic purchaseLogic = bridge;
    }

    private void checkResolveResult() {
        HybridPurchaseLogicBridge.resolveResult("requestId", HybridPurchaseLogicBridge.RESULT_SUCCESS, null);
        HybridPurchaseLogicBridge.resolveResult("requestId", HybridPurchaseLogicBridge.RESULT_ERROR, "error message");
    }

    private void checkCancelPending() {
        HybridPurchaseLogicBridge bridge = new HybridPurchaseLogicBridge(null, null);
        bridge.cancelPending();
    }
}
