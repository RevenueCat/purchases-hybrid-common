package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointErrorDialog
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory.Outcome
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(InternalRevenueCatAPI::class)
class CheckpointErrorDialogRegistryTest {

    private val registry = CheckpointErrorDialogRegistry()

    // region resolve

    @Test
    fun `resolve calls completion with the supplied dialog`() {
        var received: Outcome = Outcome.Suppress
        val completion = recordingCompletion { received = it }
        registry.register("req1", "call1", completion)

        val result = registry.resolve("req1", Outcome.Show(CheckpointErrorDialog("Error!", "OK")))

        assertTrue(result)
        assertEquals(Outcome.Show(CheckpointErrorDialog("Error!", "OK")), received)
    }

    @Test
    fun `resolve calls completion with UseDefault`() {
        var received: Outcome = Outcome.Suppress
        val completion = recordingCompletion { received = it }
        registry.register("req1", "call1", completion)

        val result = registry.resolve("req1", Outcome.UseDefault)

        assertTrue(result)
        assertEquals(Outcome.UseDefault, received)
    }

    @Test
    fun `resolve returns false and does nothing for an unknown requestId`() {
        val completion = recordingCompletion { }
        registry.register("req1", "call1", completion)

        val result = registry.resolve("unknown", Outcome.Show(CheckpointErrorDialog("msg", "OK")))

        assertFalse(result)
        // req1 is still pending
        assertTrue(registry.resolve("req1", Outcome.UseDefault))
    }

    @Test
    fun `resolve returns false on the second call for the same requestId`() {
        val completions = mutableListOf<Outcome>()
        val completion = recordingCompletion { completions += it }
        registry.register("req1", "call1", completion)

        val first = registry.resolve("req1", Outcome.Show(CheckpointErrorDialog("msg", "OK")))
        val second = registry.resolve("req1", Outcome.UseDefault)

        assertTrue(first)
        assertFalse(second)
        assertEquals(1, completions.size)
        assertEquals(Outcome.Show(CheckpointErrorDialog("msg", "OK")), completions[0])
    }

    @Test
    fun `several pending requests for the same callId resolve independently`() {
        val dialogs = mutableMapOf<String, Outcome>()
        val c1 = recordingCompletion { dialogs["req1"] = it }
        val c2 = recordingCompletion { dialogs["req2"] = it }
        registry.register("req1", "call1", c1)
        registry.register("req2", "call1", c2)

        registry.resolve("req1", Outcome.Show(CheckpointErrorDialog("msg1", "OK")))
        registry.resolve("req2", Outcome.UseDefault)

        assertEquals(Outcome.Show(CheckpointErrorDialog("msg1", "OK")), dialogs["req1"])
        assertEquals(Outcome.UseDefault, dialogs["req2"])
    }

    @Test
    fun `resolve forwards Suppress without replacing it with UseDefault`() {
        val completions = mutableListOf<Outcome>()
        registry.register("request", "call", recordingCompletion { completions += it })

        assertTrue(registry.resolve("request", Outcome.Suppress))
        assertFalse(registry.resolve("request", Outcome.UseDefault))

        assertEquals(listOf(Outcome.Suppress), completions)
    }

    // endregion

    // region cancel(callId)

    @Test
    fun `cancel(callId) completes all pending requests for that callId with UseDefault`() {
        val completions = mutableMapOf<String, Outcome>()
        registry.register("req1", "call1", recordingCompletion { completions["req1"] = it })
        registry.register("req2", "call1", recordingCompletion { completions["req2"] = it })
        registry.register("req3", "call2", recordingCompletion { completions["req3"] = it })

        registry.cancel("call1")

        assertEquals(Outcome.UseDefault, completions["req1"])
        assertEquals(Outcome.UseDefault, completions["req2"])
        assertFalse(completions.containsKey("req3")) // call2 unaffected
    }

    @Test
    fun `cancel(callId) marks the callId detached`() {
        assertFalse(registry.isDetached("call1"))
        registry.cancel("call1")
        assertTrue(registry.isDetached("call1"))
    }

    @Test
    fun `cancel(callId) leaves later resolves for that requestId ignored`() {
        val completions = mutableListOf<Outcome>()
        val completion = recordingCompletion { completions += it }
        registry.register("req1", "call1", completion)
        registry.cancel("call1")

        // req1 was already cancelled; resolve should find nothing
        val result = registry.resolve("req1", Outcome.Show(CheckpointErrorDialog("msg", "OK")))

        assertFalse(result)
        // Only the cancel completion (UseDefault) was delivered
        assertEquals(1, completions.size)
        assertEquals(Outcome.UseDefault, completions[0])
    }

    @Test
    fun `cancel(callId) with no pending requests still marks callId detached`() {
        registry.cancel("call1")
        assertTrue(registry.isDetached("call1"))
    }

    // endregion

    // region cancel(null)

    @Test
    fun `cancel(null) completes all pending requests with UseDefault and detaches all callIds`() {
        val completions = mutableMapOf<String, Outcome>()
        registry.register("req1", "call1", recordingCompletion { completions["req1"] = it })
        registry.register("req2", "call2", recordingCompletion { completions["req2"] = it })
        registry.register("req3", "call2", recordingCompletion { completions["req3"] = it })

        registry.cancel(null)

        assertEquals(Outcome.UseDefault, completions["req1"])
        assertEquals(Outcome.UseDefault, completions["req2"])
        assertEquals(Outcome.UseDefault, completions["req3"])
        assertTrue(registry.isDetached("call1"))
        assertTrue(registry.isDetached("call2"))
    }

    @Test
    fun `cancel(null) with no pending requests does not throw`() {
        registry.cancel(null) // should be a no-op
    }

    // endregion

    // region clearDetached

    @Test
    fun `clearDetached removes the detached marker so future requests can reach the handler`() {
        registry.cancel("call1")
        assertTrue(registry.isDetached("call1"))

        registry.clearDetached("call1")

        assertFalse(registry.isDetached("call1"))
    }

    @Test
    fun `clearDetached on a non-detached callId is a no-op`() {
        registry.clearDetached("call1")
        assertFalse(registry.isDetached("call1"))
    }

    // endregion

    // region helpers

    private fun recordingCompletion(
        block: (Outcome) -> Unit,
    ): ErrorDialogFactory.Completion = ErrorDialogFactory.Completion { block(it) }

    // endregion
}
