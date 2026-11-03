@file:OptIn(InternalRevenueCatAPI::class, ExperimentalCoroutinesApi::class)

package com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.hybridcommon.mappers.overrideMapperDispatcher
import com.revenuecat.purchases.identity.Authentication
import com.revenuecat.purchases.identity.AuthenticationDelegate
import com.revenuecat.purchases.identity.Identity
import com.revenuecat.purchases.interfaces.ReceiveCustomerInfoCallback
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.runs
import io.mockk.slot
import io.mockk.verify
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

internal class AuthenticationTests {

    private val mockPurchases = mockk<Purchases>()
    private val mockAuthentication = mockk<Authentication>()
    private var nativeDelegate: AuthenticationDelegate? = null

    private val received = mutableListOf<Map<String, *>>()
    private val errors = mutableListOf<ErrorContainer>()
    private val onResult = object : OnResult {
        override fun onReceived(map: Map<String, *>) {
            received += map
        }

        override fun onError(errorContainer: ErrorContainer) {
            errors += errorContainer
        }
    }

    @BeforeEach
    fun setup() {
        mockLogs()
        mockkObject(Purchases)
        every { Purchases.sharedInstance } returns mockPurchases
        every { mockPurchases.authentication } returns mockAuthentication
        every { mockAuthentication.delegate = any() } answers { nativeDelegate = firstArg() }
        every { mockAuthentication.delegate } answers { nativeDelegate }
        val testDispatcher = UnconfinedTestDispatcher()
        overrideMapperDispatcher = testDispatcher
        Dispatchers.setMain(testDispatcher)
    }

    @AfterEach
    fun teardown() {
        authenticationDelegate = null
        Dispatchers.resetMain()
    }

    // region logInWithIdentity

    @Test
    fun `logInWithIdentity passes the mapped identity to Authentication`() {
        val identitySlot = slot<Identity>()
        every { mockAuthentication.logIn(capture(identitySlot), any()) } just runs

        logInWithIdentity(mapOf("source" to "google", "token" to "abc"), onResult)

        assertThat(identitySlot.captured).isEqualTo(Identity.google("abc".toByteArray(Charsets.UTF_8)))
    }

    @Test
    fun `logInWithIdentity success maps CustomerInfo`() {
        val callbackSlot = slot<ReceiveCustomerInfoCallback>()
        every { mockAuthentication.logIn(any(), capture(callbackSlot)) } just runs
        val customerInfo = mockk<CustomerInfo>(relaxed = true)

        logInWithIdentity(mapOf("source" to "oidc", "token" to "abc"), onResult)
        callbackSlot.captured.onReceived(customerInfo)

        assertThat(received).containsExactly(customerInfo.mapBlocking())
        assertThat(errors).isEmpty()
    }

    @Test
    fun `logInWithIdentity native error is mapped`() {
        val callbackSlot = slot<ReceiveCustomerInfoCallback>()
        every { mockAuthentication.logIn(any(), capture(callbackSlot)) } just runs
        val error = PurchasesError(PurchasesErrorCode.ConfigurationError, "IAM login is not enabled.")

        logInWithIdentity(mapOf("source" to "oidc", "token" to "abc"), onResult)
        callbackSlot.captured.onError(error)

        assertThat(errors).containsExactly(error.map())
        assertThat(received).isEmpty()
    }

    @Test
    fun `logInWithIdentity with an invalid identity fails without calling Authentication`() {
        logInWithIdentity(mapOf("source" to "anonymous", "token" to "abc"), onResult)

        assertThat(errors).hasSize(1)
        assertThat(errors[0].code).isEqualTo(PurchasesErrorCode.UnsupportedError.code)
        verify(exactly = 0) { mockAuthentication.logIn(any(), any()) }
    }

    // endregion logInWithIdentity

    // region getCurrentAccessToken

    @Test
    fun `getCurrentAccessToken returns the token`() {
        every { mockAuthentication.currentAccessToken } returns "token"
        assertThat(getCurrentAccessToken()).isEqualTo("token")
    }

    @Test
    fun `getCurrentAccessToken returns null without a token`() {
        every { mockAuthentication.currentAccessToken } returns null
        assertThat(getCurrentAccessToken()).isNull()
    }

    // endregion getCurrentAccessToken

    // region setAuthenticationListener

    @Test
    fun `setAuthenticationListener installs a delegate the bridge keeps a strong reference to`() {
        setAuthenticationListener(onError = {}, onAccessTokenUpdated = {})

        assertThat(nativeDelegate).isNotNull
        assertThat(authenticationDelegate).isSameAs(nativeDelegate)
    }

    @Test
    fun `listener receives mapped errors`() {
        val receivedErrors = mutableListOf<ErrorContainer>()
        setAuthenticationListener(onError = { receivedErrors += it }, onAccessTokenUpdated = {})
        val error = PurchasesError(PurchasesErrorCode.InvalidCredentialsError, "refresh failed")

        nativeDelegate!!.authenticatorDidEncounterError(error)

        assertThat(receivedErrors).containsExactly(error.map())
    }

    @Test
    fun `listener receives token updates including null`() {
        val tokens = mutableListOf<String?>()
        setAuthenticationListener(onError = {}, onAccessTokenUpdated = { tokens += it })

        nativeDelegate!!.authenticatorDidUpdateAccessToken("new-token")
        nativeDelegate!!.authenticatorDidUpdateAccessToken(null)

        assertThat(tokens).containsExactly("new-token", null)
    }

    @Test
    fun `setting a new listener replaces the old one`() {
        val first = mutableListOf<String?>()
        val second = mutableListOf<String?>()
        setAuthenticationListener(onError = {}, onAccessTokenUpdated = { first += it })
        val firstDelegate = nativeDelegate!!
        setAuthenticationListener(onError = {}, onAccessTokenUpdated = { second += it })

        assertThat(nativeDelegate).isNotSameAs(firstDelegate)
        nativeDelegate!!.authenticatorDidUpdateAccessToken("token")

        assertThat(first).isEmpty()
        assertThat(second).containsExactly("token")
    }

    @Test
    fun `removeAuthenticationListener clears the delegate`() {
        setAuthenticationListener(onError = {}, onAccessTokenUpdated = {})

        removeAuthenticationListener()

        assertThat(nativeDelegate).isNull()
        assertThat(authenticationDelegate).isNull()
    }

    // endregion setAuthenticationListener
}
