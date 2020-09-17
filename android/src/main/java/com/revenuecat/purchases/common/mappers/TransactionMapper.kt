package com.revenuecat.purchases.common.mappers

import com.revenuecat.purchases.models.Transaction

fun Transaction.map(): Map<String, Any?> =
    mapOf(
        "revenuecatId" to this.revenuecatId,
        "productId" to this.productId,
        "purchaseDateMillis" to this.purchaseDate.toMillis(),
        "purchaseDate" to this.purchaseDate.toIso8601()
    )