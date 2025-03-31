@file:OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)

package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI

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
        "virtualCurrencies" to virtualCurrencies.mapValues { it.value.map() },
    )
