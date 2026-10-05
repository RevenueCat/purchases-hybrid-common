package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.ui.revenuecatui.PaywallInteractionEvent
import io.mockk.every
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Test

class PaywallListenerWrapperTest {

    @Test
    fun `onInteraction forwards the raw properties map`() {
        val listener = TestPaywallListenerWrapper()
        val rawProperties = mapOf("component_type" to "tab", "origin_index" to 0, "dark_mode" to true)
        val event: PaywallInteractionEvent = mockk {
            every { this@mockk.rawProperties } returns rawProperties
        }

        listener.onInteraction(event)

        assertEquals(listOf(rawProperties), listener.interactions)
    }

    private class TestPaywallListenerWrapper : PaywallListenerWrapper() {
        val interactions = mutableListOf<Map<String, Any>>()

        override fun onInteraction(event: Map<String, Any>) {
            interactions += event
        }

        override fun onPurchaseStarted(rcPackage: Map<String, Any?>) = Unit
        override fun onPurchaseCompleted(customerInfo: Map<String, Any?>, storeTransaction: Map<String, Any?>) = Unit
        override fun onPurchaseError(error: Map<String, Any?>) = Unit
        override fun onRestoreCompleted(customerInfo: Map<String, Any?>) = Unit
        override fun onRestoreError(error: Map<String, Any?>) = Unit
    }
}
