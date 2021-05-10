package com.revenuecat.purchases.hybridcommon


import android.app.Application
import android.content.Context
import com.revenuecat.purchases.BillingFeature
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.common.PlatformInfo
import io.mockk.*
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
    fun `calling canMakePayments correctly passes call to Purchases`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.Companion.canMakePayments(mockContext, any(), any()) } just runs

        val onResult = mockk<OnResult>()
        every { onResult.onReceived(any()) } just runs

        canMakePayments(mockContext,
                listOf(BillingFeature.SUBSCRIPTIONS.name),
                onResult = object : OnResultAny<Boolean> {
                    override fun onReceived(result: Boolean) {}
                    override fun onError(errorContainer: ErrorContainer?) {}
                })

        verify(exactly = 1) {
            Purchases.Companion.canMakePayments(
                    mockContext,
                    listOf(BillingFeature.SUBSCRIPTIONS),
                    any())
        }
    }

    @Test
    fun `calling canMakePayments with invalid string results in error`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.Companion.canMakePayments(mockContext, any(), any()) } just runs

        val onResultAny = object : OnResultAny<Boolean> {
            override fun onReceived(result: Boolean) {}
            override fun onError(errorContainer: ErrorContainer?) {}
        }

        canMakePayments(mockContext,
                listOf("a;sdklfja;skdjgh"),
                onResult = onResultAny)

        verify(exactly = 1) {
            onResultAny.onError(any())
        }
    }
}
