@file:OptIn(InviteOnlyCheckpointsAPI::class, InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.ui.revenuecatui.CustomVariableValue
import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointErrorDialog
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointFailureKind
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory.Outcome
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowPresentationMode
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowResult
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.PaywallPresenter

internal fun PaywallPresenter.Params.toHybridMap(offering: Map<String, Any?>): Map<String, Any?> = mapOf(
    "checkpointIdentifier" to checkpointIdentifier,
    "customVariables" to customVariables.mapValues { (_, value) ->
        when (value) {
            is CustomVariableValue.String -> value.value
            is CustomVariableValue.Number -> value.value
            is CustomVariableValue.Boolean -> value.value
            else -> null
        }
    },
    "presentationMode" to when (presentationMode) {
        FlowPresentationMode.MODAL_FULL_SCREEN -> "MODAL_FULL_SCREEN"
        FlowPresentationMode.MODAL_SHEET -> "MODAL_SHEET"
        else -> "DEFAULT"
    },
    "offering" to offering,
)

internal fun Map<String, Any?>?.toCheckpointErrorDialogOutcome(): Outcome {
    if (this == null) return Outcome.UseDefault
    return when (this["type"]) {
        "useDefault" -> Outcome.UseDefault
        "suppress" -> Outcome.Suppress
        "show" -> {
            val dialog = this["dialog"] as? Map<*, *>
            val message = dialog?.get("message") as? String
            val buttonTitle = dialog?.get("buttonTitle") as? String
            if (!message.isNullOrEmpty() && !buttonTitle.isNullOrEmpty()) {
                Outcome.Show(CheckpointErrorDialog(message, buttonTitle))
            } else {
                invalidErrorDialogOutcome()
            }
        }
        else -> invalidErrorDialogOutcome()
    }
}

private fun invalidErrorDialogOutcome(): Outcome {
    Log.w("Purchases", "resolveErrorDialog: invalid outcome; using the SDK's default dialog instead.")
    return Outcome.UseDefault
}

internal fun String?.toFlowPresentationMode(): FlowPresentationMode = when (this) {
    "MODAL_FULL_SCREEN" -> FlowPresentationMode.MODAL_FULL_SCREEN
    "MODAL_SHEET" -> FlowPresentationMode.MODAL_SHEET
    else -> FlowPresentationMode.DEFAULT
}

internal fun FlowResult.toMap(): Map<String, Any?> = mapOf(
    "obtainedEntitlements" to obtainedEntitlements
        .sortedBy { it.entitlementInfo.identifier }
        .map { mapOf("entitlementInfo" to it.entitlementInfo.map()) },
    "obtainedProducts" to obtainedProducts
        .sortedBy { it.product.id }
        .map { mapOf("product" to it.product.map()) },
)

internal fun CheckpointFailureKind.toHybridString(): String = when (this) {
    CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN -> "flowCouldNotBeShown"
    CheckpointFailureKind.FLOW_ACTION_FAILED -> "flowActionFailed"
    CheckpointFailureKind.FLOW_RESULT_SYNC_FAILED -> "flowResultSyncFailed"
    else -> toString()
}
