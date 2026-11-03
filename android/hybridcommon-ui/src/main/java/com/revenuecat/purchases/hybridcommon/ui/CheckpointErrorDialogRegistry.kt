@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory.Outcome
import java.util.Collections
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

internal val defaultCheckpointErrorDialogRegistry = CheckpointErrorDialogRegistry()

/**
 * Tracks pending [ErrorDialogFactory.Completion] instances keyed by unique request IDs.
 *
 * Each pending entry also records the [callId] supplied by the hybrid layer, so that entries
 * can be bulk-cancelled when a call ends or the JS runtime is invalidated. Cancelled call IDs
 * are marked "detached" so that any later errors for them are silently completed with UseDefault
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

    private val currentGeneration = AtomicLong()

    /** Captured by each factory so global cancellation also detaches calls without pending errors. */
    val generation: Long get() = currentGeneration.get()

    /** Returns true when the factory's generation or [callId] has been detached via [cancel]. */
    fun isDetached(callId: String, generation: Long = this.generation): Boolean =
        generation != this.generation || callId in detachedCallIds

    /** Stores a pending [completion] for later resolution via [resolve]. */
    fun register(requestId: String, callId: String, completion: ErrorDialogFactory.Completion) {
        pending[requestId] = PendingRequest(callId, completion)
    }

    /**
     * Removes and completes the pending entry for [requestId] with [outcome].
     * Returns true when found, false when unknown or already resolved (ignored).
     */
    fun resolve(requestId: String, outcome: Outcome): Boolean {
        val request = pending.remove(requestId) ?: return false
        request.completion.complete(outcome)
        return true
    }

    /**
     * Cancels and marks detached all pending requests for [callId].
     * When [callId] is null, all existing factory generations are detached and all pending
     * requests are cancelled. New factories can reach the hybrid handler again.
     */
    fun cancel(callId: String?) {
        if (callId == null) {
            currentGeneration.incrementAndGet()
            detachedCallIds.clear()
            val snapshot = pending.toMap()
            pending.clear()
            snapshot.values.forEach { req ->
                req.completion.complete(Outcome.UseDefault)
            }
        } else {
            detachedCallIds.add(callId)
            val keys = pending.entries
                .filter { it.value.callId == callId }
                .map { it.key }
            keys.forEach { key -> pending.remove(key)?.completion?.complete(Outcome.UseDefault) }
        }
    }

    /**
     * Removes the detached marker for [callId], allowing future requests to reach the handler again.
     * Called when the checkpoint for [callId] passes successfully. Older factory generations
     * cannot clear cancellation markers belonging to the current runtime.
     */
    fun clearDetached(callId: String, generation: Long = this.generation) {
        if (generation == this.generation) {
            detachedCallIds.remove(callId)
        }
    }
}
