package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.customercenter.CustomerCenterListener
import com.revenuecat.purchases.customercenter.CustomerCenterManagementOption
import com.revenuecat.purchases.hybridcommon.mappers.map

abstract class CustomerCenterListenerWrapper : CustomerCenterListener {

    override fun onFeedbackSurveyCompleted(feedbackSurveyOptionId: String) {
        this.onFeedbackSurveyCompletedWrapper(feedbackSurveyOptionId)
    }

    override fun onRestoreCompleted(customerInfo: CustomerInfo) {
        this.onRestoreCompletedWrapper(customerInfo = customerInfo.map())
    }

    override fun onRestoreFailed(error: PurchasesError) {
        this.onRestoreFailedWrapper(error = error.map().info)
    }

    override fun onRestoreStarted() {
        this.onRestoreStartedWrapper()
    }

    override fun onShowingManageSubscriptions() {
        this.onShowingManageSubscriptionsWrapper()
    }

    override fun onManagementOptionSelected(action: CustomerCenterManagementOption) {
        if (action is CustomerCenterManagementOption.CustomUrl) {
            this.onManagementOptionSelectedWrapper(action.name, action.uri.toString())
        } else {
            this.onManagementOptionSelectedWrapper(action.name, null)
        }
    }

    abstract fun onFeedbackSurveyCompletedWrapper(feedbackSurveyOptionId: String)
    abstract fun onRestoreCompletedWrapper(customerInfo: Map<String, Any?>)
    abstract fun onRestoreFailedWrapper(error: Map<String, Any?>)
    abstract fun onRestoreStartedWrapper()
    abstract fun onShowingManageSubscriptionsWrapper()
    abstract fun onManagementOptionSelectedWrapper(action: String, url: String?)
}

private val CustomerCenterManagementOption.name: String
    get() {
        return when (this) {
            is CustomerCenterManagementOption.Cancel -> "cancel"
            is CustomerCenterManagementOption.MissingPurchase -> "missing_purchase"
            is CustomerCenterManagementOption.CustomUrl -> "custom_url"
            else -> "unknown"
        }
    }
