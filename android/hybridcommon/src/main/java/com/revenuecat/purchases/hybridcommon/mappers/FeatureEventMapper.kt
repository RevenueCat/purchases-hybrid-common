package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.common.events.FeatureEvent
import com.revenuecat.purchases.customercenter.events.CustomerCenterImpressionEvent
import com.revenuecat.purchases.customercenter.events.CustomerCenterSurveyOptionChosenEvent
import com.revenuecat.purchases.paywalls.events.PaywallEvent

@OptIn(InternalRevenueCatAPI::class)
fun FeatureEvent.toMap(): Map<String, Any?> {
    return when (this) {
        is PaywallEvent -> mapOf(
            "discriminator" to "paywalls",
            "type" to type.value,
            "id" to creationData.id.toString(),
            "timestamp" to creationData.date.time,
            "offering_id" to data.offeringIdentifier,
            "paywall_revision" to data.paywallRevision,
            "session_id" to data.sessionIdentifier.toString(),
            "display_mode" to data.displayMode,
            "locale" to data.localeIdentifier,
            "dark_mode" to data.darkMode,
        )
        is CustomerCenterImpressionEvent -> mapOf(
            "discriminator" to "customer_center",
            "type" to "customer_center_impression",
            "id" to creationData.id.toString(),
            "timestamp" to creationData.date.time,
            "dark_mode" to data.darkMode,
            "locale" to data.locale,
            "display_mode" to data.displayMode.name,
            "revision_id" to data.revisionID,
        )
        is CustomerCenterSurveyOptionChosenEvent -> mapOf(
            "discriminator" to "customer_center",
            "type" to "customer_center_survey_option_chosen",
            "id" to creationData.id.toString(),
            "timestamp" to creationData.date.time,
            "dark_mode" to data.darkMode,
            "locale" to data.locale,
            "display_mode" to data.displayMode.name,
            "survey_option_id" to data.surveyOptionID,
            "path" to data.path.name,
            "url" to data.url,
            "revision_id" to data.revisionID,
        )
        else -> mapOf(
            "discriminator" to "unknown",
            "type" to "unknown",
            "class_name" to this::class.simpleName,
        )
    }
}
