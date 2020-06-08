package com.revenuecat.purchases.common

import android.net.Uri
import com.revenuecat.purchases.PurchaserInfo
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe

object PurchaserInfoMappersTests : Spek({

    describe("when mapping a PurchaserInfo") {
        val mockPurchaserInfo by memoized { mockk<PurchaserInfo>(relaxed = true) }

        context("with a null managementURL") {
            it("should map to a null managementURL") {
                every { mockPurchaserInfo.managementURL } returns null
                val map = mockPurchaserInfo.map()
                assertThat(map["managementURL"]).isNull()
            }
        }

        context("with a non null managementURL") {
            it("should map to a null managementURL") {
                val expected = "https://www.url.com/"
                val mockkUri = mockk<Uri>(relaxed = true)
                every { mockPurchaserInfo.managementURL } returns mockkUri
                every { mockkUri.toString() } returns expected
                val map = mockPurchaserInfo.map()
                assertThat(map["managementURL"]).isEqualTo(expected)
            }
        }

    }

})