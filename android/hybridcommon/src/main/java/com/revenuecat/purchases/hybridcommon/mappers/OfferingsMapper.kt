package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PresentedOfferingContext

fun Offerings.map(): Map<String, Any?> =
    mapOf(
        "all" to this.all.mapValues { it.value.map() },
        "current" to this.current?.map(),
    )

fun Offering.map(): Map<String, Any?> =
    mapOf(
        "identifier" to identifier,
        "serverDescription" to serverDescription,
        "metadata" to metadata,
        "availablePackages" to availablePackages.map { it.map() },
        "lifetime" to lifetime?.map(),
        "annual" to annual?.map(),
        "sixMonth" to sixMonth?.map(),
        "threeMonth" to threeMonth?.map(),
        "twoMonth" to twoMonth?.map(),
        "monthly" to monthly?.map(),
        "weekly" to weekly?.map(),
    )

fun Package.map(): Map<String, Any?> =
    mapOf(
        "identifier" to identifier,
        "packageType" to packageType.name,
        "product" to product.map(),
        "offeringIdentifier" to presentedOfferingContext.offeringIdentifier,
        "presentedOfferingContext" to presentedOfferingContext.map(),
    )

fun PresentedOfferingContext.map(): Map<String, Any?> =
    mapOf(
        "offeringIdentifier" to offeringIdentifier,
        "placementIdentifier" to placementIdentifier,
        "targetingRevision" to targetingContext?.revision,
        "targetingRuleId" to targetingContext?.ruleId,
    )
