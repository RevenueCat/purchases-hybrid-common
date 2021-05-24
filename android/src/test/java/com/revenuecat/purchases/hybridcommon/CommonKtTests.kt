package com.revenuecat.purchases.hybridcommon


import android.app.Application
import android.content.Context
import com.revenuecat.purchases.BillingFeature
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.common.PlatformInfo
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.runs
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import java.net.URL
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class CommonKtTests {

    private val mockApplicationContext = mockk<Application>(relaxed = true)
    private val mockContext = mockk<Context>(relaxed = true)
    private val mockPurchases = mockk<Purchases>()

    @BeforeEach
    fun setup() {
        mockkObject(Purchases)
        every {
            Purchases.configure(
                    context = any(),
                    apiKey = any(),
                    appUserID = any(),
                    observerMode = any(),
                    service = any()
            )
        } returns mockPurchases
        every { mockContext.applicationContext } returns mockApplicationContext
        every { Purchases.sharedInstance } returns mockPurchases
    }


    @Test
    fun `Calling setProxyURLString, sets the proxyURL correctly from a valid URL`() {
        assertEquals(Purchases.proxyURL, null)

        val urlString = "https://revenuecat.com"
        setProxyURLString(urlString)

        assertEquals(Purchases.proxyURL.toString(), urlString)
    }

    @Test
    fun `Calling setProxyURLString, sets the proxyURL to null from a null string`() {
        Purchases.proxyURL = URL("https://revenuecat.com")

        setProxyURLString(null)

        assertEquals(Purchases.proxyURL, null)
    }

    @Test
    fun `Calling setProxyURLString, raises exception if url string can't be parsed into a URL`() {
        assertFailsWith<java.net.MalformedURLException> {
            setProxyURLString("this is not a url")
        }
    }

    @Test
    fun `calling canMakePayments correctly passes through to Purchases`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.canMakePayments(mockContext, any(), any()) } just runs

        val onResult = mockk<OnResultAny<Boolean>>()
        every { onResult.onReceived(any()) } just runs

        canMakePayments(mockContext,
                listOf(BillingFeature.SUBSCRIPTIONS.ordinal),
                onResult)

        verify(exactly = 1) {
            Purchases.canMakePayments(
                    mockContext,
                    listOf(BillingFeature.SUBSCRIPTIONS),
                    any())
        }
    }

    @Test
    fun `calling canMakePayments with empty list correctly passes through to Purchases`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.canMakePayments(mockContext, any(), any()) } just runs

        val onResult = mockk<OnResultAny<Boolean>>()
        every { onResult.onReceived(any()) } just runs

        canMakePayments(mockContext,
                listOf(),
                onResult)

        verify(exactly = 1) {
            Purchases.canMakePayments(
                    mockContext,
                    listOf(),
                    any())
        }
    }

    @Test
    fun `canMakePayments correctly maps all integer values to BillingFeature enum type`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.canMakePayments(mockContext, any(), any()) } just runs

        val onResult = mockk<OnResultAny<Boolean>>()
        every { onResult.onReceived(any()) } just runs

        val billingFeatureValues = BillingFeature.values()

        billingFeatureValues.forEachIndexed { index, billingFeature ->
            canMakePayments(mockContext,
                    listOf(index),
                    onResult)

            verify(exactly = 1) {
                Purchases.canMakePayments(
                        mockContext,
                        listOf(billingFeature),
                        any())
            }
        }
    }

    @Test
    fun `calling canMakePayments with invalid integer results in error`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.canMakePayments(mockContext, any(), any()) } just runs

        val onResultAny = mockk<OnResultAny<Boolean>>()
        every { onResultAny.onError(any())} just runs

        canMakePayments(mockContext,
                listOf(8),
                onResultAny)

        verify(exactly = 1) {
            onResultAny.onError(any())
        }
    }
}
