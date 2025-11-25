package com.revenuecat.apitests.java;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.revenuecat.purchases.DangerousSettings;
import com.revenuecat.purchases.PurchasesAreCompletedBy;
import com.revenuecat.purchases.Store;
import com.revenuecat.purchases.common.PlatformInfo;
import com.revenuecat.purchases.hybridcommon.CommonKt;
import com.revenuecat.purchases.hybridcommon.ErrorContainer;
import com.revenuecat.purchases.hybridcommon.OnResult;
import com.revenuecat.purchases.hybridcommon.OnResultAny;
import com.revenuecat.purchases.hybridcommon.OnResultList;
import com.revenuecat.purchases.models.InAppMessageType;

import java.util.List;
import java.util.Map;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

@SuppressWarnings({"unused", "deprecation"})
class CommonApiTests {
    private void checkCheckSetAllowSharingAppStoreAccount(boolean enabled) {
        CommonKt.setAllowSharingAppStoreAccount(enabled);
    }

    private void checkGetOfferings(OnResult onResult) {
        CommonKt.getOfferings(onResult);
    }

    private void checkGetProductInfo(List<String> productIDs,
                                     String type,
                                     OnResultList onResult) {
        CommonKt.getProductInfo(productIDs, type, onResult);
    }

    private void checkPurchaseProduct(Activity activity,
                                      String productIdentifier,
                                      String type,
                                      String googleBasePlanId,
                                      String googleOldProductId,
                                      Integer googleReplacementMode,
                                      Boolean googleIsPersonalizedPrice,
                                      Map<String, Object> presentedOfferingContext,
                                      OnResult onResult,
                                      List<Map<String, Object>> addOnStoreProducts,
                                      List<Map<String, Object>> addOnSubscriptionOptions,
                                      List<Map<String, Object>> addOnPackages) {
        CommonKt.purchaseProduct(
                activity,
                productIdentifier,
                type,
                googleBasePlanId,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                presentedOfferingContext,
                onResult
        );

        CommonKt.purchaseProduct(
                activity,
                productIdentifier,
                type,
                googleBasePlanId,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                presentedOfferingContext,
                onResult,
                addOnStoreProducts
        );

        CommonKt.purchaseProduct(
                activity,
                productIdentifier,
                type,
                googleBasePlanId,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                presentedOfferingContext,
                onResult,
                addOnStoreProducts,
                addOnSubscriptionOptions
        );

        CommonKt.purchaseProduct(
                activity,
                productIdentifier,
                type,
                googleBasePlanId,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                presentedOfferingContext,
                onResult,
                addOnStoreProducts,
                addOnSubscriptionOptions,
                addOnPackages
        );
    }

    private void checkPurchasePackage(Activity activity,
                                      String packageIdentifier,
                                      Map<String, Object> presentedOfferingContext,
                                      String googleOldProductId,
                                      Integer googleReplacementMode,
                                      Boolean googleIsPersonalizedPrice,
                                      OnResult onResult,
                                      List<Map<String, Object>> addOnStoreProducts,
                                      List<Map<String, Object>> addOnSubscriptionOptions,
                                      List<Map<String, Object>> addOnPackages) {
        CommonKt.purchasePackage(
                activity,
                packageIdentifier,
                presentedOfferingContext,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                onResult
        );

        CommonKt.purchasePackage(
                activity,
                packageIdentifier,
                presentedOfferingContext,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                onResult,
                addOnStoreProducts
        );

        CommonKt.purchasePackage(
                activity,
                packageIdentifier,
                presentedOfferingContext,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                onResult,
                addOnStoreProducts,
                addOnSubscriptionOptions
        );

        CommonKt.purchasePackage(
                activity,
                packageIdentifier,
                presentedOfferingContext,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                onResult,
                addOnStoreProducts,
                addOnSubscriptionOptions,
                addOnPackages
        );
    }

    private void checkPurchaseSubscriptionOption(Activity activity,
                                                 String productIdentifier,
                                                 String optionIdentifier,
                                                 String googleOldProductId,
                                                 Integer googleReplacementMode,
                                                 Boolean googleIsPersonalizedPrice,
                                                 Map<String, Object> presentedOfferingContext,
                                                 OnResult onResult,
                                                 List<Map<String, Object>> addOnStoreProducts,
                                                 List<Map<String, Object>> addOnSubscriptionOptions,
                                                 List<Map<String, Object>> addOnPackages) {
        CommonKt.purchaseSubscriptionOption(
                activity,
                productIdentifier,
                optionIdentifier,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                presentedOfferingContext,
                onResult
        );

        CommonKt.purchaseSubscriptionOption(
                activity,
                productIdentifier,
                optionIdentifier,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                presentedOfferingContext,
                onResult,
                addOnStoreProducts
        );

        CommonKt.purchaseSubscriptionOption(
                activity,
                productIdentifier,
                optionIdentifier,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                presentedOfferingContext,
                onResult,
                addOnStoreProducts,
                addOnSubscriptionOptions
        );

        CommonKt.purchaseSubscriptionOption(
                activity,
                productIdentifier,
                optionIdentifier,
                googleOldProductId,
                googleReplacementMode,
                googleIsPersonalizedPrice,
                presentedOfferingContext,
                onResult,
                addOnStoreProducts,
                addOnSubscriptionOptions,
                addOnPackages
        );
    }

