package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.PaywallPresenter.Completion
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.PaywallPresenter.Completion.Result
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(InviteOnlyCheckpointsAPI::class)
class CheckpointPaywallRegistryTest {
    private val registry = CheckpointPaywallRegistry()
    private val results = mutableListOf<Result>()
    private val completion = Completion { results += it }

    @Test
    fun `outcomes resolve exactly once and unknown requests do nothing`() {
        val call = registry.begin("call")
        listOf(Result.Continued, Result.Closed, Result.NavigatedBack).forEachIndexed { index, result ->
            val id = "request-$index"
            assertTrue(registry.register(id, call, completion))
            assertTrue(registry.resolve(id, result))
            assertFalse(registry.resolve(id, Result.Continued))
        }
        assertFalse(registry.resolve("missing", Result.Continued))
        assertEquals(listOf(Result.Continued, Result.Closed, Result.NavigatedBack), results)
    }

    @Test
    fun `detach before resolution rejects late presentation`() {
        val call = registry.begin("call")
        registry.detach("call", null)
        assertFalse(registry.register("late", call, completion))
        assertFalse(registry.isPending("late"))
        assertEquals(listOf(Result.NavigatedBack), results)
    }

    @Test
    fun `detach cancels queued event and preserves only delivered app UI`() {
        registry.register("queued-request", registry.begin("queued"), completion)
        registry.register("active-request", registry.begin("active"), completion)
        registry.detach("queued", null)
        registry.detach("active", "active-request")
        assertFalse(registry.isPending("queued-request"))
        assertTrue(registry.isPending("active-request"))
        assertEquals(listOf(Result.NavigatedBack), results)
        registry.resolve("active-request", Result.Closed)
        assertEquals(listOf(Result.NavigatedBack, Result.Closed), results)
    }

    @Test
    fun `invalidation drains requests rejects late requests and allows new calls`() {
        val old = registry.begin("call")
        registry.register("old-request", old, completion)
        registry.invalidate()
        val new = registry.begin("call")
        registry.finish(old)
        assertFalse(registry.register("late", old, completion))
        assertTrue(registry.register("new-request", new, completion))
        registry.resolve("new-request", Result.Continued)
        assertEquals(listOf(Result.NavigatedBack, Result.NavigatedBack, Result.Continued), results)
    }

    @Test
    fun `invalidation completion may reenter registry without canceling new requests`() {
        registry.register(
            "old-request",
            registry.begin("old"),
            Completion {
                registry.register("new-request", registry.begin("new"), completion)
            },
        )
        registry.invalidate()
        assertTrue(registry.isPending("new-request"))
        registry.resolve("new-request", Result.Continued)
        assertEquals(listOf(Result.Continued), results)
    }
}
