package com.revenuecat.purchases.common


import com.revenuecat.purchases.Purchases
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe
import java.net.URL
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.expect

object CommonKtTests : Spek({
    describe("setProxyURLString") {
        it("sets the proxyURL correctly from a valid URL") {
            assertEquals(Purchases.proxyURL, null)

            val urlString = "https://revenuecat.com"
            setProxyURLString(urlString)

            assertEquals(Purchases.proxyURL.toString(), urlString)
        }

        it("sets the proxyURL to null from a null string") {
            Purchases.proxyURL = URL("https://revenuecat.com")

            setProxyURLString(null)

            assertEquals(Purchases.proxyURL, null)
        }

        it("raises exception if url string can't be parsed into a URL") {
            assertFailsWith<java.net.MalformedURLException> {
                setProxyURLString("this is not a url")
            }
        }
    }
})