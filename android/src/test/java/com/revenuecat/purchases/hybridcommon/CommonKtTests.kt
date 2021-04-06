package com.revenuecat.purchases.hybridcommon


import android.app.Application
import android.content.Context
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.common.PlatformInfo
import io.mockk.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import java.net.URL
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class CommonKtTests {
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
    }

    @Test
    fun `calling logIn correctly passes call to Purchases`() {
        val appUserID = "appUserID"

        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.sharedInstance } returns mockPurchases
        every { mockPurchases.logIn(appUserID, any()) } just runs

        logIn(appUserID = appUserID, onResult = object : OnResult {
            override fun onReceived(map: Map<String?, *>?) {}
            override fun onError(errorContainer: ErrorContainer) {}
        })

        verify(exactly = 1) { mockPurchases.logIn(appUserID, any()) }
    }

    @Test
    fun `calling logOut correctly passes call to Purchases`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.sharedInstance } returns mockPurchases
        every { mockPurchases.logOut(any()) } just runs

        logOut(onResult = object : OnResult {
            override fun onReceived(map: Map<String?, *>?) {}
            override fun onError(errorContainer: ErrorContainer) {}
        })

        verify(exactly = 1) { mockPurchases.logOut(any()) }
    }
}
