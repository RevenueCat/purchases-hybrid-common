package com.revenuecat.purchases.hybridcommon


import android.app.Application
import android.content.Context
import com.revenuecat.purchases.PurchaserInfo
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.interfaces.LogInCallback
import com.revenuecat.purchases.interfaces.ReceivePurchaserInfoListener
import io.mockk.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import java.net.URL
import kotlin.random.Random
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
    fun `calling logIn correctly calls onReceived`() {
        val appUserID = "appUserID"

        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.sharedInstance } returns mockPurchases

        val mockInfo = mockk<PurchaserInfo>(relaxed = true)
        val mockCreated = Random.nextBoolean()

        val logInCallback = slot<LogInCallback>()
        every {
            mockPurchases.logIn(
                newAppUserID = appUserID,
                capture(logInCallback)
            )
        } just runs

        val onResult = mockk<OnResult>()
        every { onResult.onReceived(any()) } just runs
        every { onResult.onError(any()) } just runs

        logIn(appUserID = appUserID, onResult = onResult)
        logInCallback.captured.onReceived(mockInfo, mockCreated)

        val mockInfoMap = mockInfo.map()

        verify(exactly = 1) {
            onResult.onReceived(mapOf(
                "created" to mockCreated,
                "purchaserInfo" to mockInfoMap
            ))
        }
    }

    @Test
    fun `calling logIn with error calls onError`() {
        val appUserID = "appUserID"

        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.sharedInstance } returns mockPurchases
        val mockError = mockk<PurchasesError>(relaxed = true)

        val logInCallback = slot<LogInCallback>()
        every {
            mockPurchases.logIn(
                newAppUserID = appUserID,
                capture(logInCallback)
            )
        } just runs

        val onResult = mockk<OnResult>()
        every { onResult.onReceived(any()) } just runs
        every { onResult.onError(any()) } just runs

        logIn(appUserID = appUserID, onResult = onResult)
        logInCallback.captured.onError(mockError)

        val mockErrorMap = mockError.map()
        verify(exactly = 1) {
            onResult.onError(mockErrorMap)
        }
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

    @Test
    fun `calling logOut correctly calls onReceived`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.sharedInstance } returns mockPurchases
        val mockInfo = mockk<PurchaserInfo>(relaxed = true)
        val receivePurchaserInfoListener = slot<ReceivePurchaserInfoListener>()

        every { mockPurchases.logOut(capture(receivePurchaserInfoListener)) } just runs
        val onResult = mockk<OnResult>()
        every { onResult.onReceived(any()) } just runs
        every { onResult.onError(any()) } just runs

        logOut(onResult)

        receivePurchaserInfoListener.captured.onReceived(mockInfo)

        val mockInfoMap = mockInfo.map()
        verify(exactly = 1) { onResult.onReceived(mockInfoMap) }
    }

    @Test
    fun `calling logOut with error calls onError`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.sharedInstance } returns mockPurchases
        val mockError = mockk<PurchasesError>(relaxed = true)
        val receivePurchaserInfoListener = slot<ReceivePurchaserInfoListener>()

        every { mockPurchases.logOut(capture(receivePurchaserInfoListener)) } just runs
        val onResult = mockk<OnResult>()
        every { onResult.onReceived(any()) } just runs
        every { onResult.onError(any()) } just runs

        logOut(onResult)

        receivePurchaserInfoListener.captured.onError(mockError)

        val mockErrorMap = mockError.map()
        verify(exactly = 1) { onResult.onError(mockErrorMap) }
    }
}
