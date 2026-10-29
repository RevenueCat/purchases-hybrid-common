package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.EntitlementInfo
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.ui.revenuecatui.CustomVariableValue
import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointErrorDialog
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointFailureKind
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointParams
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointPassedCallback
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointResult
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowPresentationMode
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowResult
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ObtainedEntitlement
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ObtainedProduct
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.unmockkStatic
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(InviteOnlyCheckpointsAPI::class, InternalRevenueCatAPI::class)
class CheckpointHelpersTest {

    private companion object {
        val MAPPER_FILES = arrayOf(
            "com.revenuecat.purchases.hybridcommon.mappers.CustomerInfoMapperKt",
            "com.revenuecat.purchases.hybridcommon.mappers.EntitlementInfoMapperKt",
            "com.revenuecat.purchases.hybridcommon.mappers.StoreProductMapperKt",
        )
    }

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
        mockkStatic(MAPPER_FILES.first(), *MAPPER_FILES.drop(1).toTypedArray())
    }

    @After
    fun tearDown() {
        unmockkStatic(Log::class)
        unmockkStatic(*MAPPER_FILES)
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
    fun `starts the checkpoint with the identifier, custom variables and presentation mode`() {
        val listener = RecordingListener()
        val started = present(
            listener = listener,
            customVariables = mapOf("level" to 12, "name" to "a", "pro" to true, "ignored" to listOf(1)),
            presentationMode = "MODAL_SHEET",
        )

        assertEquals("upgrade", started.identifier)
        assertEquals(
            mapOf(
                "level" to CustomVariableValue.Number(12.0),
                "name" to CustomVariableValue.String("a"),
                "pro" to CustomVariableValue.Boolean(true),
            ),
            started.params.customVariables,
        )
        assertEquals(FlowPresentationMode.MODAL_SHEET, started.params.presentationMode)
        assertTrue(listener.passed.isEmpty())
        assertTrue(listener.errors.isEmpty())
    }

    @Test
    fun `maps each presentation mode`() {
        val modes = mapOf(
            "MODAL_FULL_SCREEN" to FlowPresentationMode.MODAL_FULL_SCREEN,
            "MODAL_SHEET" to FlowPresentationMode.MODAL_SHEET,
            "DEFAULT" to FlowPresentationMode.DEFAULT,
            "unknown" to FlowPresentationMode.DEFAULT,
            null to FlowPresentationMode.DEFAULT,
        )
        modes.forEach { (mode, expected) ->
            assertEquals(mode, expected, present(presentationMode = mode).params.presentationMode)
        }
    }

    @Test
    fun `reports the passed result with the customer and the sorted obtained entitlements and products`() {
        val listener = RecordingListener()
        val started = present(listener = listener)
        val customer = mockk<CustomerInfo>()
        every { customer.map() } returns mapOf("originalAppUserId" to "user")
        val pro = entitlement("pro")
        val plus = entitlement("plus")
        val monthly = product("monthly")
        val annual = product("annual")
        val flow = mockk<FlowResult>()
        every { flow.obtainedEntitlements } returns setOf(obtained(pro), obtained(plus))
        every { flow.obtainedProducts } returns setOf(obtained(monthly), obtained(annual))

        started.callback.onCheckpointPassed(result(customer, flow))

        assertEquals(
            listOf(
                mapOf(
                    "customer" to mapOf("originalAppUserId" to "user"),
                    "flow" to mapOf(
                        "obtainedEntitlements" to listOf(
                            mapOf("entitlementInfo" to mapOf("identifier" to "plus")),
                            mapOf("entitlementInfo" to mapOf("identifier" to "pro")),
                        ),
                        "obtainedProducts" to listOf(
                            mapOf("product" to mapOf("identifier" to "annual")),
                            mapOf("product" to mapOf("identifier" to "monthly")),
                        ),
                    ),
                ),
            ),
            listener.passed,
        )
        assertTrue(listener.errors.isEmpty())
    }

    @Test
    fun `reports a null flow when the checkpoint passed without presenting one`() {
        val listener = RecordingListener()
        val started = present(listener = listener)
        val customer = mockk<CustomerInfo>()
        every { customer.map() } returns mapOf("originalAppUserId" to "user")

        started.callback.onCheckpointPassed(result(customer, flow = null))

        assertEquals(
            listOf(mapOf("customer" to mapOf("originalAppUserId" to "user"), "flow" to null)),
            listener.passed,
        )
    }

    private class Started(
        val identifier: String,
        val params: CheckpointParams,
        val callback: CheckpointPassedCallback,
    )

    private fun present(
        listener: CheckpointListener = RecordingListener(),
        customVariables: Map<String, Any?>? = null,
        presentationMode: String? = null,
    ): Started {
        var started: Started? = null
        presentCheckpoint(
            identifier = "upgrade",
            customVariables = customVariables,
            presentationMode = presentationMode,
            listener = listener,
            isConfigured = { true },
            start = { id, params, callback -> started = Started(id, params, callback) },
        )
        return checkNotNull(started) { "presentCheckpoint did not start the checkpoint" }
    }

    private fun result(customer: CustomerInfo, flow: FlowResult?): CheckpointResult {
        val result = mockk<CheckpointResult>()
        every { result.customer } returns customer
        every { result.flow } returns flow
        return result
    }

    private fun obtained(info: EntitlementInfo): ObtainedEntitlement {
        val obtained = mockk<ObtainedEntitlement>()
        every { obtained.entitlementInfo } returns info
        return obtained
    }

    private fun obtained(product: StoreProduct): ObtainedProduct {
        val obtained = mockk<ObtainedProduct>()
        every { obtained.product } returns product
        return obtained
    }

    private fun entitlement(identifier: String): EntitlementInfo {
        val info = mockk<EntitlementInfo>()
        every { info.identifier } returns identifier
        every { info.map() } returns mapOf("identifier" to identifier)
        return info
    }

    private fun product(id: String): StoreProduct {
        val product = mockk<StoreProduct>()
        every { product.id } returns id
        every { product.map() } returns mapOf("identifier" to id)
        return product
    }

    // region error-dialog-factory path

    @Test
    fun `reports NOT_CONFIGURED and does not start when Purchases is not configured (callId overload)`() {
        val listener = RecordingListener()
        var started = false
        val registry = CheckpointErrorDialogRegistry()

        presentCheckpoint(
            identifier = "upgrade",
            callId = "c1",
            customVariables = null,
            presentationMode = null,
            listener = listener,
            isConfigured = { false },
            start = { _, _, _ -> started = true },
            registry = registry,
        )

        assertFalse(started)
        assertEquals(CheckpointErrorCode.NOT_CONFIGURED, listener.errors.single().first)
        assertTrue(listener.passed.isEmpty())
    }

    @Test
    fun `presentCheckpoint with callId sets an error dialog factory on the params`() {
        val registry = CheckpointErrorDialogRegistry()
        val started = presentWithCallId(callId = "c1", registry = registry)

        assertNotNull(started.params.errorDialogFactory)
    }

    @Test
    fun `factory sends onErrorDialogRequested with the correct error map`() {
        val capturedRequests = mutableListOf<Pair<String, Map<String, Any?>>>()
        val recordingListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
            override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                capturedRequests += requestId to error
            }
        }
        val registry = CheckpointErrorDialogRegistry()
        val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)
        val fp = mockFactoryParams(
            kind = CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN,
            errorCode = PurchasesErrorCode.StoreProblemError,
            message = "Store failed",
        )

        started.params.errorDialogFactory!!.createDialog(fp) { }

        assertEquals(1, capturedRequests.size)
        val (_, errorMap) = capturedRequests.single()
        assertEquals("flowCouldNotBeShown", errorMap["kind"])
        assertEquals(PurchasesErrorCode.StoreProblemError.code, errorMap["code"])
        assertEquals("Store failed", errorMap["message"])
    }

    @Test
    fun `factory maps all CheckpointFailureKind values to hybrid strings`() {
        val kinds = mapOf(
            CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN to "flowCouldNotBeShown",
            CheckpointFailureKind.FLOW_ACTION_FAILED to "flowActionFailed",
            CheckpointFailureKind.FLOW_RESULT_SYNC_FAILED to "flowResultSyncFailed",
        )
        kinds.forEach { (kind, expectedString) ->
            val capturedKind = mutableListOf<String>()
            val recordingListener = object : CheckpointListener {
                override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
                override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                    capturedKind += error["kind"] as String
                }
            }
            val registry = CheckpointErrorDialogRegistry()
            val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)
            started.params.errorDialogFactory!!.createDialog(mockFactoryParams(kind = kind)) { }
            assertEquals(expectedString, capturedKind.single())
        }
    }

    @Test
    fun `resolveErrorDialog with content completes the factory completion with the dialog`() {
        val completions = mutableListOf<CheckpointErrorDialog?>()
        val registry = CheckpointErrorDialogRegistry()
        val capturedRequestId = mutableListOf<String>()
        val recordingListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
            override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                capturedRequestId += requestId
            }
        }
        val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)
        started.params.errorDialogFactory!!.createDialog(
            mockFactoryParams(kind = CheckpointFailureKind.FLOW_ACTION_FAILED),
        ) { completions += it }

        resolveErrorDialog(
            capturedRequestId.single(),
            mapOf("message" to "Something went wrong", "buttonTitle" to "OK"),
            registry,
        )

        assertEquals(1, completions.size)
        assertEquals(CheckpointErrorDialog("Something went wrong", "OK"), completions.single())
    }

    @Test
    fun `resolveErrorDialog with null dialog completes with null`() {
        val completions = mutableListOf<CheckpointErrorDialog?>()
        val registry = CheckpointErrorDialogRegistry()
        val capturedRequestId = mutableListOf<String>()
        val recordingListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
            override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                capturedRequestId += requestId
            }
        }
        val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)
        started.params.errorDialogFactory!!.createDialog(
            mockFactoryParams(kind = CheckpointFailureKind.FLOW_ACTION_FAILED),
        ) { completions += it }

        resolveErrorDialog(capturedRequestId.single(), null, registry)

        assertEquals(1, completions.size)
        assertNull(completions.single())
    }

    @Test
    fun `resolveErrorDialog with invalid content logs a warning and completes with null`() {
        val completions = mutableListOf<CheckpointErrorDialog?>()
        val registry = CheckpointErrorDialogRegistry()
        val capturedRequestId = mutableListOf<String>()
        val recordingListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
            override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                capturedRequestId += requestId
            }
        }
        val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)
        started.params.errorDialogFactory!!.createDialog(
            mockFactoryParams(kind = CheckpointFailureKind.FLOW_RESULT_SYNC_FAILED),
        ) { completions += it }

        // missing buttonTitle key
        resolveErrorDialog(capturedRequestId.single(), mapOf("message" to "oops"), registry)

        assertNull(completions.single())
    }

    @Test
    fun `resolveErrorDialog with unknown requestId is ignored`() {
        val registry = CheckpointErrorDialogRegistry()
        // Should not throw; the warning is logged
        resolveErrorDialog("nonexistent", mapOf("message" to "msg", "buttonTitle" to "OK"), registry)
    }

    @Test
    fun `double resolveErrorDialog ignores the second call`() {
        val completions = mutableListOf<CheckpointErrorDialog?>()
        val registry = CheckpointErrorDialogRegistry()
        val capturedRequestId = mutableListOf<String>()
        val recordingListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
            override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                capturedRequestId += requestId
            }
        }
        val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)
        started.params.errorDialogFactory!!.createDialog(
            mockFactoryParams(kind = CheckpointFailureKind.FLOW_ACTION_FAILED),
        ) { completions += it }
        val requestId = capturedRequestId.single()

        resolveErrorDialog(requestId, mapOf("message" to "first", "buttonTitle" to "OK"), registry)
        resolveErrorDialog(requestId, mapOf("message" to "second", "buttonTitle" to "OK"), registry)

        assertEquals(1, completions.size)
        assertEquals("first", (completions.single() as CheckpointErrorDialog).message)
    }

    @Test
    fun `several independent errors are handled independently`() {
        val completions = mutableMapOf<String, CheckpointErrorDialog?>()
        val registry = CheckpointErrorDialogRegistry()
        val capturedRequestIds = mutableListOf<String>()
        val recordingListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
            override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                capturedRequestIds += requestId
            }
        }
        val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)
        val fp = mockFactoryParams(kind = CheckpointFailureKind.FLOW_ACTION_FAILED)
        started.params.errorDialogFactory!!.createDialog(fp) { completions["req1"] = it }
        started.params.errorDialogFactory!!.createDialog(fp) { completions["req2"] = it }
        val (id1, id2) = capturedRequestIds.take(2)

        resolveErrorDialog(id1, mapOf("message" to "Dialog 1", "buttonTitle" to "OK"), registry)
        resolveErrorDialog(id2, null, registry)

        assertEquals(CheckpointErrorDialog("Dialog 1", "OK"), completions["req1"])
        assertNull(completions["req2"])
    }

    @Test
    fun `cancelErrorDialogs(callId) completes pending requests with null and detaches the callId`() {
        val completions = mutableListOf<CheckpointErrorDialog?>()
        val registry = CheckpointErrorDialogRegistry()
        val recordingListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
        }
        val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)
        started.params.errorDialogFactory!!.createDialog(
            mockFactoryParams(kind = CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN),
        ) { completions += it }

        cancelErrorDialogs("c1", registry)

        assertEquals(1, completions.size)
        assertNull(completions.single())
        assertTrue(registry.isDetached("c1"))
    }

    @Test
    fun `cancelErrorDialogs(callId) causes later factory invocations to complete immediately with null`() {
        val completions = mutableListOf<CheckpointErrorDialog?>()
        val requestIds = mutableListOf<String>()
        val registry = CheckpointErrorDialogRegistry()
        val recordingListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
            override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
                requestIds += requestId
            }
        }
        val started = presentWithCallId(callId = "c1", listener = recordingListener, registry = registry)

        cancelErrorDialogs("c1", registry)

        // Factory should now complete immediately with null, not call onErrorDialogRequested
        started.params.errorDialogFactory!!.createDialog(
            mockFactoryParams(kind = CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN),
        ) { completions += it }

        assertEquals(1, completions.size)
        assertNull(completions.single())
        assertTrue(requestIds.isEmpty())
    }

    @Test
    fun `cancelErrorDialogs(null) cancels all pending requests`() {
        val completions = mutableMapOf<String, CheckpointErrorDialog?>()
        val registry = CheckpointErrorDialogRegistry()
        val fp = mockFactoryParams(kind = CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN)
        val noopListener = object : CheckpointListener {
            override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
        }
        val started1 = presentWithCallId(callId = "c1", listener = noopListener, registry = registry)
        val started2 = presentWithCallId(callId = "c2", listener = noopListener, registry = registry)
        started1.params.errorDialogFactory!!.createDialog(fp) { completions["c1"] = it }
        started2.params.errorDialogFactory!!.createDialog(fp) { completions["c2"] = it }

        cancelErrorDialogs(null, registry)

        assertNull(completions["c1"])
        assertNull(completions["c2"])
        assertTrue(registry.isDetached("c1"))
        assertTrue(registry.isDetached("c2"))
    }

    @Test
    fun `onCheckpointPassed clears the detached marker for that callId`() {
        val registry = CheckpointErrorDialogRegistry()
        val listener = RecordingListener()
        val customer = mockk<CustomerInfo>()
        every { customer.map() } returns mapOf("originalAppUserId" to "user")
        val started = presentWithCallId(callId = "c1", listener = listener, registry = registry)

        cancelErrorDialogs("c1", registry)
        assertTrue(registry.isDetached("c1"))

        started.callback.onCheckpointPassed(result(customer, flow = null))

        assertFalse(registry.isDetached("c1"))
    }

    @Test
    fun `no-handler path (presentCheckpoint without callId) sets no errorDialogFactory`() {
        val started = present()
        assertNull(started.params.errorDialogFactory)
    }

    private class StartedWithCallId(
        val params: CheckpointParams,
        val callback: CheckpointPassedCallback,
    )

    private fun presentWithCallId(
        callId: String = "call1",
        listener: CheckpointListener = RecordingListener(),
        registry: CheckpointErrorDialogRegistry = CheckpointErrorDialogRegistry(),
    ): StartedWithCallId {
        var started: StartedWithCallId? = null
        presentCheckpoint(
            identifier = "upgrade",
            callId = callId,
            customVariables = null,
            presentationMode = null,
            listener = listener,
            isConfigured = { true },
            start = { _, params, callback -> started = StartedWithCallId(params, callback) },
            registry = registry,
        )
        return checkNotNull(started) { "presentCheckpoint did not start the checkpoint" }
    }

    @Suppress("LongParameterList")
    private fun mockFactoryParams(
        kind: CheckpointFailureKind = CheckpointFailureKind.FLOW_COULD_NOT_BE_SHOWN,
        errorCode: PurchasesErrorCode = PurchasesErrorCode.StoreProblemError,
        message: String = "err",
    ): ErrorDialogFactory.Params {
        val error = mockk<PurchasesError>()
        every { error.code } returns errorCode
        every { error.message } returns message
        val params = mockk<ErrorDialogFactory.Params>()
        every { params.error } returns error
        every { params.kind } returns kind
        every { params.checkpointIdentifier } returns "upgrade"
        every { params.customVariables } returns emptyMap()
        return params
    }

    // endregion
}
