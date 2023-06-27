package com.revenuecat.purchases.hybridcommon

import android.app.Application
import android.content.Context
import com.revenuecat.purchases.DangerousSettings
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesConfiguration
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.common.PlatformInfo
import io.mockk.CapturingSlot
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.slot
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

internal class ConfiguringUnitTests {
    private val mockPurchases = mockk<Purchases>()
    private val mockContext = mockk<Context>(relaxed = true)
    private val mockApplicationContext = mockk<Application>(relaxed = true)
    private val expectedPlatformInfo = PlatformInfo("flavor", "version")
    private val purchasesConfigurationSlot = slot<PurchasesConfiguration>()

    @BeforeEach
    fun setup() {
        every { mockContext.applicationContext } returns mockApplicationContext
        mockkObject(Purchases)
        every {
            Purchases.configure(any())
        } returns mockPurchases
        every {
            Purchases.configure(configuration = capture(purchasesConfigurationSlot))
        } returns mockPurchases
    }

    @Test
    fun `calling configure with observer mode false should configure the Android SDK with observer mode false`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = false,
            platformInfo = expectedPlatformInfo,
            store = Store.PLAY_STORE,
        )
        assertConfiguration(
            purchasesConfigurationSlot,
            expectedContext = mockContext,
            expectedApiKey = "api_key",
            expectedAppUserID = "appUserID",
            expectedObserverMode = false,
        )
    }

    @Test
    fun `calling configure with observer mode true, should configure the Android SDK with observer mode true`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = expectedPlatformInfo,
            store = Store.PLAY_STORE,
        )
        assertConfiguration(
            purchasesConfigurationSlot,
            expectedContext = mockContext,
            expectedApiKey = "api_key",
            expectedAppUserID = "appUserID",
            expectedObserverMode = true,
        )
    }

    @Test
    fun `calling configure with a null observer mode should configure the Android SDK with observer mode false`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = null,
            platformInfo = expectedPlatformInfo,
            store = Store.PLAY_STORE,
        )
        assertConfiguration(
            purchasesConfigurationSlot,
            expectedContext = mockContext,
            expectedApiKey = "api_key",
            expectedAppUserID = "appUserID",
            expectedObserverMode = false,
        )
    }

    @Test
    fun `calling configure with a null app user ID, should configure the Android SDK with null app user ID`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = null,
            observerMode = null,
            platformInfo = expectedPlatformInfo,
            store = Store.PLAY_STORE,
        )
        assertConfiguration(
            purchasesConfigurationSlot,
            expectedContext = mockContext,
            expectedApiKey = "api_key",
            expectedAppUserID = null,
            expectedObserverMode = false,
        )
    }

    @Test
    fun `calling configure with a platform info, should configure the Android SDK with that platform info`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = false,
                platformInfo = expectedPlatformInfo,
                store = Store.PLAY_STORE,
        )
        verify(exactly = 1) {
            Purchases.platformInfo = expectedPlatformInfo
        }
    }

    @Test
    fun `calling configure with no verification mode`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = false,
                platformInfo = expectedPlatformInfo,
                verificationMode = null
        )
        verify(exactly = 1) {
            // TODO
        }
    }

    @Test
    fun `calling configure with verification mode disabled`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = false,
                platformInfo = expectedPlatformInfo,
                verificationMode = "DISABLED"
        )
        verify(exactly = 1) {
            // TODO
        }
    }

    @Test
    fun `calling configure with verification mode informational`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = false,
                platformInfo = expectedPlatformInfo,
                verificationMode = "INFORMATIONAL"
        )
        verify(exactly = 1) {
            // TODO
        }
    }

    @Test
    fun `calling configure with verification mode enforced`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = false,
                platformInfo = expectedPlatformInfo,
                verificationMode = "ENFORCED"
        )
        verify(exactly = 1) {
            // TODO
        }
    }

    @Test
    fun `calling configure without dangerous settings defaults to autosync on`() {
        val expectedDangerousSettings = DangerousSettings(autoSyncPurchases = true)
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = false,
            platformInfo = expectedPlatformInfo,
            store = Store.PLAY_STORE,
        )
        assertEquals(expectedDangerousSettings, purchasesConfigurationSlot.captured.dangerousSettings)
    }

    @Test
    fun `calling configure passing dangerous settings on`() {
        val expectedDangerousSettings = DangerousSettings(autoSyncPurchases = false)
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = false,
            platformInfo = expectedPlatformInfo,
            store = Store.PLAY_STORE,
            dangerousSettings = expectedDangerousSettings,
        )
        assertEquals(expectedDangerousSettings, purchasesConfigurationSlot.captured.dangerousSettings)
    }

    private fun assertConfiguration(
        purchasesConfigurationSlot: CapturingSlot<PurchasesConfiguration>,
        expectedContext: Context,
        expectedApiKey: String,
        expectedAppUserID: String?,
        expectedObserverMode: Boolean,
    ) {
        assertTrue(purchasesConfigurationSlot.isCaptured)
        purchasesConfigurationSlot.captured.let { captured ->
            assertEquals(expectedContext, captured.context)
            assertEquals(expectedApiKey, captured.apiKey)
            assertEquals(expectedAppUserID, captured.appUserID)
            assertEquals(expectedObserverMode, captured.observerMode)
        }
    }
}
