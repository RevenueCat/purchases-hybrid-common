package apitests.java;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.revenuecat.purchases.DangerousSettings;
import com.revenuecat.purchases.Store;
import com.revenuecat.purchases.common.PlatformInfo;
import com.revenuecat.purchases.hybridcommon.CommonKt;
import com.revenuecat.purchases.hybridcommon.ErrorContainer;
import com.revenuecat.purchases.hybridcommon.OnResult;
import com.revenuecat.purchases.hybridcommon.OnResultAny;
import com.revenuecat.purchases.hybridcommon.OnResultList;
import com.revenuecat.purchases.models.GoogleProrationMode;

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
                                      Integer googleProrationMode,
                                      Boolean googleIsPersonalizedPrice,
                                      OnResult onResult) {
        CommonKt.purchaseProduct(
                activity,
                productIdentifier,
                type,
                googleBasePlanId,
                googleOldProductId,
                googleProrationMode,
                googleIsPersonalizedPrice,
                onResult
        );
    }

    private void checkPurchasePackage(Activity activity,
                                      String packageIdentifier,
                                      String offeringIdentifier,
                                      String googleOldProductId,
                                      Integer googleProrationMode,
                                      Boolean googleIsPersonalizedPrice,
                                      OnResult onResult) {
        CommonKt.purchasePackage(
                activity,
                packageIdentifier,
                offeringIdentifier,
                googleOldProductId,
                googleProrationMode,
                googleIsPersonalizedPrice,
                onResult
        );
    }

    private void checkPurchaseSubscriptionOption(Activity activity,
                                                 String productIdentifier,
                                                 String optionIdentifier,
                                                 String googleOldProductId,
                                                 Integer googleProrationMode,
                                                 Boolean googleIsPersonalizedPrice,
                                                 OnResult onResult) {
        CommonKt.purchaseSubscriptionOption(
                activity,
                productIdentifier,
                optionIdentifier,
                googleOldProductId,
                googleProrationMode,
                googleIsPersonalizedPrice,
                onResult
        );
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

    private void checkSetFinishTransactions(boolean enabled) {
        CommonKt.setFinishTransactions(enabled);
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

    private void checkConfigure(Context context,
                                String apiKey,
                                String appUserId,
                                Boolean observerMode,
                                PlatformInfo platformInfo,
                                Store store,
                                DangerousSettings dangerousSettings) {
        CommonKt.configure(context, apiKey, appUserId, observerMode, platformInfo);
        CommonKt.configure(context, apiKey, appUserId, observerMode, platformInfo, store);
        CommonKt.configure(context, apiKey, appUserId, observerMode, platformInfo, store, dangerousSettings);
    }

    private void checkGetPromotionalOffer() {
        ErrorContainer errorContainer = CommonKt.getPromotionalOffer();
    }

    private void checkErrorContainer(Integer code, String message, Map<String, Object> info) {
        ErrorContainer errorContainer = new ErrorContainer(code, message, info);
        Integer storedCode = errorContainer.getCode();
        String storedMessage = errorContainer.getMessage();
        Map<String, Object> storedAny = errorContainer.getInfo();
    }
}
