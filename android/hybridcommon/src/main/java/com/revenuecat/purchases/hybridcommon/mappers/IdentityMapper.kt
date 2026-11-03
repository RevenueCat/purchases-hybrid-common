@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.hybridcommon.ErrorContainer
import com.revenuecat.purchases.identity.Identity
import com.revenuecat.purchases.identity.IdentitySource

internal object IdentityKeys {
    const val SOURCE = "source"
    const val TOKEN = "token"
    const val EMAIL = "email"
}

internal sealed interface IdentityMappingResult {
    data class Success(val identity: Identity) : IdentityMappingResult
    data class Failure(val error: ErrorContainer) : IdentityMappingResult
}

/**
 * Builds an [Identity] from a hybrid map of `source` (an [IdentitySource] raw value), `token` (the raw ID token
 * string) and, for Facebook only, an optional `email`.
 */
internal fun Map<String, Any?>.toIdentity(): IdentityMappingResult {
    val sourceValue = this[IdentityKeys.SOURCE] as? String
        ?: return failure(PurchasesErrorCode.UnsupportedError, "Identity is missing a '${IdentityKeys.SOURCE}'.")
    val token = (this[IdentityKeys.TOKEN] as? String)?.takeIf { it.isNotEmpty() }
        ?: return failure(PurchasesErrorCode.InvalidCredentialsError, "Identity is missing a '${IdentityKeys.TOKEN}'.")
    val tokenBytes = token.toByteArray(Charsets.UTF_8)

    val identity = when (IdentitySource.values().firstOrNull { it.rawValue == sourceValue }) {
        IdentitySource.SIGN_IN_WITH_APPLE -> Identity.signInWithApple(tokenBytes)
        IdentitySource.OIDC -> Identity.oidc(tokenBytes)
        IdentitySource.GOOGLE -> Identity.google(tokenBytes)
        IdentitySource.FIREBASE -> Identity.firebase(tokenBytes)
        IdentitySource.FACEBOOK -> Identity.facebook(tokenBytes, this[IdentityKeys.EMAIL] as? String)
        // The SDK creates anonymous identities itself.
        IdentitySource.ANONYMOUS, null ->
            return failure(PurchasesErrorCode.UnsupportedError, "Unsupported identity source '$sourceValue'.")
    }
    return IdentityMappingResult.Success(identity)
}

private fun failure(code: PurchasesErrorCode, message: String): IdentityMappingResult =
    IdentityMappingResult.Failure(PurchasesError(code, message).map())
