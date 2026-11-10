package com.revenuecat.apitests.kotlin

import com.revenuecat.purchases.hybridcommon.ErrorContainer
import com.revenuecat.purchases.hybridcommon.OnResult
import com.revenuecat.purchases.hybridcommon.getCurrentAccessToken
import com.revenuecat.purchases.hybridcommon.logInWithIdentity
import com.revenuecat.purchases.hybridcommon.removeAuthenticationListener
import com.revenuecat.purchases.hybridcommon.setAuthenticationListener

@Suppress("unused", "UNUSED_VARIABLE")
private class AuthenticationApiTests {

    fun checkLogInWithIdentity(identity: Map<String, Any?>, onResult: OnResult) {
        logInWithIdentity(identity, onResult)
    }

    fun checkGetCurrentAccessToken() {
        val token: String? = getCurrentAccessToken()
    }

    fun checkSetAuthenticationListener() {
        setAuthenticationListener(
            onError = { error: ErrorContainer -> },
            onAccessTokenUpdated = { token: String? -> },
        )
        removeAuthenticationListener()
    }
}
