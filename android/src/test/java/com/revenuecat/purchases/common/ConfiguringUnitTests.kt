package com.revenuecat.purchases.common

import android.app.Application
import android.content.Context
import com.revenuecat.purchases.PlatformInfo
import com.revenuecat.purchases.Purchases
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.verify
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe

object ConfiguringUnitTests : Spek({
    describe("when setting up Purchases") {

        val mockPurchases by memoized { mockk<Purchases>() }
        val mockContext by memoized { mockk<Context>(relaxed = true) }
        val mockApplicationContext by memoized { mockk<Application>(relaxed = true) }
        val expectedPlatformInfo by memoized {
            PlatformInfo("flavor", "version")
        }

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
        }

        context("with observer mode false") {
            it("should configure the Android SDK with observer mode false") {
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
        }

        context("with observer mode true") {
            it("should configure the Android SDK with observer mode true") {
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
        }

        context("with a null observer mode") {
            it("should configure the Android SDK with observer mode false") {
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
        }

        context("with a null app user ID") {
            it("should configure the Android SDK with null app user ID") {
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
        }
    }
})