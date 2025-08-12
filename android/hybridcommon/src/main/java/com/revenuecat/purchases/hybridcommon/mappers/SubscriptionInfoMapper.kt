package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.SubscriptionInfo

fun SubscriptionInfo.map(): Map<String, Any?> {
    var priceObject: Map<String, Any>? = null
    price?.let {
        priceObject = mapOf(
            "currency" to it.currencyCode,
            "amount" to (it.amountMicros.toDouble() / 1_000_000.0),
            "formatted" to it.formatted,
        )
    }

    return mapOf(
        "productIdentifier" to productIdentifier,
        "purchaseDate" to purchaseDate.toIso8601(),
        "purchaseDateMillis" to purchaseDate.toMillis(),
        "originalPurchaseDate" to originalPurchaseDate?.toIso8601(),
        "originalPurchaseDateMillis" to originalPurchaseDate?.toMillis(),
        "expiresDate" to expiresDate?.toIso8601(),
        "expiresDateMillis" to expiresDate?.toMillis(),
        "store" to store.name,
        "unsubscribeDetectedAt" to unsubscribeDetectedAt?.toIso8601(),
        "unsubscribeDetectedAtMillis" to unsubscribeDetectedAt?.toMillis(),
        "isSandbox" to isSandbox,
        "billingIssuesDetectedAt" to billingIssuesDetectedAt?.toIso8601(),
        "billingIssuesDetectedAtMillis" to billingIssuesDetectedAt?.toMillis(),
        "gracePeriodExpiresDate" to gracePeriodExpiresDate?.toIso8601(),
        "gracePeriodExpiresDateMillis" to gracePeriodExpiresDate?.toMillis(),
        "ownershipType" to ownershipType.name,
        "periodType" to periodType.name,
        "refundedAt" to refundedAt?.toIso8601(),
        "refundedAtMillis" to refundedAt?.toMillis(),
        "storeTransactionId" to storeTransactionId,
        "autoResumeDate" to autoResumeDate?.toIso8601(),
        "autoResumeDateMillis" to autoResumeDate?.toMillis(),
        "price" to priceObject,
        "productPlanIdentifier" to productPlanIdentifier,
        "managementURL" to managementURL?.toString(),
        "isActive" to isActive,
        "willRenew" to willRenew,
    )
}
