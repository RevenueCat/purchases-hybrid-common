package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.customercenter.CustomerCenterManagementOption
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class CustomerCenterListenerWrapperTest {

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
    }
}
