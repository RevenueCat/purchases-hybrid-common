package com.revenuecat.apitests.java;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import com.revenuecat.purchases.Offering;
import com.revenuecat.purchases.PresentedOfferingContext;
import com.revenuecat.purchases.hybridcommon.ui.PaywallHelpersKt;
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener;
import com.revenuecat.purchases.hybridcommon.ui.PaywallSource;
import com.revenuecat.purchases.hybridcommon.ui.PresentPaywallOptions;
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

    private void checkPaywallSource(PaywallSource source) {
        if (source instanceof PaywallSource.DefaultOffering) {
            PaywallSource.DefaultOffering defaultOffering = (PaywallSource.DefaultOffering) source;
        } else if (source instanceof PaywallSource.OfferingIdentifier) {
            PaywallSource.OfferingIdentifier offeringIdentifier = (PaywallSource.OfferingIdentifier) source;
            String identifier = offeringIdentifier.getValue();
        } else if (source instanceof PaywallSource.Offering) {
            PaywallSource.Offering offering = (PaywallSource.Offering) source;
            Offering internalOffering = offering.getValue();
        } else if (source instanceof PaywallSource.OfferingIdentifierWithPresentedOfferingContext) {
            PaywallSource.OfferingIdentifierWithPresentedOfferingContext offeringWithContext
                    = (PaywallSource.OfferingIdentifierWithPresentedOfferingContext) source;
            String identifier = offeringWithContext.getOfferingIdentifier();
            PresentedOfferingContext context = offeringWithContext.getPresentedOfferingContext();
        }
    }

    private void checkPresentPaywall(
            FragmentActivity fragmentActivity,
            String requiredEntitlementIdentifier,
            PaywallResultListener listener,
            Boolean shouldDisplayDismissButton,
            Offering offering,
            PresentPaywallOptions presentPaywallOptions
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
        PaywallHelpersKt.presentPaywallFromFragment(
                fragmentActivity, presentPaywallOptions
        );
    }
}
