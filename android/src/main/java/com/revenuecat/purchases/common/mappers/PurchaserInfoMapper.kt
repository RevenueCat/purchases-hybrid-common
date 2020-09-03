package com.revenuecat.purchases.common.mappers

import com.revenuecat.purchases.PurchaserInfo

fun PurchaserInfo.map(): Map<String, Any?> =
    mapOf(
        "entitlements" to entitlements.map(),
        "activeSubscriptions" to activeSubscriptions.toList(),
        "allPurchasedProductIdentifiers" to allPurchasedSkus.toList(),
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
        "originalPurchaseDateMillis" to originalPurchaseDate?.toMillis()
    )