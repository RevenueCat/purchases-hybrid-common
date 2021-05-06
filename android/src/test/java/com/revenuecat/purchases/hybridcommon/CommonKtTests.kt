package com.revenuecat.purchases.hybridcommon


import android.app.Application
import android.content.Context
import com.revenuecat.purchases.PurchaserInfo
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.common.BillingFeature
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.interfaces.ReceivePurchaserInfoListener
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.runs
import io.mockk.slot
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import java.net.URL
import kotlin.random.Random
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

        canMakePayments(mockContext, BillingFeature.SUBSCRIPTIONS, onResult = object : OnResult {
            override fun onReceived(map: Map<String?, *>?) {}
            override fun onError(errorContainer: ErrorContainer) {}
        })

        verify(exactly = 1) { Purchases.Companion.canMakePayments(mockContext, BillingFeature.SUBSCRIPTIONS, any()) }
    }
}
