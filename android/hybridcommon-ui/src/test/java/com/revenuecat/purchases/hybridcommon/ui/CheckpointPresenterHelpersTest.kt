package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.hybridcommon.mappers.mapAsync
import com.revenuecat.purchases.ui.revenuecatui.CustomVariableValue
import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointFailureKind
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointParams
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointPassedCallback
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointResult
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.ErrorDialogFactory
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.FlowPresentationMode
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.PaywallPresenter
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.unmockkStatic
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Before
import org.junit.Test

private typealias OfferingMapCallback = (Map<String, Any?>) -> Unit

@OptIn(InviteOnlyCheckpointsAPI::class, InternalRevenueCatAPI::class)
class CheckpointPresenterHelpersTest {
    private val paywalls = CheckpointPaywallRegistry()
    private val errors = CheckpointErrorDialogRegistry()
    private val requested = mutableListOf<Pair<String, Map<String, Any?>>>()
    private val errorRequests = mutableListOf<String>()
    private val results = mutableListOf<PaywallPresenter.Completion.Result>()
    private val offering = mockk<Offering>()
    private val listener = object : CheckpointListener {
        override fun onCheckpointPassed(result: Map<String, Any?>) = Unit
        override fun onPaywallPresentationRequested(requestId: String, params: Map<String, Any?>) {
            requested += requestId to params
        }
        override fun onErrorDialogRequested(requestId: String, error: Map<String, Any?>) {
            errorRequests += requestId
        }
    }

    @Before
    fun setUp() {
        mockkStatic(Log::class)
        every { Log.e(any<String>(), any<String>()) } returns 0
        every { Log.w(any<String>(), any<String>()) } returns 0
        mockkStatic("com.revenuecat.purchases.hybridcommon.mappers.OfferingsMapperKt")
        every { offering.mapAsync(any()) } answers {
            secondArg<OfferingMapCallback>()(mapOf("identifier" to "premium", "availablePackages" to emptyList<Any>()))
        }
    }

    @After
    fun tearDown() {
        unmockkStatic(Log::class)
        unmockkStatic("com.revenuecat.purchases.hybridcommon.mappers.OfferingsMapperKt")
    }

    private data class Started(val params: CheckpointParams, val callback: CheckpointPassedCallback)

    private fun present(custom: Boolean = true, factory: Boolean = false): Started {
        var started: Started? = null
        presentCheckpoint(
            "upgrade", "call", mapOf("premium" to false), "MODAL_SHEET", custom, factory, listener,
            isConfigured = { true },
            start = { _, params, callback -> started = Started(params, callback) },
            registry = errors, paywallRegistry = paywalls,
        )
        return checkNotNull(started)
    }

    private fun request(started: Started) {
        val params = mockk<PaywallPresenter.Params>()
        every { params.offering } returns offering
        every { params.checkpointIdentifier } returns "upgrade"
        every { params.presentationMode } returns FlowPresentationMode.MODAL_FULL_SCREEN
        every { params.customVariables } returns mapOf(
            "name" to CustomVariableValue.String("Taylor"), "level" to CustomVariableValue.Number(12),
            "premium" to CustomVariableValue.Boolean(false),
        )
        checkNotNull(started.params.paywallPresenter).present(params) { results += it }
    }

    @Test
    fun `selects presenter and error factory independently`() {
        listOf(false, true).forEach { custom ->
            listOf(false, true).forEach { factory ->
                val started = present(custom, factory)
                assertEquals(custom, started.params.paywallPresenter != null)
                assertEquals(factory, started.params.errorDialogFactory != null)
            }
        }
    }

    @Test
    fun `presenter serializes resolved context and waits for explicit outcome`() {
        request(present())
        assertEquals(
            mapOf(
                "checkpointIdentifier" to "upgrade",
                "presentationMode" to "MODAL_FULL_SCREEN",
                "customVariables" to mapOf("name" to "Taylor", "level" to 12.0, "premium" to false),
                "offering" to mapOf("identifier" to "premium", "availablePackages" to emptyList<Any>()),
            ),
            requested.single().second,
        )
        assertEquals(emptyList<PaywallPresenter.Completion.Result>(), results)
        completePaywallPresentation(requested.single().first, "CLOSED", paywalls)
        completePaywallPresentation(requested.single().first, "CONTINUED", paywalls)
        assertEquals(listOf(PaywallPresenter.Completion.Result.Closed), results)
    }

