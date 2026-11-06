@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.CustomerAttribute
import com.revenuecat.purchases.InternalRevenueCatAPI

internal fun CustomerAttribute.map(): Map<String, Any> = mapOf(
    "key" to key,
    "value" to value,
    "lastUpdatedDate" to lastUpdatedDate.toIso8601(),
    "lastUpdatedDateMillis" to lastUpdatedDate.toMillis(),
)
