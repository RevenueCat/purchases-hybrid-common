package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.EntitlementInfo
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.ui.revenuecatui.CustomVariableValue
import com.revenuecat.purchases.ui.revenuecatui.InviteOnlyCheckpointsAPI
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointParams
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointPassedCallback
import com.revenuecat.purchases.ui.revenuecatui.checkpoints.CheckpointResult
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
}
