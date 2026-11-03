package com.revenuecat.apitests.java;

import com.revenuecat.purchases.hybridcommon.AuthenticationKt;
import com.revenuecat.purchases.hybridcommon.ErrorContainer;
import com.revenuecat.purchases.hybridcommon.OnResult;

import java.util.Map;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

@SuppressWarnings({"unused"})
class AuthenticationApiTests {

    private void checkLogInWithIdentity(Map<String, Object> identity, OnResult onResult) {
        AuthenticationKt.logInWithIdentity(identity, onResult);
    }

    private void checkGetCurrentAccessToken() {
        String token = AuthenticationKt.getCurrentAccessToken();
    }

    private void checkSetAuthenticationListener(
            Function1<? super ErrorContainer, Unit> onError,
            Function1<? super String, Unit> onAccessTokenUpdated
    ) {
        AuthenticationKt.setAuthenticationListener(onError, onAccessTokenUpdated);
        AuthenticationKt.removeAuthenticationListener();
    }
}
