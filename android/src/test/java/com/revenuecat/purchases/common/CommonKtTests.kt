package com.revenuecat.purchases.common


import com.revenuecat.purchases.Purchases
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import java.net.URL
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class CommonKtTests {
    @Nested
    @DisplayName("Calling setProxyURLString")
    inner class SetProxyURLString {
        @Test
        fun `sets the proxyURL correctly from a valid URL`() {
            assertEquals(Purchases.proxyURL, null)

            val urlString = "https://revenuecat.com"
            setProxyURLString(urlString)

            assertEquals(Purchases.proxyURL.toString(), urlString)
        }

        @Test
        fun `sets the proxyURL to null from a null string`() {
            Purchases.proxyURL = URL("https://revenuecat.com")

            setProxyURLString(null)

            assertEquals(Purchases.proxyURL, null)
        }

        @Test
        fun `raises exception if url string can't be parsed into a URL`() {
            assertFailsWith<java.net.MalformedURLException> {
                setProxyURLString("this is not a url")
            }
        }
    }
}