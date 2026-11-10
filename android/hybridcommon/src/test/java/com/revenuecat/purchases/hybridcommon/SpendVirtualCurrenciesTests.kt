@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.interfaces.GetVirtualCurrenciesCallback
import com.revenuecat.purchases.virtualcurrencies.VirtualCurrencies
import com.revenuecat.purchases.virtualcurrencies.VirtualCurrency
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.runs
import io.mockk.slot
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

internal class SpendVirtualCurrenciesTests {

    private val mockPurchases = mockk<Purchases>()
    private val amountsSlot = slot<Map<String, Int>>()
    private val callbackSlot = slot<GetVirtualCurrenciesCallback>()
    private val references = mutableListOf<String?>()

    private val received = mutableListOf<Map<String, *>>()
    private val errors = mutableListOf<ErrorContainer>()
    private val onResult = object : OnResult {
        override fun onReceived(map: Map<String, *>) {
            received += map
        }

        override fun onError(errorContainer: ErrorContainer) {
            errors += errorContainer
        }
    }

    @BeforeEach
    fun setup() {
        mockLogs()
        mockkObject(Purchases)
        every { Purchases.sharedInstance } returns mockPurchases
        every {
            mockPurchases.spendVirtualCurrencies(
                capture(amountsSlot),
                captureNullable(references),
                capture(callbackSlot),
            )
        } just runs
    }

    @Test
    fun `passes amounts and reference to Purchases`() {
        spendVirtualCurrencies(mapOf("GLD" to 5, "SLV" to 10), "order-1", onResult)

        assertThat(amountsSlot.captured).isEqualTo(mapOf("GLD" to 5, "SLV" to 10))
        assertThat(references).containsExactly("order-1")
    }

    @Test
    fun `passes a null reference`() {
        spendVirtualCurrencies(mapOf("GLD" to 5), null, onResult)

        assertThat(references).containsExactly(null)
    }

    @Test
    fun `converts whole-number doubles and longs`() {
        spendVirtualCurrencies(mapOf("GLD" to 5.0, "SLV" to 10L), null, onResult)

        assertThat(amountsSlot.captured).isEqualTo(mapOf("GLD" to 5, "SLV" to 10))
    }

    @Test
    fun `passes non-positive amounts through for the SDK to ignore`() {
        spendVirtualCurrencies(mapOf("GLD" to 0, "SLV" to -3), null, onResult)

        assertThat(amountsSlot.captured).isEqualTo(mapOf("GLD" to 0, "SLV" to -3))
    }

    @Test
    fun `rejects fractional amounts without calling Purchases`() {
        assertRejected(mapOf("GLD" to 1.5))
    }

    @Test
    fun `rejects non-numeric amounts without calling Purchases`() {
        assertRejected(mapOf("GLD" to "5"))
    }

    @Test
    fun `rejects null amounts without calling Purchases`() {
        assertRejected(mapOf("GLD" to null))
    }

    @Test
    fun `rejects amounts that don't fit in an Int without calling Purchases`() {
        assertRejected(mapOf("GLD" to Int.MAX_VALUE.toLong() + 1))
    }

    @Test
    fun `success maps virtual currencies`() {
        val virtualCurrency = mockk<VirtualCurrency>()
        every { virtualCurrency.balance } returns 95
        every { virtualCurrency.name } returns "Gold"
        every { virtualCurrency.code } returns "GLD"
        every { virtualCurrency.serverDescription } returns null
        val virtualCurrencies = mockk<VirtualCurrencies>()
        every { virtualCurrencies.all } returns mapOf("GLD" to virtualCurrency)

        spendVirtualCurrencies(mapOf("GLD" to 5), null, onResult)
        callbackSlot.captured.onReceived(virtualCurrencies)

        assertThat(received).containsExactly(virtualCurrencies.map())
        assertThat(errors).isEmpty()
    }

    @Test
    fun `native error is mapped`() {
        val error = PurchasesError(PurchasesErrorCode.UnsupportedError, "Spending requires IAM")

        spendVirtualCurrencies(mapOf("GLD" to 5), null, onResult)
        callbackSlot.captured.onError(error)

        assertThat(errors).containsExactly(error.map())
        assertThat(received).isEmpty()
    }

    private fun assertRejected(amounts: Map<String, Any?>) {
        spendVirtualCurrencies(amounts, null, onResult)

        assertThat(errors).hasSize(1)
        assertThat(errors[0].code).isEqualTo(PurchasesErrorCode.PurchaseInvalidError.code)
        verify(exactly = 0) { mockPurchases.spendVirtualCurrencies(any(), any(), any()) }
    }
}
