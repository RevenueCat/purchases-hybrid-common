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
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowPresentationMode
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowResult
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.checkpoint
import java.util.UUID

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

    /**
     * Called when the native SDK needs custom error-dialog content for a checkpoint error.
     * Only called when [presentCheckpoint] was invoked with a [callId].
     * Respond by calling [resolveErrorDialog] with the [requestId] and optional dialog content.
     *
     * [error] is `{ kind: String, code: Int, message: String }` where [kind] is one of
     * `"flowCouldNotBeShown"`, `"flowActionFailed"`, or `"flowResultSyncFailed"`.
     */
    fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {}
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

/**
 * Experimental, invite-only. Registers that [identifier] was hit with error-dialog-factory support.
 * [callId] identifies this call for [resolveErrorDialog] and [cancelErrorDialogs].
 *
 * When a checkpoint error occurs and the SDK needs dialog content, [CheckpointListener.onErrorDialogRequested]
 * is called with a unique [requestId]. Respond by calling [resolveErrorDialog] to supply custom dialog content
 * or null to use the SDK's own localized copy.
 *
 * Must be called on the main thread. See [CheckpointListener] for when the listener is called.
 *
 * @param presentationMode One of `MODAL_FULL_SCREEN`, `MODAL_SHEET`. Anything else uses the default presentation.
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
 * Resolves a pending error-dialog request created by [presentCheckpoint] (the overload with a `callId`).
 *
 * [dialog] may contain `message` and `buttonTitle` string entries to supply custom dialog content,
 * or be null to let the SDK use its own localized copy. Invalid entries (non-string values) are
 * logged and treated as null. Unknown or already-resolved [requestId]s are silently ignored.
 */
fun resolveErrorDialog(requestId: String, dialog: Map<String, Any?>?) {
    resolveErrorDialog(requestId, dialog, defaultCheckpointErrorDialogRegistry)
}

/**
 * Cancels pending error-dialog requests.
 *
 * When [callId] is non-null, only requests for that call are cancelled and the call is marked
 * detached — future errors for it silently complete with null without calling the handler.
 * When [callId] is null, all pending requests are cancelled and all their call IDs are marked
 * detached. Use null when the JS runtime is invalidated.
 *
 * The detached marker for a call is cleared when that call's [CheckpointListener.onCheckpointPassed] fires.
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
    val factory = ErrorDialogFactory { params, completion ->
        if (registry.isDetached(callId)) {
            completion.complete(null)
            return@ErrorDialogFactory
        }
        val requestId = UUID.randomUUID().toString()
        registry.register(requestId, callId, completion)
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
        registry.clearDetached(callId)
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
    dialog: Map<String, Any?>?,
    registry: CheckpointErrorDialogRegistry,
) {
    val resolved = registry.resolve(requestId, dialog.toCheckpointErrorDialog())
    if (!resolved) {
        Log.w(TAG, "resolveErrorDialog: unknown or already-resolved requestId '$requestId'; ignoring.")
    }
}

internal fun cancelErrorDialogs(callId: String?, registry: CheckpointErrorDialogRegistry) {
    registry.cancel(callId)
}

private fun Map<String, Any?>?.toCheckpointErrorDialog(): CheckpointErrorDialog? {
    if (this == null) return null
    val message = this["message"]
    val buttonTitle = this["buttonTitle"]
    return if (message is String && buttonTitle is String) {
        CheckpointErrorDialog(message, buttonTitle)
    } else {
        Log.w(
            TAG,
            "resolveErrorDialog: 'message' and 'buttonTitle' must be non-null strings; " +
                "using the SDK's default dialog instead.",
        )
        null
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

private fun CheckpointFailureKind.toHybridString(): String = when (this) {
    CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN -> "flowCouldNotBeShown"
    CheckpointFailureKind.FLOW_ACTION_FAILED -> "flowActionFailed"
    CheckpointFailureKind.FLOW_RESULT_SYNC_FAILED -> "flowResultSyncFailed"
    else -> toString()
}
