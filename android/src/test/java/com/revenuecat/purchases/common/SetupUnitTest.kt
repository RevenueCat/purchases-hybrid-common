package com.revenuecat.purchases.common

import com.revenuecat.purchases.Purchases
import org.assertj.core.api.Assertions.assertThat
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe

object SetupUnitTest: Spek({
    describe("setting platform info") {
        val expectedFlavor = "flavor"
        val expectedVersion = "version"
        setPlatformInfo(expectedFlavor, expectedVersion)
        it("should set the platform info in the Android SDK") {
            assertThat(Purchases.platformInfo.flavor).isEqualTo(expectedFlavor)
            assertThat(Purchases.platformInfo.version).isEqualTo(expectedVersion)
        }
    }
})