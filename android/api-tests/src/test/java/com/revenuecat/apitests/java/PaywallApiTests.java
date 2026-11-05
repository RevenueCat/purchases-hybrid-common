package com.revenuecat.apitests.java;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import com.revenuecat.purchases.Offering;
import com.revenuecat.purchases.PresentedOfferingContext;
import com.revenuecat.purchases.hybridcommon.ui.CheckpointErrorCode;
import com.revenuecat.purchases.hybridcommon.ui.CheckpointHelpersKt;
import com.revenuecat.purchases.hybridcommon.ui.CheckpointListener;
import androidx.annotation.Nullable;
import com.revenuecat.purchases.hybridcommon.ui.PaywallHelpersKt;
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener;
import com.revenuecat.purchases.hybridcommon.ui.PaywallSource;
import com.revenuecat.purchases.hybridcommon.ui.PresentPaywallOptions;
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult;

import java.util.HashMap;
import java.util.Map;

@SuppressWarnings({"unused"})
class PaywallApiTests {

    private void checkCheckpoint() {
        CheckpointListener listener = new CheckpointListener() {
            @Override
            public void onCheckpointPassed(@NonNull Map<String, ?> result) {
            }

            @Override
            public void onCheckpointError(@NonNull String code, @NonNull String message) {
            }

            @Override
            public void onErrorDialogRequested(@NonNull String requestId, @NonNull Map<String, ?> error) {
                @Nullable Object kind = error.get("kind");
                @Nullable Object errorCode = error.get("code");
                @Nullable Object errorMessage = error.get("message");
                Map<String, Object> dialog = new HashMap<>();
                dialog.put("message", "err");
                dialog.put("buttonTitle", "OK");
                Map<String, Object> outcome = new HashMap<>();
                outcome.put("type", "show");
                outcome.put("dialog", dialog);
                CheckpointHelpersKt.resolveErrorDialog(requestId, outcome);
                outcome = new HashMap<>();
                outcome.put("type", "useDefault");
                CheckpointHelpersKt.resolveErrorDialog(requestId, outcome);
                outcome.put("type", "suppress");
                CheckpointHelpersKt.resolveErrorDialog(requestId, outcome);
                CheckpointHelpersKt.resolveErrorDialog(requestId, null);
            }
        };
        Map<String, Object> customVariables = new HashMap<>();
        CheckpointHelpersKt.presentCheckpoint("identifier", customVariables, "MODAL_SHEET", listener);
        CheckpointHelpersKt.presentCheckpoint("identifier", "c1", null, null, listener);
        CheckpointHelpersKt.presentCheckpoint("identifier", "c1", customVariables, "MODAL_SHEET", listener);
        String notConfigured = CheckpointErrorCode.NOT_CONFIGURED;
        CheckpointHelpersKt.cancelErrorDialogs("c1");
        CheckpointHelpersKt.cancelErrorDialogs(null);
    }

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

    private void checkPresentPaywallOptionsWithCustomVariablesAndContext(
            FragmentActivity fragmentActivity,
            PaywallResultListener listener
    ) {
        PaywallSource.OfferingIdentifierWithPresentedOfferingContext source
                = new PaywallSource.OfferingIdentifierWithPresentedOfferingContext(
                "offering",
                new PresentedOfferingContext("offering")
        );
        Map<String, Object> customVariables = new HashMap<>();
        customVariables.put("user_name", "John");
        customVariables.put("count", 42);
        customVariables.put("enabled", true);
        PresentPaywallOptions options = new PresentPaywallOptions(
                listener,
                source,
                null,
                null,
                null,
                customVariables
        );
        PaywallHelpersKt.presentPaywallFromFragment(fragmentActivity, options);
    }
}
