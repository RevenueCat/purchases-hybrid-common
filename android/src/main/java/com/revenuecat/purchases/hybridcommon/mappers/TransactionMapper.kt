package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.models.Transaction

fun Transaction.map(): Map<String, Any?> =
    mapOf(
        "revenueCatId" to this.revenuecatId,
        "productId" to this.productId,
        "purchaseDateMillis" to this.purchaseDate.toMillis(),
        "purchaseDate" to this.purchaseDate.toIso8601()
    )