    private void checkGetStorefront() {
        CommonKt.getStorefront(new Function1<Map<String, ? extends Object>, Unit>() {
            @Override
            public Unit invoke(Map<String, ?> stringMap) {
                return null;
            }
        });
        CommonKt.getStorefront(stringMap -> null);
    }

    private void checkGetAppUserId() {
        String appUserId = CommonKt.getAppUserID();
    }

    private void checkRestorePurchases(OnResult onResult) {
        CommonKt.restorePurchases(onResult);
    }

    private void checkLogIn(String appUserId, OnResult onResult) {
        CommonKt.logIn(appUserId, onResult);
    }

    private void checkLogOut(OnResult onResult) {
        CommonKt.logOut(onResult);
    }

    private void checkSetDebugLogsEnabled(boolean enabled) {
        CommonKt.setDebugLogsEnabled(enabled);
    }

    private void checkSetLogLevel(String level) {
        CommonKt.setLogLevel(level);
    }

    private void checkSetLogHandler(Function1<? super Map<String, String>, Unit> callback) {
        CommonKt.setLogHandler(callback);
    }

    private void checkSetLogHandlerWithOnResult() {
        CommonKt.setLogHandlerWithOnResult(new OnResult() {
            @Override
            public void onReceived(@NonNull Map<String, ?> map) {
            }

            @Override
            public void onError(@NonNull ErrorContainer errorContainer) {
            }
        });
    }

    private void checkSetProxyURLString(String proxyUrlString) {
        CommonKt.setProxyURLString(proxyUrlString);
    }

    private void checkGetProxyURLString() {
        String proxyUrlString = CommonKt.getProxyURLString();
    }

    private void checkGetCustomerInfo(OnResult onResult) {
        CommonKt.getCustomerInfo(onResult);
    }

    private void checkSyncPurchases() {
        CommonKt.syncPurchases();
    }

    private void checkIsAnonymous() {
        boolean isAnonymous = CommonKt.isAnonymous();
    }

    private void checkSetPurchasesAreCompletedBy(String purchasesAreCompletedBy) {
        CommonKt.setPurchasesAreCompletedBy(purchasesAreCompletedBy);
    }

    private void checkCheckTrialOrIntroductoryPriceEligibility(List<String> productIdentifiers) {
        Map<String, Map<String, Object>> result = CommonKt.checkTrialOrIntroductoryPriceEligibility(productIdentifiers);
    }

    private void checkInvalidateCustomerInfoCache() {
        CommonKt.invalidateCustomerInfoCache();
    }

    private void checkCanMakePayments(Context context, List<Integer> features, OnResultAny<Boolean> onResult) {
        CommonKt.canMakePayments(context, features, onResult);
    }

    private void checkShowInAppMessagesIfNeeded(Activity activity, List<InAppMessageType> types) {
        CommonKt.showInAppMessagesIfNeeded(activity);
        CommonKt.showInAppMessagesIfNeeded(activity, types);
        CommonKt.showInAppMessagesIfNeeded(activity, null);
    }

    private void checkConfigure(Context context,
                                String apiKey,
                                String appUserId,
                                String purchasesAreCompletedBy,
                                PlatformInfo platformInfo,
                                Store store,
                                DangerousSettings dangerousSettings,
                                Boolean shouldShowInAppMessagesAutomatically,
                                String verificationMode,
                                Boolean pendingTransactionsForPrepaidPlansEnabled,
                                Boolean diagnosticsEnabled
    ) {
        CommonKt.configure(context, apiKey, appUserId, purchasesAreCompletedBy, platformInfo);
        CommonKt.configure(context, apiKey, appUserId, purchasesAreCompletedBy, platformInfo, store);
        CommonKt.configure(context, apiKey, appUserId, purchasesAreCompletedBy, platformInfo, store, dangerousSettings);
        CommonKt.configure(
                context,
                apiKey,
                appUserId,
                purchasesAreCompletedBy,
                platformInfo,
                store,
                dangerousSettings,
                shouldShowInAppMessagesAutomatically);
        CommonKt.configure(
                context,
                apiKey,
                appUserId,
                purchasesAreCompletedBy,
                platformInfo,
                store,
                dangerousSettings,
                shouldShowInAppMessagesAutomatically,
                verificationMode,
                pendingTransactionsForPrepaidPlansEnabled,
                diagnosticsEnabled);
    }

    private void checkGetPromotionalOffer() {
        ErrorContainer errorContainer = CommonKt.getPromotionalOffer();
    }

    private void checkGetVirtualCurrencies(OnResult onResult) {
        CommonKt.getVirtualCurrencies(onResult);
    }

    private void checkInvalidateVirtualCurrenciesCache() {
        CommonKt.invalidateVirtualCurrenciesCache();
    }

    private void checkGetCachedVirtualCurrencies() {
        Map<String, Object> cachedVirtualCurrencies = CommonKt.getCachedVirtualCurrencies();
    }

    private void checkErrorContainer(Integer code, String message, Map<String, Object> info) {
        ErrorContainer errorContainer = new ErrorContainer(code, message, info);
        Integer storedCode = errorContainer.getCode();
        String storedMessage = errorContainer.getMessage();
        Map<String, Object> storedAny = errorContainer.getInfo();
    }

    private void checkOverridePreferredLocale(String locale) {
        CommonKt.overridePreferredLocale(locale);
    }
}
