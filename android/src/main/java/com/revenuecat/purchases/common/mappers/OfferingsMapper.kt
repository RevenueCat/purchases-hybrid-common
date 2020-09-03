package com.revenuecat.purchases.common.mappers

import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.Package

fun Offerings.map(): Map<String, Any?> =
    mapOf(
        "all" to this.all.mapValues { it.value.map() },
        "current" to this.current?.map()
    )

private fun Offering.map(): Map<String, Any?> =
    mapOf(
        "identifier" to identifier,
        "serverDescription" to serverDescription,
        "availablePackages" to availablePackages.map { it.map(identifier) },
        "lifetime" to lifetime?.map(identifier),
        "annual" to annual?.map(identifier),
        "sixMonth" to sixMonth?.map(identifier),
        "threeMonth" to threeMonth?.map(identifier),
        "twoMonth" to twoMonth?.map(identifier),
        "monthly" to monthly?.map(identifier),
        "weekly" to weekly?.map(identifier)
    )

private fun Package.map(offeringIdentifier: String): Map<String, Any?> =
    mapOf(
        "identifier" to identifier,
        "packageType" to packageType.name,
        "product" to product.map(),
        "offeringIdentifier" to offeringIdentifier
    )
