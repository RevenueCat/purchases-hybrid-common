package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.models.Transaction

fun Transaction.map(): Map<String, Any?> =
    mapOf(
        "transactionIdentifier" to this.revenuecatId,
        // Deprecated: Use transactionIdentifier in this map instead
        "revenueCatId" to this.revenuecatId,
        "productIdentifier" to this.productId,
        // Deprecated: Use productIdentifier in this map instead
        "productId" to this.productId,
        "purchaseDateMillis" to this.purchaseDate.toMillis(),
        "purchaseDate" to this.purchaseDate.toIso8601()
    )