package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.VirtualCurrencyInfo
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class VirtualCurrencyInfoMapperTests {

    private val balanceDictionaryKey = "balance"

    @OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
    @Test
    fun `VirtualCurrencyInfo maps to expected map`() {
        val mockVirtualCurrencyInfo = generateMockVirtualCurrencyInfo()
        val vcInfoMap = mockVirtualCurrencyInfo.map()

        assertThat(vcInfoMap).hasSize(1)
        assertThat(vcInfoMap[balanceDictionaryKey]).isEqualTo(100L)
    }

    @OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
    fun generateMockVirtualCurrencyInfo(
        balance: Long = 100L
    ): VirtualCurrencyInfo {
        val mockVirtualCurrencyInfo = mockk<VirtualCurrencyInfo>()
        every { mockVirtualCurrencyInfo.balance } returns balance

        return mockVirtualCurrencyInfo
    }

}
