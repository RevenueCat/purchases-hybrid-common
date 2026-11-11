package com.revenuecat.purchases.hybridcommon.ui

import android.app.Activity
import android.os.Looper
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.models.GoogleSubscriptionOption
import com.revenuecat.purchases.models.Period
import com.revenuecat.purchases.models.Price
import com.revenuecat.purchases.models.PricingPhase
import com.revenuecat.purchases.models.RecurrenceMode
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.models.StoreReplacementMode
import com.revenuecat.purchases.models.SubscriptionOption
import com.revenuecat.purchases.ui.revenuecatui.PaywallPurchaseLogic
import com.revenuecat.purchases.ui.revenuecatui.PaywallPurchaseLogicParams
import com.revenuecat.purchases.ui.revenuecatui.PurchaseLogic
import com.revenuecat.purchases.ui.revenuecatui.PurchaseLogicResult
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.unmockkAll
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertSame
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class HybridPurchaseLogicBridgeTest {
    private val activity = mockk<Activity>()
    private val product = mockk<StoreProduct>(relaxed = true)
    private val rcPackage = mockk<Package>()
    private val packageData = mapOf(
        "identifier" to "monthly",
        "product" to mapOf("identifier" to "subscription:monthly"),
    )

    @Before
    fun setUp() {
        mockkStatic("com.revenuecat.purchases.hybridcommon.mappers.OfferingsMapperKt")
        every { rcPackage.map() } returns packageData
        every { rcPackage.product } returns product
        every { product.id } returns "subscription:monthly"
        every { product.purchasingData.productId } returns "subscription"
    }

    @After
    fun tearDown() {
        unmockkAll()
    }

    @Suppress("DEPRECATION")
    @Test
    fun `legacy PurchaseLogic callers keep the original event shape`() {
        val event = purchase { bridge ->
            val legacy: PurchaseLogic = bridge
            legacy.performPurchase(activity, rcPackage)
        }

        assertEquals(setOf("requestId", "packageBeingPurchased"), event.keys)
        assertEquals(packageData, event["packageBeingPurchased"])
    }

    @Test
    fun `new callback without optional params keeps the original event shape`() {
        val event = purchase { bridge ->
            val logic: PaywallPurchaseLogic = bridge
            logic.performPurchase(activity, PaywallPurchaseLogicParams.Builder(rcPackage).build())
        }

        assertEquals(setOf("requestId", "packageBeingPurchased"), event.keys)
        assertEquals(packageData, event["packageBeingPurchased"])
    }

    @Test
    fun `selected Google offer and token are forwarded without changing the package`() {
        val option = GoogleSubscriptionOption(
            productId = "subscription",
            basePlanId = "monthly",
            offerId = "promo",
            pricingPhases = listOf(
                PricingPhase(Period.create("P1M"), RecurrenceMode.FINITE_RECURRING, 1, Price("$0.00", 0, "USD")),
                PricingPhase(
                    Period.create("P1M"),
                    RecurrenceMode.INFINITE_RECURRING,
                    null,
                    Price("$9.99", 9990000, "USD"),
                ),
            ),
            tags = listOf("promo"),
            productDetails = mockk(),
            offerToken = "selected-offer-token",
            presentedOfferingContext = PresentedOfferingContext("offering", "placement", null),
        )
        val defaultOption = mockk<SubscriptionOption>()
        every { defaultOption.id } returns "monthly:default"
        every { product.defaultOption } returns defaultOption

        val event = purchase { bridge ->
            bridge.performPurchase(
                activity,
                PaywallPurchaseLogicParams.Builder(rcPackage).subscriptionOption(option).build(),
            )
        }

        val mappedOption = event["subscriptionOption"] as Map<*, *>
        assertEquals("monthly:promo", mappedOption["id"])
        assertEquals("subscription", mappedOption["productId"])
        assertEquals("subscription:monthly", mappedOption["storeProductId"])
        assertEquals("selected-offer-token", mappedOption["offerToken"])
        assertEquals(listOf("promo"), mappedOption["tags"])
        assertEquals(2, (mappedOption["pricingPhases"] as List<*>).size)
        assertEquals("placement", (mappedOption["presentedOfferingContext"] as Map<*, *>)["placementIdentifier"])
        assertEquals(packageData, event["packageBeingPurchased"])
        assertSame(defaultOption, product.defaultOption)
    }

    @Test
    fun `upgrade params use the existing store replacement mode strings`() {
        val params = PaywallPurchaseLogicParams.Builder(rcPackage)
            .oldProductId("old-subscription")
            .replacementMode(StoreReplacementMode.CHARGE_PRORATED_PRICE)
            .build()

        val event = purchase { bridge -> bridge.performPurchase(activity, params) }

        assertEquals("old-subscription", event["oldProductId"])
        assertEquals("CHARGE_PRORATED_PRICE", event["storeReplacementMode"])
        assertFalse(event.containsKey("subscriptionOption"))
        assertEquals(packageData, event["packageBeingPurchased"])
    }

    @Test
    fun `non Google options do not require an offer token`() {
        val option = mockk<SubscriptionOption>(relaxed = true)
        every { option.id } returns "term-sku"
        val params = PaywallPurchaseLogicParams.Builder(rcPackage).subscriptionOption(option).build()

        val event = purchase { bridge -> bridge.performPurchase(activity, params) }

        val mappedOption = event["subscriptionOption"] as Map<*, *>
        assertEquals("term-sku", mappedOption["id"])
        assertFalse(mappedOption.containsKey("offerToken"))
    }

    private fun purchase(
        block: suspend (HybridPurchaseLogicBridge) -> PurchaseLogicResult,
    ): Map<String, Any?> = runBlocking {
        var event: Map<String, Any?>? = null
        val bridge = HybridPurchaseLogicBridge(
            onPerformPurchase = {
                event = it
                assertSame(Looper.getMainLooper(), Looper.myLooper())
                HybridPurchaseLogicBridge.resolveResult(
                    it[HybridPurchaseLogicBridge.EVENT_KEY_REQUEST_ID] as String,
                    HybridPurchaseLogicBridge.RESULT_SUCCESS,
                )
            },
            onPerformRestore = null,
        )
        try {
            val result = async(start = CoroutineStart.UNDISPATCHED) { block(bridge) }
            shadowOf(Looper.getMainLooper()).idle()
            assertSame(PurchaseLogicResult.Success, withTimeout(5000) { result.await() })
            assertNotNull(event?.get("requestId"))
            checkNotNull(event)
        } finally {
            bridge.cancelPending()
        }
    }
}
