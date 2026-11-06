@file:OptIn(InviteOnlyCheckpointsAPI::class)

package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.PaywallPresenter.Completion

internal val defaultCheckpointPaywallRegistry = CheckpointPaywallRegistry()

/** Keeps native completions alive until a hybrid wrapper answers or detaches. */
internal class CheckpointPaywallRegistry {
    class Call(val callId: String, val generation: Long) {
        var detached = false
    }
    private data class Pending(val call: Call, val completion: Completion)

    private val lock = Any()
    private var generation = 0L
    private val calls = mutableMapOf<String, Call>()
    private val pending = mutableMapOf<String, Pending>()

    fun begin(callId: String): Call = synchronized(lock) {
        Call(callId, generation).also { calls[callId] = it }
    }

    fun isAttached(call: Call): Boolean = synchronized(lock) {
        call.generation == generation && !call.detached
    }

    fun register(requestId: String, call: Call, completion: Completion): Boolean {
        val registered = synchronized(lock) {
            if (!isAttached(call)) {
                false
            } else {
                pending[requestId] = Pending(call, completion)
                true
            }
        }
        if (!registered) completion.complete(Completion.Result.NavigatedBack)
        return registered
    }

    fun resolve(requestId: String, result: Completion.Result): Boolean {
        val request = synchronized(lock) { pending.remove(requestId) } ?: return false
        if (result == Completion.Result.NavigatedBack) finish(request.call)
        request.completion.complete(result)
        return true
    }

    fun isPending(requestId: String): Boolean = synchronized(lock) { requestId in pending }

    fun detach(callId: String, activeRequestId: String?) {
        val cancelled = synchronized(lock) {
            calls.remove(callId)?.detached = true
            val requests = pending.filter { (id, request) -> request.call.callId == callId && id != activeRequestId }
            requests.keys.forEach { pending.remove(it) }
            requests.values.toList()
        }
        cancelled.forEach { it.completion.complete(Completion.Result.NavigatedBack) }
    }

    fun invalidate() {
        takePendingOnInvalidation().forEach { it.complete(Completion.Result.NavigatedBack) }
    }

    fun takePendingOnInvalidation(): List<Completion> = synchronized(lock) {
        generation++
        calls.clear()
        pending.values.toList().also { pending.clear() }
    }.map { it.completion }

    fun finish(call: Call) {
        synchronized(lock) {
            call.detached = true
            if (calls[call.callId] === call) calls.remove(call.callId)
        }
    }
}
