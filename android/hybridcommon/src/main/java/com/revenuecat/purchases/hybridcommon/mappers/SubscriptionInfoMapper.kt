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
        "originalPurchaseDate" to originalPurchaseDate?.toIso8601(),
        "expiresDate" to expiresDate?.toIso8601(),
        "store" to store.name,
        "unsubscribeDetectedAt" to unsubscribeDetectedAt?.toIso8601(),
        "isSandbox" to isSandbox,
        "billingIssuesDetectedAt" to billingIssuesDetectedAt?.toIso8601(),
        "gracePeriodExpiresDate" to gracePeriodExpiresDate?.toIso8601(),
        "ownershipType" to ownershipType.name,
        "periodType" to periodType.name,
        "refundedAt" to refundedAt?.toIso8601(),
        "storeTransactionId" to storeTransactionId,
        "autoResumeDate" to autoResumeDate?.toIso8601(),
        "price" to priceObject,
        "productPlanIdentifier" to productPlanIdentifier,
        "managementURL" to managementURL?.toString(),
        "isActive" to isActive,
        "willRenew" to willRenew,
    )
}
