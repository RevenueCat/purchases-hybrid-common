@file:OptIn(InviteOnlyCheckpointsAPI::class, InternalRevenueCatAPI::class)
@file:Suppress("TooManyFunctions")

package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.hybridcommon.mappers.mapAsync
import com.revenuecat.purchases.ui.revenuecatui.CustomVariableValue
import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointErrorDialog
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointFailureKind
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointParams
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointPassedCallback
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory.Outcome
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowPresentationMode
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowResult
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.PaywallPresenter
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

    /** Called when `hasErrorDialogFactory` is enabled; resolve [requestId] with [resolveErrorDialog]. */
    fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {}

    /** Called only when custom presentation was requested; complete it with [completePaywallPresentation]. */
    fun onPaywallPresentationRequested(requestId: String, params: Map<String, Any?>) {}
}

object CheckpointErrorCode {
    const val NOT_CONFIGURED = "NOT_CONFIGURED"
}

private const val TAG = "Purchases"

/**
 * Experimental, invite-only. Registers a checkpoint hit; call on the main thread.
 * [presentationMode] accepts `MODAL_FULL_SCREEN` or `MODAL_SHEET`; other values use the default.
 * Supports independently optional app-owned paywall and error-dialog callbacks.
 * Use a unique [callId] for each invocation. When [useCustomPaywallPresenter] is true,
 * implement [CheckpointListener.onPaywallPresentationRequested] and complete every delivered presentation after
 * dismissing its UI. Otherwise the native SDK presents paywalls. [hasErrorDialogFactory] independently enables
 * [CheckpointListener.onErrorDialogRequested], including synchronization errors after custom paywall completion.
 */
@Suppress("LongParameterList") // Paywall presentation and error dialogs are independently optional.
fun presentCheckpoint(
    identifier: String,
    callId: String,
    customVariables: Map<String, Any?>? = null,
    presentationMode: String? = null,
    useCustomPaywallPresenter: Boolean = false,
    hasErrorDialogFactory: Boolean = false,
    listener: CheckpointListener,
) {
    presentCheckpoint(
        identifier,
        callId,
        customVariables,
        presentationMode,
        useCustomPaywallPresenter,
        hasErrorDialogFactory,
        listener,
        isConfigured = { Purchases.isConfigured },
        start = { id, params, callback -> startNativeCheckpoint(id, params, callback) },
        registry = defaultCheckpointErrorDialogRegistry,
        paywallRegistry = defaultCheckpointPaywallRegistry,
    )
}

/**
 * Reports CONTINUED or CLOSED to continue through native purchase synchronization, or NAVIGATED_BACK to back out.
 * Unrecognized outcomes back out; repeated or unknown request IDs are ignored. Call on the main thread.
 */
fun completePaywallPresentation(requestId: String, result: String) {
    completePaywallPresentation(requestId, result, defaultCheckpointPaywallRegistry)
}

/**
 * Detaches both callback protocols. Preserve only the [activePaywallRequestId] whose app-owned handler actually ran;
 * its UI stays open and must still complete after dismissal. Null cancels queued presentations as well as late
 * native requests. Pending and future errors use default dialogs. Call on the main thread.
 */
fun detachCheckpoint(callId: String, activePaywallRequestId: String?) {
    detachCheckpoint(
        callId,
        activePaywallRequestId,
        defaultCheckpointErrorDialogRegistry,
        defaultCheckpointPaywallRegistry,
    )
}

/**
 * Invalidates both protocols on runtime teardown. Pending paywalls back out and dialogs use defaults. Captured old
 * calls stay detached, including late native callbacks; new calls work normally. Call on the main thread.
 */
fun invalidateCheckpointPresentations() {
    invalidateCheckpointPresentations(defaultCheckpointErrorDialogRegistry, defaultCheckpointPaywallRegistry)
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

@Suppress("LongParameterList") // isConfigured, start, and registries are test seams.
internal fun presentCheckpoint(
    identifier: String,
    callId: String,
    customVariables: Map<String, Any?>?,
    presentationMode: String?,
    useCustomPaywallPresenter: Boolean,
    hasErrorDialogFactory: Boolean,
    listener: CheckpointListener,
    isConfigured: () -> Boolean,
    start: (String, CheckpointParams, CheckpointPassedCallback) -> Unit,
    registry: CheckpointErrorDialogRegistry,
    paywallRegistry: CheckpointPaywallRegistry,
) {
    if (!isConfigured()) {
        val message = "Configure Purchases before calling a checkpoint."
        Log.e(TAG, message)
        listener.onCheckpointError(CheckpointErrorCode.NOT_CONFIGURED, message)
        return
    }
    val call = paywallRegistry.begin(callId)
    val generation = registry.generation
    val builder = CheckpointParams.Builder()
        .setCustomVariables(customVariables.toCustomVariableValues() ?: emptyMap())
        .setPresentationMode(presentationMode.toFlowPresentationMode())
    if (hasErrorDialogFactory) {
        builder.setErrorDialogFactory(createErrorDialogFactory(callId, generation, listener, registry))
    }
    if (useCustomPaywallPresenter) {
        builder.setPaywallPresenter(
            PaywallPresenter { params, completion ->
                val requestId = UUID.randomUUID().toString()
                if (paywallRegistry.register(requestId, call, completion)) {
                    params.offering.mapAsync { offering ->
                        // Mapping happens asynchronously. Teardown may have already completed the native request.
                        if (paywallRegistry.isPending(requestId)) {
                            listener.onPaywallPresentationRequested(requestId, params.toHybridMap(offering))
                        }
                    }
                }
            },
        )
    }
    start(identifier, builder.build()) { result ->
        if (paywallRegistry.isAttached(call)) {
            paywallRegistry.finish(call)
            registry.clearDetached(callId, generation)
            listener.onCheckpointPassed(
                mapOf("customer" to result.customer.map(), "flow" to result.flow?.toMap()),
            )
        }
    }
}

private fun createErrorDialogFactory(
    callId: String,
    generation: Long,
    listener: CheckpointListener,
    registry: CheckpointErrorDialogRegistry,
): ErrorDialogFactory {
    return ErrorDialogFactory { params, completion ->
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
}

internal fun completePaywallPresentation(requestId: String, result: String, registry: CheckpointPaywallRegistry) {
    val outcome = when (result) {
        "CONTINUED" -> PaywallPresenter.Completion.Result.Continued
        "CLOSED" -> PaywallPresenter.Completion.Result.Closed
        else -> PaywallPresenter.Completion.Result.NavigatedBack
    }
    registry.resolve(requestId, outcome)
}

internal fun detachCheckpoint(
    callId: String,
    activePaywallRequestId: String?,
    errors: CheckpointErrorDialogRegistry,
    paywalls: CheckpointPaywallRegistry,
) {
    val errorCompletions = errors.takeCancelled(callId)
    paywalls.detach(callId, activePaywallRequestId)
    errorCompletions.forEach { it.complete(Outcome.UseDefault) }
}

internal fun invalidateCheckpointPresentations(
    errors: CheckpointErrorDialogRegistry,
    paywalls: CheckpointPaywallRegistry,
) {
    // Invalidate both generations before completing requests, which may start work for a new runtime.
    val errorCompletions = errors.takeCancelled(null)
    val paywallCompletions = paywalls.takePendingOnInvalidation()
    errorCompletions.forEach { it.complete(Outcome.UseDefault) }
    paywallCompletions.forEach { it.complete(PaywallPresenter.Completion.Result.NavigatedBack) }
}

private fun PaywallPresenter.Params.toHybridMap(offering: Map<String, Any?>): Map<String, Any?> = mapOf(
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
