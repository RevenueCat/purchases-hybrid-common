package apitests.java;

import android.app.Activity;
import android.content.Context;

import com.revenuecat.purchases.DangerousSettings;
import com.revenuecat.purchases.LogHandler;
import com.revenuecat.purchases.Store;
import com.revenuecat.purchases.common.PlatformInfo;
import com.revenuecat.purchases.hybridcommon.CommonKt;
import com.revenuecat.purchases.hybridcommon.ErrorContainer;
import com.revenuecat.purchases.hybridcommon.OnResult;
import com.revenuecat.purchases.hybridcommon.OnResultAny;
import com.revenuecat.purchases.hybridcommon.OnResultList;

import java.util.List;
import java.util.Map;

@SuppressWarnings({"unused", "deprecation"})
class CommonApiTests {
    private void checkCheckSetAllowSharingAppStoreAccount(Boolean enabled) {
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
                              String oldSku,
                              Integer prorationMode,
                              String type,
                              OnResult onResult) {
        CommonKt.purchaseProduct(
                activity,
                productIdentifier,
                oldSku,
                prorationMode,
                type,
                onResult
        );
    }

    private void checkPurchasePackage(Activity activity,
                              String packageIdentifier,
                              String offeringIdentifier,
                              String oldSku,
                              Integer prorationMode,
                              OnResult onResult) {
        CommonKt.purchasePackage(
                activity,
                packageIdentifier,
                offeringIdentifier,
                oldSku,
                prorationMode,
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

    private void checkSetDebugLogsEnabled(Boolean enabled) {
        CommonKt.setDebugLogsEnabled(enabled);
    }

    private void checkSetLogHandler(LogHandler logHandler) {
        CommonKt.setLogHandler(logHandler);
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
        Boolean isAnonymous = CommonKt.isAnonymous();
    }

    private void checkSetFinishTransactions(Boolean enabled) {
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
