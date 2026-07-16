package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.InternalRevenueCatAPI
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

// phc:stable-bridge - foundational CustomerInfo mapping, used throughout the bridge.
@OptIn(InternalRevenueCatAPI::class)
fun CustomerInfo.map(): Map<String, Any?> =
    mapOf(
        "entitlements" to entitlements.map(),
        "activeSubscriptions" to activeSubscriptions.toList(),
        "allPurchasedProductIdentifiers" to allPurchasedProductIds.toList(),
        "latestExpirationDate" to latestExpirationDate?.toIso8601(),
        "latestExpirationDateMillis" to latestExpirationDate?.toMillis(),
        "firstSeen" to firstSeen.toIso8601(),
        "firstSeenMillis" to firstSeen.toMillis(),
        "originalAppUserId" to originalAppUserId,
        "requestDate" to requestDate.toIso8601(),
        "requestDateMillis" to requestDate.toMillis(),
        "allExpirationDates" to allExpirationDatesByProduct.mapValues { it.value?.toIso8601() },
        "allExpirationDatesMillis" to allExpirationDatesByProduct.mapValues { it.value?.toMillis() },
        "allPurchaseDates" to allPurchaseDatesByProduct.mapValues { it.value?.toIso8601() },
        "allPurchaseDatesMillis" to allPurchaseDatesByProduct.mapValues { it.value?.toMillis() },
        "originalApplicationVersion" to null,
        "managementURL" to managementURL?.toString(),
        "originalPurchaseDate" to originalPurchaseDate?.toIso8601(),
        "originalPurchaseDateMillis" to originalPurchaseDate?.toMillis(),
        "nonSubscriptionTransactions" to nonSubscriptionTransactions.map { it.map() },
        "subscriptionsByProductIdentifier" to subscriptionsByProductIdentifier.mapValues { it.value.map() },
    )

// phc:stable-bridge - foundational CustomerInfo mapping, same as CustomerInfo.map() above.
@OptIn(InternalRevenueCatAPI::class)
fun CustomerInfo.mapAsync(
    callback: (Map<String, Any?>) -> Unit,
) {
    mainScope.launch {
        val map = withContext(mapperDispatcher) { map() }
        callback(map)
    }
}
