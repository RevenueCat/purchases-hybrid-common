package com.revenuecat.purchases.common

import android.app.Application
import android.content.Context
import com.revenuecat.purchases.Purchases
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

internal class ConfiguringUnitTests {
    @Nested
    @DisplayName("when setting up Purchases")
    inner class ParsingInvalidPurchasesPeriod {
        private val mockPurchases = mockk<Purchases>()
        private val mockContext = mockk<Context>(relaxed = true)
        private val mockApplicationContext = mockk<Application>(relaxed = true)
        private val expectedPlatformInfo = PlatformInfo("flavor", "version")

        @BeforeEach
        fun setup() {
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
        }

        @Test
        fun `with observer mode false should configure the Android SDK with observer mode false`() {
            configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = false,
                platformInfo = expectedPlatformInfo
            )
            verify(exactly = 1) {
                Purchases.configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = "appUserID",
                    observerMode = false,
                    service = any()
                )
            }
        }

        @Test
        fun `with observer mode true, should configure the Android SDK with observer mode true`() {
            configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = expectedPlatformInfo
            )
            verify(exactly = 1) {
                Purchases.configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = "appUserID",
                    observerMode = true,
                    service = any()
                )
            }
        }

        @Test
        fun `with a null observer mode should configure the Android SDK with observer mode false`() {
            configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = null,
                platformInfo = expectedPlatformInfo
            )
            verify(exactly = 1) {
                Purchases.configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = "appUserID",
                    observerMode = false,
                    service = any()
                )
            }
        }

        @Test
        fun `with a null app user ID, should configure the Android SDK with null app user ID`() {
            configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = null,
                observerMode = null,
                platformInfo = expectedPlatformInfo
            )
            verify(exactly = 1) {
                Purchases.configure(
                    context = mockContext,
                    apiKey = "api_key",
                    appUserID = null,
                    observerMode = false,
                    service = any()
                )
            }
        }

        @Test
        fun `with a platform info, should configure the Android SDK with that platform info`() {
            configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = false,
                platformInfo = expectedPlatformInfo
            )
            verify(exactly = 1) {
                Purchases.platformInfo = expectedPlatformInfo
            }
        }
    }
}