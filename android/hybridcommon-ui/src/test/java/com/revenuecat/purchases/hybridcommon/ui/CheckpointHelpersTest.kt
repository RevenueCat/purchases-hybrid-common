package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointParams
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointPassedCallback
import io.mockk.every
import io.mockk.mockkStatic
import io.mockk.unmockkStatic
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(InviteOnlyCheckpointsAPI::class)
class CheckpointHelpersTest {

    private class RecordingListener : CheckpointListener {
        val errors = mutableListOf<Pair<String, String>>()
        val passed = mutableListOf<Map<String, Any?>>()

        override fun onCheckpointPassed(result: Map<String, Any?>) {
            passed += result
        }

        override fun onCheckpointError(code: String, message: String) {
            errors += code to message
        }
    }

    @Before
    fun setUp() {
        mockkStatic(Log::class)
        every { Log.e(any<String>(), any<String>()) } returns 0
        every { Log.w(any<String>(), any<String>()) } returns 0
    }

    @After
    fun tearDown() {
        unmockkStatic(Log::class)
    }

    @Test
    fun `reports NOT_CONFIGURED and does not start when Purchases is not configured`() {
        val listener = RecordingListener()
        var started = false

        presentCheckpoint(
            identifier = "upgrade",
            customVariables = null,
            presentationMode = null,
            listener = listener,
            isConfigured = { false },
            start = { _, _, _ -> started = true },
        )

        assertTrue(!started)
        assertEquals(CheckpointErrorCode.NOT_CONFIGURED, listener.errors.single().first)
        assertTrue(listener.passed.isEmpty())
    }

    @Test
    fun `starts the checkpoint with the identifier and without calling the listener until it passes`() {
        val listener = RecordingListener()
        var startedIdentifier: String? = null
        var startedParams: CheckpointParams? = null
        var startedCallback: CheckpointPassedCallback? = null

        presentCheckpoint(
            identifier = "upgrade",
            customVariables = mapOf("level" to 12, "name" to "a", "pro" to true, "ignored" to listOf(1)),
            presentationMode = "MODAL_SHEET",
            listener = listener,
            isConfigured = { true },
            start = { id, params, callback ->
                startedIdentifier = id
                startedParams = params
                startedCallback = callback
            },
        )

        assertEquals("upgrade", startedIdentifier)
        assertTrue(startedCallback != null)
        assertTrue(startedParams != null)
        assertTrue(listener.passed.isEmpty())
        assertTrue(listener.errors.isEmpty())
    }
}
