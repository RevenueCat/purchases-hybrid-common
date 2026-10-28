@file:OptIn(InviteOnlyCheckpointsAPI::class, InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointParams
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointPassedCallback
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowPresentationMode
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowResult
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.checkpoint

/**
 * Experimental. Receives the outcome of [presentCheckpoint].
 */
interface CheckpointListener {
    /**
     * Called at most once, only when the user passes the checkpoint. Backing out of the flow, a blocking failure,
     * or another checkpoint owning presentation never calls it.
     *
     * [result] is `{ customer, flow: { obtainedEntitlements: [{ entitlementInfo }],
     * obtainedProducts: [{ product }] } | null }`.
     */
    fun onCheckpointPassed(result: Map<String, Any?>)

    /**
     * Called when the checkpoint could not be started, e.g. [CheckpointErrorCode.NOT_CONFIGURED].
     */
    fun onCheckpointError(code: String, message: String) {}
}

object CheckpointErrorCode {
    const val NOT_CONFIGURED = "NOT_CONFIGURED"
}

private const val TAG = "Purchases"

/**
 * Experimental, invite-only. Registers that [identifier] was hit, which may present a dashboard-defined flow.
 * Must be called on the main thread. See [CheckpointListener] for when the listener is called.
 *
 * @param presentationMode One of `MODAL_FULL_SCREEN`, `MODAL_SHEET`. Anything else uses the default presentation.
 */
fun presentCheckpoint(
    identifier: String,
    customVariables: Map<String, Any?>? = null,
    presentationMode: String? = null,
    listener: CheckpointListener,
) {
    presentCheckpoint(
        identifier,
        customVariables,
        presentationMode,
        listener,
        isConfigured = { Purchases.isConfigured },
        start = { id, params, callback -> startNativeCheckpoint(id, params, callback) },
    )
}

private fun startNativeCheckpoint(
    identifier: String,
    params: CheckpointParams,
    callback: CheckpointPassedCallback,
) {
    Purchases.sharedInstance.checkpoint(identifier, params, callback)
}

internal fun presentCheckpoint(
    identifier: String,
    customVariables: Map<String, Any?>?,
    presentationMode: String?,
    listener: CheckpointListener,
    isConfigured: () -> Boolean,
    start: (String, CheckpointParams, CheckpointPassedCallback) -> Unit,
) {
    if (!isConfigured()) {
        val message = "Configure Purchases before calling a checkpoint."
        Log.e(TAG, message)
        listener.onCheckpointError(CheckpointErrorCode.NOT_CONFIGURED, message)
        return
    }
    val params = CheckpointParams.Builder()
        .setCustomVariables(customVariables.toCustomVariableValues() ?: emptyMap())
        .setPresentationMode(presentationMode.toFlowPresentationMode())
        .build()
    start(identifier, params) { result ->
        listener.onCheckpointPassed(
            mapOf(
                "customer" to result.customer.map(),
                "flow" to result.flow?.toMap(),
            ),
        )
    }
}

private fun String?.toFlowPresentationMode(): FlowPresentationMode = when (this) {
    "MODAL_FULL_SCREEN" -> FlowPresentationMode.MODAL_FULL_SCREEN
    "MODAL_SHEET" -> FlowPresentationMode.MODAL_SHEET
    else -> FlowPresentationMode.DEFAULT
}

private fun FlowResult.toMap(): Map<String, Any?> = mapOf(
    "obtainedEntitlements" to obtainedEntitlements
        .sortedBy { it.entitlementInfo.identifier }
        .map { mapOf("entitlementInfo" to it.entitlementInfo.map()) },
    "obtainedProducts" to obtainedProducts
        .sortedBy { it.product.id }
        .map { mapOf("product" to it.product.map()) },
)
