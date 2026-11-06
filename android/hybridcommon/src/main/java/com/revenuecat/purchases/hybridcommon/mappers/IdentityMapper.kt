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
    val token = (this[IdentityKeys.TOKEN] as? String)?.takeIf { it.isNotEmpty() }
    return when {
        sourceValue == null ->
            failure(PurchasesErrorCode.UnsupportedError, "Identity is missing a '${IdentityKeys.SOURCE}'.")
        token == null ->
            failure(PurchasesErrorCode.InvalidCredentialsError, "Identity is missing a '${IdentityKeys.TOKEN}'.")
        else ->
            identity(sourceValue, token.toByteArray(Charsets.UTF_8), this[IdentityKeys.EMAIL] as? String)
                ?.let { IdentityMappingResult.Success(it) }
                ?: failure(PurchasesErrorCode.UnsupportedError, "Unsupported identity source '$sourceValue'.")
    }
}

private fun identity(sourceValue: String, token: ByteArray, email: String?): Identity? =
    when (IdentitySource.values().firstOrNull { it.rawValue == sourceValue }) {
        IdentitySource.SIGN_IN_WITH_APPLE -> Identity.signInWithApple(token)
        IdentitySource.OIDC -> Identity.oidc(token)
        IdentitySource.GOOGLE -> Identity.google(token)
        IdentitySource.FIREBASE -> Identity.firebase(token)
        IdentitySource.FACEBOOK -> Identity.facebook(token, email)
        // The SDK creates anonymous identities itself.
        IdentitySource.ANONYMOUS, null -> null
    }

private fun failure(code: PurchasesErrorCode, message: String): IdentityMappingResult =
    IdentityMappingResult.Failure(PurchasesError(code, message).map())
