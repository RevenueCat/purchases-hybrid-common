package com.revenuecat.apitests.java;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import com.revenuecat.purchases.Offering;
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

            @Override
            public void onPaywallResult(@NonNull String paywallResult) {
            }
        };
    }

    private void checkPresentPaywall(
            FragmentActivity fragmentActivity,
            String requiredEntitlementIdentifier,
            PaywallResultListener listener,
            Boolean shouldDisplayDismissButton,
            Offering offering
    ) {
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity, listener
        );
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity, listener, requiredEntitlementIdentifier
        );
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity, listener, requiredEntitlementIdentifier, shouldDisplayDismissButton
        );
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity, listener, requiredEntitlementIdentifier, shouldDisplayDismissButton, offering
        );
    }
}
