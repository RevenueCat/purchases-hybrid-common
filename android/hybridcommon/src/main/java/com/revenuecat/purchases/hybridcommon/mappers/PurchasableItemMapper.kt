package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.hybridcommon.PurchasableItem
import kotlin.collections.get

internal fun PurchasableItem.Product.Companion.fromMap(
    map: Map<*, *>
): PurchasableItem.Product? {
    val productIdentifier = map["productIdentifier"] as? String
    val type = map["type"] as? String
    val googleBasePlanId = map["googleBasePlanId"] as? String

    if (productIdentifier.isNullOrBlank() || type.isNullOrBlank()) {
        return null
    }

    return PurchasableItem.Product(
        productIdentifier = productIdentifier,
        type = type,
        googleBasePlanId = googleBasePlanId
    )
}
