@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointErrorDialog
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import java.util.Collections
import java.util.concurrent.ConcurrentHashMap

internal val defaultCheckpointErrorDialogRegistry = CheckpointErrorDialogRegistry()

/**
 * Tracks pending [ErrorDialogFactory.Completion] instances keyed by unique request IDs.
 *
 * Each pending entry also records the [callId] supplied by the hybrid layer, so that entries
 * can be bulk-cancelled when a call ends or the JS runtime is invalidated. Cancelled call IDs
 * are marked "detached" so that any later errors for them are silently completed with null
 * instead of reaching the hybrid handler.
 */
internal class CheckpointErrorDialogRegistry {

    private data class PendingRequest(
        val callId: String,
        val completion: ErrorDialogFactory.Completion,
    )

    private val pending = ConcurrentHashMap<String, PendingRequest>()
    private val detachedCallIds: MutableSet<String> =
        Collections.newSetFromMap(ConcurrentHashMap())

    /** Returns true when [callId] has been marked detached via [cancel]. */
    fun isDetached(callId: String): Boolean = callId in detachedCallIds

    /** Stores a pending [completion] for later resolution via [resolve]. */
    fun register(requestId: String, callId: String, completion: ErrorDialogFactory.Completion) {
        pending[requestId] = PendingRequest(callId, completion)
    }

    /**
     * Removes and completes the pending entry for [requestId] with [dialog].
     * Returns true when found, false when unknown or already resolved (ignored).
     */
    fun resolve(requestId: String, dialog: CheckpointErrorDialog?): Boolean {
        val request = pending.remove(requestId) ?: return false
        request.completion.complete(dialog)
        return true
    }

    /**
     * Cancels and marks detached all pending requests for [callId].
     * When [callId] is null, all pending requests are cancelled and all their call IDs are
     * marked detached. Subsequent [isDetached] checks for those call IDs return true.
     */
    fun cancel(callId: String?) {
        if (callId == null) {
            val snapshot = pending.toMap()
            pending.clear()
            snapshot.values.forEach { req ->
                detachedCallIds.add(req.callId)
                req.completion.complete(null)
            }
        } else {
            detachedCallIds.add(callId)
            val keys = pending.entries
                .filter { it.value.callId == callId }
                .map { it.key }
            keys.forEach { key -> pending.remove(key)?.completion?.complete(null) }
        }
    }

    /**
     * Removes the detached marker for [callId], allowing future requests to reach the handler again.
     * Called when the checkpoint for [callId] passes successfully.
     */
    fun clearDetached(callId: String) {
        detachedCallIds.remove(callId)
    }
}
