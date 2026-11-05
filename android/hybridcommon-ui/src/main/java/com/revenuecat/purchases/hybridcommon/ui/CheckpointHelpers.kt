@file:OptIn(InviteOnlyCheckpointsAPI::class, InternalRevenueCatAPI::class)
@file:Suppress("TooManyFunctions")

package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointErrorDialog
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointFailureKind
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointParams
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointPassedCallback
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory.Outcome
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowPresentationMode
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowResult
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.checkpoint
import java.util.UUID
import kotlin.jvm.JvmDefaultWithCompatibility

/** Experimental checkpoint callbacks. */
@JvmDefaultWithCompatibility
interface CheckpointListener {
    /**
     * Called once when the user passes the checkpoint. [result] contains `customer` and `flow`
     * (`obtainedEntitlements` and `obtainedProducts`), or a null `flow`.
     */
    fun onCheckpointPassed(result: Map<String, Any?>)

    /** Called when the checkpoint cannot start, e.g. [CheckpointErrorCode.NOT_CONFIGURED]. */
    fun onCheckpointError(code: String, message: String) {}

    /** Called for requests from the overload with `callId`; resolve [requestId] with [resolveErrorDialog]. */
    fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {}
}

object CheckpointErrorCode {
    const val NOT_CONFIGURED = "NOT_CONFIGURED"
}

private const val TAG = "Purchases"

/**
 * Experimental, invite-only. Registers a checkpoint hit; call on the main thread.
 * `presentationMode` accepts `MODAL_FULL_SCREEN` or `MODAL_SHEET`; other values use the default.
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

/**
 * Experimental, invite-only. Registers a checkpoint with custom error dialogs.
 * `callId` identifies it for request resolution and cancellation.
 */
fun presentCheckpoint(
    identifier: String,
    callId: String,
    customVariables: Map<String, Any?>? = null,
    presentationMode: String? = null,
    listener: CheckpointListener,
) {
    presentCheckpoint(
        identifier,
        callId,
        customVariables,
        presentationMode,
        listener,
        isConfigured = { Purchases.isConfigured },
        start = { id, params, callback -> startNativeCheckpoint(id, params, callback) },
    )
}

/**
 * Resolves a request with `show` (using `dialog.message` and `dialog.buttonTitle`), `useDefault`, or `suppress`.
 * Null or invalid outcomes use the SDK default; unknown request IDs are ignored.
 */
fun resolveErrorDialog(requestId: String, outcome: Map<String, Any?>?) {
    resolveErrorDialog(requestId, outcome, defaultCheckpointErrorDialogRegistry)
}

/**
 * Cancels requests for [callId], or all requests when null. Canceled requests use the SDK default.
 * A call stays detached until it passes; null invalidates all existing factories.
 */
fun cancelErrorDialogs(callId: String?) {
    cancelErrorDialogs(callId, defaultCheckpointErrorDialogRegistry)
}

private fun startNativeCheckpoint(
    identifier: String,
    params: CheckpointParams,
    callback: CheckpointPassedCallback,
) {
    Purchases.sharedInstance.checkpoint(identifier, params, callback)
}

@Suppress("LongParameterList") // isConfigured and start are test seams over the public overload.
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

@Suppress("LongParameterList") // isConfigured, start, and registry are test seams.
internal fun presentCheckpoint(
    identifier: String,
    callId: String,
    customVariables: Map<String, Any?>?,
    presentationMode: String?,
    listener: CheckpointListener,
    isConfigured: () -> Boolean,
    start: (String, CheckpointParams, CheckpointPassedCallback) -> Unit,
    registry: CheckpointErrorDialogRegistry = defaultCheckpointErrorDialogRegistry,
) {
    if (!isConfigured()) {
        val message = "Configure Purchases before calling a checkpoint."
        Log.e(TAG, message)
        listener.onCheckpointError(CheckpointErrorCode.NOT_CONFIGURED, message)
        return
    }
    val generation = registry.generation
    val factory = ErrorDialogFactory { params, completion ->
        val requestId = UUID.randomUUID().toString()
        if (!registry.register(requestId, callId, completion, generation)) {
            return@ErrorDialogFactory
        }
        listener.onErrorDialogRequested(
            requestId,
            mapOf(
                "kind" to params.kind.toHybridString(),
                "code" to params.error.code.code,
                "message" to params.error.message,
            ),
        )
    }
    val checkpointParams = CheckpointParams.Builder()
        .setCustomVariables(customVariables.toCustomVariableValues() ?: emptyMap())
        .setPresentationMode(presentationMode.toFlowPresentationMode())
        .setErrorDialogFactory(factory)
        .build()
    start(identifier, checkpointParams) { result ->
        registry.clearDetached(callId, generation)
        listener.onCheckpointPassed(
            mapOf(
                "customer" to result.customer.map(),
                "flow" to result.flow?.toMap(),
            ),
        )
    }
}

internal fun resolveErrorDialog(
    requestId: String,
    outcome: Map<String, Any?>?,
    registry: CheckpointErrorDialogRegistry,
) {
    val resolved = registry.resolve(requestId, outcome.toCheckpointErrorDialogOutcome())
    if (!resolved) {
        Log.w(TAG, "resolveErrorDialog: unknown or already-resolved requestId '$requestId'; ignoring.")
    }
}

internal fun cancelErrorDialogs(callId: String?, registry: CheckpointErrorDialogRegistry) {
    registry.cancel(callId)
}

private fun Map<String, Any?>?.toCheckpointErrorDialogOutcome(): Outcome {
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
    Log.w(TAG, "resolveErrorDialog: invalid outcome; using the SDK's default dialog instead.")
    return Outcome.UseDefault
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

private fun CheckpointFailureKind.toHybridString(): String = when (this) {
    CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN -> "flowCouldNotBeShown"
    CheckpointFailureKind.FLOW_ACTION_FAILED -> "flowActionFailed"
    CheckpointFailureKind.FLOW_RESULT_SYNC_FAILED -> "flowResultSyncFailed"
    else -> toString()
}
