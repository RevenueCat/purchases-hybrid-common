package com.revenuecat.purchases.hybridcommon

import android.app.Activity
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.PurchaseParams
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.hybridcommon.mappers.overrideMapperDispatcher
import com.revenuecat.purchases.interfaces.PurchaseCallback
import com.revenuecat.purchases.interfaces.ReceiveOfferingsCallback
import io.mockk.Runs
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.slot
import io.mockk.unmockkObject
import io.mockk.verify
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@OptIn(InternalRevenueCatAPI::class, ExperimentalCoroutinesApi::class)
internal class PurchasePackageConfigReadinessTests {
    private val purchases = mockk<Purchases>()
    private val activity = mockk<Activity>()
    private val result = mockk<OnResult>(relaxed = true)
    private val product = TestUtilities.stubStoreProduct("monthly-product")
    private val offerings = TestUtilities.getOfferings(product, packageIdentifier = "monthly").third
    private val context = mapOf(
        "offeringIdentifier" to "offering",
        "placementIdentifier" to "upgrade-placement",
        "targetingContext" to mapOf("revision" to 7, "ruleId" to "upgrade-rule"),
    )

    @BeforeEach
    fun setup() {
        mockkObject(Purchases)
        every { Purchases.sharedInstance } returns purchases
        val dispatcher = UnconfinedTestDispatcher()
        Dispatchers.setMain(dispatcher)
        overrideMapperDispatcher = dispatcher
    }

    @AfterEach
    fun tearDown() {
        unmockkObject(Purchases)
        Dispatchers.resetMain()
    }

    @Test
    fun `package purchase reaches native purchase while ordinary offerings readiness is pending`() {
        val ordinaryCallback = slot<ReceiveOfferingsCallback>()
        every { purchases.getOfferings(capture(ordinaryCallback)) } just Runs
        every { purchases.getOfferingsForPurchase(any()) } answers {
            firstArg<ReceiveOfferingsCallback>().onReceived(offerings)
        }
        val params = slot<PurchaseParams>()
        val callback = slot<PurchaseCallback>()
        every { purchases.purchase(capture(params), capture(callback)) } just Runs
        purchases.getOfferings(mockk(relaxed = true))

        purchasePackage(activity, "MONTHLY", context, null, null, null, result)

        assertTrue(params.isCaptured)
        assertEquals("monthly-product", params.captured.purchasingDataForPreview.productId)
        val presented = PurchaseParams::class.members
            .first { it.name == "presentedOfferingContext" }.call(params.captured) as PresentedOfferingContext?
        assertEquals("offering", presented?.offeringIdentifier)
        assertEquals("upgrade-placement", presented?.placementIdentifier)
        assertEquals(7, presented?.targetingContext?.revision)
        assertEquals("upgrade-rule", presented?.targetingContext?.ruleId)
        verify(exactly = 1) { purchases.purchase(any(), any()) }

        ordinaryCallback.captured.onReceived(offerings)
        verify(exactly = 1) { purchases.purchase(any(), any()) }
        callback.captured.onCompleted(TestUtilities.createMockTransaction("monthly-product"), mockk(relaxed = true))
        verify(exactly = 1) { result.onReceived(any()) }
        verify(exactly = 0) { result.onError(any()) }
    }

    @Test
    fun `purchase lookup failure returns original error without purchasing`() {
        val expected = PurchasesError(PurchasesErrorCode.NetworkError, "purchase lookup failed")
        every { purchases.getOfferingsForPurchase(any()) } answers {
            firstArg<ReceiveOfferingsCallback>().onError(expected)
        }

        purchasePackage(activity, "monthly", context, null, null, null, result)

        verify(exactly = 1) {
            result.onError(
                match {
                    it.code == PurchasesErrorCode.NetworkError.code &&
                        it.info["underlyingErrorMessage"] == "purchase lookup failed"
                },
            )
        }
        verify(exactly = 0) { purchases.purchase(any(), any()) }
    }

    @Test
    fun `missing package returns product not available without purchasing`() {
        every { purchases.getOfferingsForPurchase(any()) } answers {
            firstArg<ReceiveOfferingsCallback>().onReceived(offerings)
        }

        purchasePackage(activity, "missing", context, null, null, null, result)

        verify(exactly = 1) {
            result.onError(match { it.code == PurchasesErrorCode.ProductNotAvailableForPurchaseError.code })
        }
        verify(exactly = 0) { purchases.purchase(any(), any()) }
    }
}
