package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.DebugEvent
import com.revenuecat.purchases.InternalRevenueCatAPI

// phc:stable-bridge - established debug event mapping.
@OptIn(InternalRevenueCatAPI::class)
internal fun DebugEvent.toMap(): Map<String, Any?> {
    return mapOf(
        "type" to this.name.name,
    ) + this.properties
}
