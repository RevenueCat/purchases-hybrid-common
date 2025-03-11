package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.customercenter.CustomerCenterListener
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

    abstract fun onFeedbackSurveyCompletedWrapper(feedbackSurveyOptionId: String)
    abstract fun onRestoreCompletedWrapper(customerInfo: Map<String, Any?>)
    abstract fun onRestoreFailedWrapper(error: Map<String, Any?>)
    abstract fun onRestoreStartedWrapper()
    abstract fun onShowingManageSubscriptionsWrapper()
}
