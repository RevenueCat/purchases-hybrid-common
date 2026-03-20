package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.customercenter.CustomerCenterManagementOption
import com.revenuecat.purchases.models.StoreTransaction
import io.mockk.every
import io.mockk.mockk
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class CustomerCenterListenerWrapperTest {

    @Test
    fun `onPromotionalOfferSucceeded extracts offerId from subscriptionOptionId`() {
        val listener = TestCustomerCenterListenerWrapper()
        val customerInfo = mockk<CustomerInfo>(relaxed = true)
        val transaction = createMockTransaction(subscriptionOptionId = "monthly:rc-cancel-offer")

        listener.onPromotionalOfferSucceeded(customerInfo, transaction)

        assertTrue(listener.promotionalOfferSucceededInvoked)
        assertEquals("rc-cancel-offer", listener.lastOfferId)
    }

    @Test
    fun `onPromotionalOfferSucceeded returns null offerId when no offer in subscriptionOptionId`() {
        val listener = TestCustomerCenterListenerWrapper()
        val customerInfo = mockk<CustomerInfo>(relaxed = true)
        val transaction = createMockTransaction(subscriptionOptionId = "monthly")

        listener.onPromotionalOfferSucceeded(customerInfo, transaction)

        assertTrue(listener.promotionalOfferSucceededInvoked)
        assertNull(listener.lastOfferId)
    }

    @Test
    fun `onPromotionalOfferSucceeded returns null offerId when subscriptionOptionId is null`() {
        val listener = TestCustomerCenterListenerWrapper()
        val customerInfo = mockk<CustomerInfo>(relaxed = true)
        val transaction = createMockTransaction(subscriptionOptionId = null)

        listener.onPromotionalOfferSucceeded(customerInfo, transaction)

        assertTrue(listener.promotionalOfferSucceededInvoked)
        assertNull(listener.lastOfferId)
    }

    private fun createMockTransaction(subscriptionOptionId: String?): StoreTransaction {
        return mockk<StoreTransaction>(relaxed = true) {
            every { this@mockk.subscriptionOptionId } returns subscriptionOptionId
            every { productIds } returns listOf("paywall_tester.subs")
            every { purchaseTime } returns 1774013027784L
            every { purchaseToken } returns "test-token"
            every { orderId } returns "GPA.1234"
            every { originalJson } returns JSONObject()
        }
    }

    @Test
    fun `onManagementOptionSelected triggers custom action callback`() {
        val listener = TestCustomerCenterListenerWrapper()

        val action = CustomerCenterManagementOption.CustomAction(
            actionIdentifier = "custom_action_id",
            purchaseIdentifier = "product_id",
        )

        listener.onManagementOptionSelected(action)

        assertTrue(listener.customActionInvoked)
        assertEquals("custom_action_id", listener.lastActionId)
        assertEquals("product_id", listener.lastPurchaseIdentifier)

        // Ensure the deprecated method remains invoked for backwards compatibility until removal.
        assertTrue(listener.deprecatedCustomActionInvoked)
    }

    private class TestCustomerCenterListenerWrapper : CustomerCenterListenerWrapper() {
        var customActionInvoked: Boolean = false
        var deprecatedCustomActionInvoked: Boolean = false
        var lastActionId: String? = null
        var lastPurchaseIdentifier: String? = null
        var promotionalOfferSucceededInvoked: Boolean = false
        var lastCustomerInfo: Map<String, Any?>? = null
        var lastTransaction: Map<String, Any?>? = null
        var lastOfferId: String? = null

        override fun onFeedbackSurveyCompletedWrapper(feedbackSurveyOptionId: String) = Unit

        override fun onRestoreCompletedWrapper(customerInfo: Map<String, Any?>) = Unit

        override fun onRestoreFailedWrapper(error: Map<String, Any?>) = Unit

        override fun onRestoreStartedWrapper() = Unit

        override fun onShowingManageSubscriptionsWrapper() = Unit

        override fun onManagementOptionSelectedWrapper(action: String, url: String?) = Unit

        @Deprecated("Use onCustomActionSelectedWrapper instead.")
        override fun onManagementOptionSelectedWrapper(
            action: String,
            customAction: String?,
            purchaseIdentifier: String?,
        ) {
            deprecatedCustomActionInvoked = true
        }

        override fun onCustomActionSelectedWrapper(
            actionId: String,
            purchaseIdentifier: String?,
        ) {
            customActionInvoked = true
            lastActionId = actionId
            lastPurchaseIdentifier = purchaseIdentifier
        }

        override fun onPromotionalOfferSucceededWrapper(
            customerInfo: Map<String, Any?>,
            transaction: Map<String, Any?>,
            offerId: String?,
        ) {
            promotionalOfferSucceededInvoked = true
            lastCustomerInfo = customerInfo
            lastTransaction = transaction
            lastOfferId = offerId
        }
    }
}
