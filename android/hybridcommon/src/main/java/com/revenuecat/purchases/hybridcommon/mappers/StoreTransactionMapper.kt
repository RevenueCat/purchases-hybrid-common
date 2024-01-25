package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.models.StoreTransaction
import java.util.Date

fun StoreTransaction.map(): Map<String, Any?> =
    mapOf(
        "transactionIdentifier" to this.orderId,
        "productIdentifier" to this.productIds.first(),
        "purchaseDateMillis" to this.purchaseTime,
        "purchaseDate" to Date(this.purchaseTime).toIso8601(),
    )
