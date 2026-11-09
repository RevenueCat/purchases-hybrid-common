@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory.Outcome

internal val defaultCheckpointErrorDialogRegistry = CheckpointErrorDialogRegistry()

/** Tracks pending dialog requests and detached calls. */
internal class CheckpointErrorDialogRegistry {

    private data class PendingRequest(
        val callId: String,
        val completion: ErrorDialogFactory.Completion,
    )

    private val lock = Any()
    private val pending = mutableMapOf<String, PendingRequest>()
    private val detachedCallIds = mutableSetOf<String>()
    private var currentGeneration = 0L

    /** Factories use this to detect global cancellation. */
    val generation: Long get() = synchronized(lock) { currentGeneration }

    fun isDetached(callId: String, generation: Long = this.generation): Boolean =
        synchronized(lock) { generation != currentGeneration || callId in detachedCallIds }

    /** Atomically rejects requests from detached factories. Completions run outside the lock. */
    fun register(
        requestId: String,
        callId: String,
        completion: ErrorDialogFactory.Completion,
        generation: Long = this.generation,
    ): Boolean {
        val registered = synchronized(lock) {
            if (generation != currentGeneration || callId in detachedCallIds) {
                false
            } else {
                pending[requestId] = PendingRequest(callId, completion)
                true
            }
        }
        if (!registered) completion.complete(Outcome.UseDefault)
        return registered
    }

    /** Returns false if [requestId] is unknown or already resolved. */
    fun resolve(requestId: String, outcome: Outcome): Boolean {
        val request = synchronized(lock) { pending.remove(requestId) } ?: return false
        request.completion.complete(outcome)
        return true
    }

    /** Cancels pending requests and detaches [callId], or all existing factories when null. */
    fun cancel(callId: String?) {
        takeCancelled(callId).forEach { it.complete(Outcome.UseDefault) }
    }

    /** Separates invalidation from callbacks so both checkpoint protocols can be invalidated before either resumes. */
    fun takeCancelled(callId: String?): List<ErrorDialogFactory.Completion> = synchronized(lock) {
        if (callId == null) {
            currentGeneration++
            detachedCallIds.clear()
            pending.values.toList().also { pending.clear() }
        } else {
            detachedCallIds.add(callId)
            val requests = pending.values.filter { it.callId == callId }
            pending.entries.removeAll { it.value.callId == callId }
            requests
        }
    }.map { it.completion }

    /** Clears [callId]'s detached marker unless this factory belongs to an older generation. */
    fun clearDetached(callId: String, generation: Long = this.generation) {
        synchronized(lock) {
            if (generation == currentGeneration) {
                detachedCallIds.remove(callId)
            }
        }
    }
}
