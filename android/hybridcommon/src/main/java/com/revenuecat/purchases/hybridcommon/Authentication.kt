@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon

import androidx.annotation.VisibleForTesting
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.hybridcommon.mappers.IdentityMappingResult
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.hybridcommon.mappers.mapAsync
import com.revenuecat.purchases.hybridcommon.mappers.toIdentity
import com.revenuecat.purchases.identity.AuthenticationDelegate
import com.revenuecat.purchases.interfaces.ReceiveCustomerInfoCallback

// The native SDK holds its delegate weakly, so the bridge keeps it alive here.
@Volatile
@VisibleForTesting
internal var authenticationDelegate: AuthenticationDelegate? = null

/**
 * Experimental. Logs in through IAM with an identity map of `source` (`apple`, `oidc`, `google`, `firebase` or
 * `facebook`), `token` (the provider's raw ID token) and, for Facebook, an optional `email`. Requires configuring
 * with `iamEnabled`.
 *
 * [onResult] receives the new user's CustomerInfo map.
 */
fun logInWithIdentity(
    identity: Map<String, Any?>,
    onResult: OnResult,
) {
    when (val mapped = identity.toIdentity()) {
        is IdentityMappingResult.Failure -> onResult.onError(mapped.error)
        is IdentityMappingResult.Success ->
            Purchases.sharedInstance.authentication.logIn(mapped.identity, customerInfoCallback(onResult))
    }
}

/**
 * Experimental. The current user's IAM access token, or null if there isn't one.
 */
fun getCurrentAccessToken(): String? = Purchases.sharedInstance.authentication.currentAccessToken

/**
 * Experimental. Listens for authentication errors that no explicit call reports, and for access-token changes.
 * Both are called on the main thread. Replaces any previous listener.
 */
fun setAuthenticationListener(
    onError: (ErrorContainer) -> Unit,
    onAccessTokenUpdated: (String?) -> Unit,
) {
    val delegate = AuthenticationDelegateBridge(onError, onAccessTokenUpdated)
    authenticationDelegate = delegate
    Purchases.sharedInstance.authentication.delegate = delegate
}

/**
 * Experimental. Removes the listener set with [setAuthenticationListener].
 */
fun removeAuthenticationListener() {
    authenticationDelegate = null
    Purchases.sharedInstance.authentication.delegate = null
}

internal fun customerInfoCallback(onResult: OnResult) = object : ReceiveCustomerInfoCallback {
    override fun onReceived(customerInfo: CustomerInfo) {
        customerInfo.mapAsync { map -> onResult.onReceived(map) }
    }

    override fun onError(error: PurchasesError) {
        onResult.onError(error.map())
    }
}

private class AuthenticationDelegateBridge(
    private val onError: (ErrorContainer) -> Unit,
    private val onAccessTokenUpdated: (String?) -> Unit,
) : AuthenticationDelegate {

    override fun authenticatorDidEncounterError(error: PurchasesError) {
        onError(error.map())
    }

    override fun authenticatorDidUpdateAccessToken(newAccessToken: String?) {
        onAccessTokenUpdated(newAccessToken)
    }
}
