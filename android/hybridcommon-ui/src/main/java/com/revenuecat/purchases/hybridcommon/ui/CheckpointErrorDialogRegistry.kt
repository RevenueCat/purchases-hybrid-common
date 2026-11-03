@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory.Outcome
import java.util.Collections
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

internal val defaultCheckpointErrorDialogRegistry = CheckpointErrorDialogRegistry()

/** Tracks pending dialog requests and detached calls. */
internal class CheckpointErrorDialogRegistry {

    private data class PendingRequest(
        val callId: String,
        val completion: ErrorDialogFactory.Completion,
    )

    private val pending = ConcurrentHashMap<String, PendingRequest>()
    private val detachedCallIds: MutableSet<String> =
        Collections.newSetFromMap(ConcurrentHashMap())

    private val currentGeneration = AtomicLong()

    /** Factories use this to detect global cancellation. */
    val generation: Long get() = currentGeneration.get()

    fun isDetached(callId: String, generation: Long = this.generation): Boolean =
        generation != this.generation || callId in detachedCallIds

    fun register(requestId: String, callId: String, completion: ErrorDialogFactory.Completion) {
        pending[requestId] = PendingRequest(callId, completion)
    }

    /** Returns false if [requestId] is unknown or already resolved. */
    fun resolve(requestId: String, outcome: Outcome): Boolean {
        val request = pending.remove(requestId) ?: return false
        request.completion.complete(outcome)
        return true
    }

    /** Cancels pending requests and detaches [callId], or all existing factories when null. */
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

    /** Clears [callId]'s detached marker unless this factory belongs to an older generation. */
    fun clearDetached(callId: String, generation: Long = this.generation) {
        if (generation == this.generation) {
            detachedCallIds.remove(callId)
        }
    }
}
