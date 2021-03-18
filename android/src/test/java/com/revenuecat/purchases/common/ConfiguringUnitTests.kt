package com.revenuecat.purchases.common

import android.app.Application
import android.content.Context
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesConfiguration
import com.revenuecat.purchases.Store
import io.mockk.CapturingSlot
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.slot
import io.mockk.verify
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe
import kotlin.test.assertEquals
import kotlin.test.assertTrue

object ConfiguringUnitTests : Spek({
    describe("when setting up Purchases") {

        val mockPurchases by memoized { mockk<Purchases>() }
        val mockContext by memoized { mockk<Context>(relaxed = true) }
        val mockApplicationContext by memoized { mockk<Application>(relaxed = true) }
        val expectedPlatformInfo by memoized {
            PlatformInfo("flavor", "version")
        }

        val purchasesConfigurationSlot = slot<PurchasesConfiguration>()

        beforeEachTest {
            every { mockContext.applicationContext } returns mockApplicationContext
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
            every {
                Purchases.configure(configuration = capture(purchasesConfigurationSlot))
            } returns mockPurchases
        }

        context("with observer mode false") {
            it("should configure the Android SDK with observer mode false") {
                configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = "appUserID",
                    observerMode = false,
                    platformInfo = expectedPlatformInfo,
                    store = Store.PLAY_STORE
                )
                assertConfiguration(
                    purchasesConfigurationSlot,
                    expectedContext = mockContext,
                    expectedApiKey = "api_key",
                    expectedAppUserID = "appUserID",
                    expectedObserverMode = false
                )
            }
        }

        context("with observer mode true") {
            it("should configure the Android SDK with observer mode true") {
                configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = "appUserID",
                    observerMode = true,
                    platformInfo = expectedPlatformInfo,
                    store = Store.PLAY_STORE
                )
                assertConfiguration(
                    purchasesConfigurationSlot,
                    expectedContext = mockContext,
                    expectedApiKey = "api_key",
                    expectedAppUserID = "appUserID",
                    expectedObserverMode = true
                )
            }
        }

        context("with a null observer mode") {
            it("should configure the Android SDK with observer mode false") {
                configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = "appUserID",
                    observerMode = null,
                    platformInfo = expectedPlatformInfo,
                    store = Store.PLAY_STORE
                )
                assertConfiguration(
                    purchasesConfigurationSlot,
                    expectedContext = mockContext,
                    expectedApiKey = "api_key",
                    expectedAppUserID = "appUserID",
                    expectedObserverMode = false,
                )
            }
        }

        context("with a null app user ID") {
            it("should configure the Android SDK with null app user ID") {
                configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = null,
                    observerMode = null,
                    platformInfo = expectedPlatformInfo,
                    store = Store.PLAY_STORE
                )
                assertConfiguration(
                    purchasesConfigurationSlot,
                    expectedContext = mockContext,
                    expectedApiKey = "api_key",
                    expectedAppUserID = null,
                    expectedObserverMode = false,
                )
            }
        }

        context("with a platform info") {
            it("should configure the Android SDK with that platform info") {
                configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = "appUserID",
                    observerMode = false,
                    platformInfo = expectedPlatformInfo,
                    store = Store.PLAY_STORE
                )
                verify(exactly = 1) {
                    Purchases.platformInfo = expectedPlatformInfo
                }
            }
        }


    }
})

fun assertConfiguration(
    purchasesConfigurationSlot: CapturingSlot<PurchasesConfiguration>,
    expectedContext: Context,
    expectedApiKey: String,
    expectedAppUserID: String?,
    expectedObserverMode: Boolean
) {
    assertTrue(purchasesConfigurationSlot.isCaptured)
    purchasesConfigurationSlot.captured.let { captured ->
        assertEquals(expectedContext, captured.context)
        assertEquals(expectedApiKey, captured.apiKey)
        assertEquals(expectedAppUserID, captured.appUserID)
        assertEquals(expectedObserverMode, captured.observerMode)
    }
}

