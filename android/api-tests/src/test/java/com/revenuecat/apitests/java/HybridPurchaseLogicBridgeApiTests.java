package com.revenuecat.apitests.java;

import android.app.Activity;
import com.revenuecat.purchases.Package;
import com.revenuecat.purchases.hybridcommon.ui.HybridPurchaseLogicBridge;
import com.revenuecat.purchases.ui.revenuecatui.PaywallPurchaseLogic;
import com.revenuecat.purchases.ui.revenuecatui.PaywallPurchaseLogicParams;
import com.revenuecat.purchases.ui.revenuecatui.PurchaseLogic;
import com.revenuecat.purchases.ui.revenuecatui.PurchaseLogicResult;

import kotlin.Unit;
import kotlin.coroutines.Continuation;

@SuppressWarnings({"unused"})
class HybridPurchaseLogicBridgeApiTests {

    private void checkConstants() {
        String requestIdKey = HybridPurchaseLogicBridge.EVENT_KEY_REQUEST_ID;
        String packageKey = HybridPurchaseLogicBridge.EVENT_KEY_PACKAGE_BEING_PURCHASED;
        String subscriptionOptionKey = HybridPurchaseLogicBridge.EVENT_KEY_SUBSCRIPTION_OPTION;
        String oldProductIdKey = HybridPurchaseLogicBridge.EVENT_KEY_OLD_PRODUCT_ID;
        String replacementModeKey = HybridPurchaseLogicBridge.EVENT_KEY_STORE_REPLACEMENT_MODE;

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
        PaywallPurchaseLogic paywallPurchaseLogic = bridge;
    }

    private void checkPurchaseOverloads(Activity activity, Package rcPackage, PaywallPurchaseLogicParams params,
                                        Continuation<? super PurchaseLogicResult> continuation) {
        HybridPurchaseLogicBridge bridge = new HybridPurchaseLogicBridge(null, null);
        bridge.performPurchase(activity, rcPackage, continuation);
        bridge.performPurchase(activity, params, continuation);
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
