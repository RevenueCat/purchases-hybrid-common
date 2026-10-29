package com.revenuecat.purchases.hybridcommon.ui

import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointErrorDialog
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(InternalRevenueCatAPI::class)
class CheckpointErrorDialogRegistryTest {

    private val registry = CheckpointErrorDialogRegistry()

    // region resolve

    @Test
    fun `resolve calls completion with the supplied dialog`() {
        var received: CheckpointErrorDialog? = CheckpointErrorDialog("sentinel", "x")
        val completion = recordingCompletion { received = it }
        registry.register("req1", "call1", completion)

        val result = registry.resolve("req1", CheckpointErrorDialog("Error!", "OK"))

        assertTrue(result)
        assertEquals(CheckpointErrorDialog("Error!", "OK"), received)
    }

    @Test
    fun `resolve calls completion with null when dialog is null`() {
        var received: CheckpointErrorDialog? = CheckpointErrorDialog("sentinel", "x")
        val completion = recordingCompletion { received = it }
        registry.register("req1", "call1", completion)

        val result = registry.resolve("req1", null)

        assertTrue(result)
        assertNull(received)
    }

    @Test
    fun `resolve returns false and does nothing for an unknown requestId`() {
        val completion = recordingCompletion { }
        registry.register("req1", "call1", completion)

        val result = registry.resolve("unknown", CheckpointErrorDialog("msg", "OK"))

        assertFalse(result)
        // req1 is still pending
        assertTrue(registry.resolve("req1", null))
    }

    @Test
    fun `resolve returns false on the second call for the same requestId`() {
        val completions = mutableListOf<CheckpointErrorDialog?>()
        val completion = recordingCompletion { completions += it }
        registry.register("req1", "call1", completion)

        val first = registry.resolve("req1", CheckpointErrorDialog("msg", "OK"))
        val second = registry.resolve("req1", null)

        assertTrue(first)
        assertFalse(second)
        assertEquals(1, completions.size)
        assertEquals(CheckpointErrorDialog("msg", "OK"), completions[0])
    }

    @Test
    fun `several pending requests for the same callId resolve independently`() {
        val dialogs = mutableMapOf<String, CheckpointErrorDialog?>()
        val c1 = recordingCompletion { dialogs["req1"] = it }
        val c2 = recordingCompletion { dialogs["req2"] = it }
        registry.register("req1", "call1", c1)
        registry.register("req2", "call1", c2)

        registry.resolve("req1", CheckpointErrorDialog("msg1", "OK"))
        registry.resolve("req2", null)

        assertEquals(CheckpointErrorDialog("msg1", "OK"), dialogs["req1"])
        assertNull(dialogs["req2"])
    }

    // endregion

    // region cancel(callId)

    @Test
    fun `cancel(callId) completes all pending requests for that callId with null`() {
        val completions = mutableMapOf<String, CheckpointErrorDialog?>()
        registry.register("req1", "call1", recordingCompletion { completions["req1"] = it })
        registry.register("req2", "call1", recordingCompletion { completions["req2"] = it })
        registry.register("req3", "call2", recordingCompletion { completions["req3"] = it })

        registry.cancel("call1")

        assertNull(completions["req1"])
        assertNull(completions["req2"])
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
        val completions = mutableListOf<CheckpointErrorDialog?>()
        val completion = recordingCompletion { completions += it }
        registry.register("req1", "call1", completion)
        registry.cancel("call1")

        // req1 was already cancelled; resolve should find nothing
        val result = registry.resolve("req1", CheckpointErrorDialog("msg", "OK"))

        assertFalse(result)
        // Only the cancel completion (null) was delivered
        assertEquals(1, completions.size)
        assertNull(completions[0])
    }

    @Test
    fun `cancel(callId) with no pending requests still marks callId detached`() {
        registry.cancel("call1")
        assertTrue(registry.isDetached("call1"))
    }

    // endregion

    // region cancel(null)

    @Test
    fun `cancel(null) completes all pending requests with null and detaches all callIds`() {
        val completions = mutableMapOf<String, CheckpointErrorDialog?>()
        registry.register("req1", "call1", recordingCompletion { completions["req1"] = it })
        registry.register("req2", "call2", recordingCompletion { completions["req2"] = it })
        registry.register("req3", "call2", recordingCompletion { completions["req3"] = it })

        registry.cancel(null)

        assertNull(completions["req1"])
        assertNull(completions["req2"])
        assertNull(completions["req3"])
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
        block: (CheckpointErrorDialog?) -> Unit,
    ): ErrorDialogFactory.Completion = ErrorDialogFactory.Completion { block(it) }

    // endregion
}