    @Test
    fun `detach during asynchronous offering mapping cancels native and suppresses late event`() {
        var mapped: OfferingMapCallback? = null
        every { offering.mapAsync(any()) } answers { mapped = secondArg() }
        request(present())
        detachCheckpoint("call", null, errors, paywalls)
        checkNotNull(mapped)(mapOf("identifier" to "premium"))
        assertEquals(emptyList<Pair<String, Map<String, Any?>>>(), requested)
        assertEquals(listOf(PaywallPresenter.Completion.Result.NavigatedBack), results)
    }

    @Test
    fun `custom presenter keeps error factory for post completion sync errors`() {
        val started = present(factory = true)
        request(started)
        completePaywallPresentation(requested.single().first, "CONTINUED", paywalls)
        val params = mockk<ErrorDialogFactory.Params>()
        every { params.kind } returns CheckpointFailureKind.FLOW_RESULT_SYNC_FAILED
        every { params.error } returns PurchasesError(PurchasesErrorCode.NetworkError, "offline")
        val outcomes = mutableListOf<ErrorDialogFactory.Outcome>()
        checkNotNull(started.params.errorDialogFactory).createDialog(params) { outcomes += it }
        resolveErrorDialog(errorRequests.single(), mapOf("type" to "suppress"), errors)
        assertEquals(listOf(ErrorDialogFactory.Outcome.Suppress), outcomes)
    }

    @Test
    fun `invalid outcome backs out and setup failure never starts`() {
        request(present())
        completePaywallPresentation(requested.single().first, "invalid", paywalls)
        assertEquals(listOf(PaywallPresenter.Completion.Result.NavigatedBack), results)
        var started = false
        presentCheckpoint(
            "upgrade", "unconfigured", null, null, true, false, listener,
            isConfigured = { false }, start = { _, _, _ -> started = true },
            registry = errors, paywallRegistry = paywalls,
        )
        assertFalse(started)
    }

    @Test
    fun `invalidation drains both protocols rejects late callbacks and preserves reentrant new runtime`() {
        val old = present(factory = true)
        request(old)
        val params = mockk<ErrorDialogFactory.Params>()
        every { params.kind } returns CheckpointFailureKind.FLOW_RESULT_SYNC_FAILED
        every { params.error } returns PurchasesError(PurchasesErrorCode.NetworkError, "offline")
        var successor: Started? = null
        val outcomes = mutableListOf<ErrorDialogFactory.Outcome>()
        checkNotNull(old.params.errorDialogFactory).createDialog(params) {
            outcomes += it
            successor = present(factory = true)
        }

        invalidateCheckpointPresentations(errors, paywalls)
        request(old)
        old.callback.onCheckpointPassed(mockk<CheckpointResult>())
        checkNotNull(old.params.errorDialogFactory).createDialog(params) { outcomes += it }
        request(checkNotNull(successor))
        checkNotNull(successor?.params?.errorDialogFactory).createDialog(params) { outcomes += it }
        assertEquals(2, requested.size)
        assertEquals(2, errorRequests.size)
        completePaywallPresentation(requested.last().first, "CONTINUED", paywalls)
        resolveErrorDialog(errorRequests.last(), mapOf("type" to "suppress"), errors)
        assertEquals(
            listOf(
                PaywallPresenter.Completion.Result.NavigatedBack,
                PaywallPresenter.Completion.Result.NavigatedBack,
                PaywallPresenter.Completion.Result.Continued,
            ),
            results,
        )
        assertEquals(
            listOf(
                ErrorDialogFactory.Outcome.UseDefault,
                ErrorDialogFactory.Outcome.UseDefault,
                ErrorDialogFactory.Outcome.Suppress,
            ),
            outcomes,
        )
    }
}
