@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.identity.Identity
import com.revenuecat.purchases.identity.IdentitySource
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

internal class IdentityMapperTests {

    private val token = "header.payload.signature"
    private val tokenBytes = token.toByteArray(Charsets.UTF_8)

    @Test
    fun `maps apple identity`() {
        assertMaps(mapOf("source" to "apple", "token" to token), Identity.signInWithApple(tokenBytes))
    }

    @Test
    fun `maps oidc identity`() {
        assertMaps(mapOf("source" to "oidc", "token" to token), Identity.oidc(tokenBytes))
    }

    @Test
    fun `maps google identity`() {
        assertMaps(mapOf("source" to "google", "token" to token), Identity.google(tokenBytes))
    }

    @Test
    fun `maps firebase identity`() {
        assertMaps(mapOf("source" to "firebase", "token" to token), Identity.firebase(tokenBytes))
    }

    @Test
    fun `maps facebook identity with email`() {
        assertMaps(
            mapOf("source" to "facebook", "token" to token, "email" to "a@b.com"),
            Identity.facebook(tokenBytes, "a@b.com"),
        )
    }

    @Test
    fun `maps facebook identity without email`() {
        assertMaps(mapOf("source" to "facebook", "token" to token), Identity.facebook(tokenBytes, null))
    }

    @Test
    fun `ignores email for non-facebook identities`() {
        assertMaps(
            mapOf("source" to "google", "token" to token, "email" to "a@b.com"),
            Identity.google(tokenBytes),
        )
    }

    @Test
    fun `encodes non-ascii tokens as UTF-8`() {
        val unicodeToken = "tökén-✓"
        assertMaps(
            mapOf("source" to "oidc", "token" to unicodeToken),
            Identity.oidc(unicodeToken.toByteArray(Charsets.UTF_8)),
        )
    }

    @Test
    fun `accepts every public identity source raw value`() {
        IdentitySource.values()
            .filter { it != IdentitySource.ANONYMOUS }
            .forEach { source ->
                val result = mapOf("source" to source.rawValue, "token" to token).toIdentity()
                assertThat(result).isInstanceOf(IdentityMappingResult.Success::class.java)
                assertThat((result as IdentityMappingResult.Success).identity.identitySource).isEqualTo(source)
            }
    }

    @Test
    fun `rejects anonymous source`() {
        assertFails(mapOf("source" to "anonymous", "token" to token), PurchasesErrorCode.UnsupportedError)
    }

    @Test
    fun `rejects unknown source`() {
        assertFails(mapOf("source" to "myspace", "token" to token), PurchasesErrorCode.UnsupportedError)
    }

    @Test
    fun `rejects missing source`() {
        assertFails(mapOf("token" to token), PurchasesErrorCode.UnsupportedError)
    }

    @Test
    fun `rejects non-string source`() {
        assertFails(mapOf("source" to 1, "token" to token), PurchasesErrorCode.UnsupportedError)
    }

    @Test
    fun `rejects missing token`() {
        assertFails(mapOf("source" to "google"), PurchasesErrorCode.InvalidCredentialsError)
    }

    @Test
    fun `rejects empty token`() {
        assertFails(mapOf("source" to "google", "token" to ""), PurchasesErrorCode.InvalidCredentialsError)
    }

    @Test
    fun `rejects non-string token`() {
        assertFails(mapOf("source" to "google", "token" to 42), PurchasesErrorCode.InvalidCredentialsError)
    }

    private fun assertMaps(map: Map<String, Any?>, expected: Identity) {
        val result = map.toIdentity()
        assertThat(result).isEqualTo(IdentityMappingResult.Success(expected))
    }

    private fun assertFails(map: Map<String, Any?>, expectedCode: PurchasesErrorCode) {
        val result = map.toIdentity()
        assertThat(result).isInstanceOf(IdentityMappingResult.Failure::class.java)
        val error = (result as IdentityMappingResult.Failure).error
        assertThat(error.code).isEqualTo(expectedCode.code)
        assertThat(error.info["readableErrorCode"]).isEqualTo(expectedCode.name)
    }
}
