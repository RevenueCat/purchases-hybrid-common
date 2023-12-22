package com.revenuecat.apitests.java;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import com.revenuecat.purchases.hybridcommon.ui.PaywallHelpersKt;
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener;
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult;

@SuppressWarnings({"unused"})
class PaywallApiTests {

    private void checkPaywallResultListener() {
        PaywallResultListener listener = new PaywallResultListener() {
            @Override
            public void onPaywallResult(@NonNull PaywallResult paywallResult) {
            }
        };
    }

    private void checkPresentPaywall(
            FragmentActivity fragmentActivity,
            String requiredEntitlementIdentifier,
            PaywallResultListener listener,
            Boolean shouldDisplayDismissButton
    ) {
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity
        );
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity, requiredEntitlementIdentifier
        );
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity, requiredEntitlementIdentifier, listener
        );
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity, requiredEntitlementIdentifier, listener, shouldDisplayDismissButton
        );
    }
}
