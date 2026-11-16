package com.revenuecat.purchases.hybridcommon

import android.app.Activity
import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PackagePurchaseReference
import com.revenuecat.purchases.PackageType
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.PurchaseParams
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.hybridcommon.mappers.overrideMapperDispatcher
import com.revenuecat.purchases.interfaces.GetPackagesForPurchaseCallback
import com.revenuecat.purchases.interfaces.PurchaseCallback
import com.revenuecat.purchases.interfaces.ReceiveOfferingsCallback
import com.revenuecat.purchases.models.GooglePurchasingData
import com.revenuecat.purchases.models.Period
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.models.StoreReplacementMode
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

@OptIn(
    InternalRevenueCatAPI::class,
    ExperimentalCoroutinesApi::class,
    ExperimentalPreviewRevenueCatPurchasesAPI::class,
)
internal class PurchasePackageConfigReadinessTests {
    private val purchases = mockk<Purchases>()
    private val activity = mockk<Activity>()
    private val result = mockk<OnResult>(relaxed = true)
    private val mainPackage = googlePackage("offering", "monthly", "monthly-product")
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
    fun `package batch purchase attaches ordered add ons while ordinary readiness is pending`() {
        val firstAddOn = googlePackage("other-offering", "monthly", "other-product")
        val secondAddOn = googlePackage("offering", "Extra", "extra-product")
        val ordinaryCallback = slot<ReceiveOfferingsCallback>()
        every { purchases.getOfferings(capture(ordinaryCallback)) } just Runs
        val mainReference = slot<PackagePurchaseReference>()
        val addOnReferences = slot<List<PackagePurchaseReference>>()
        every { purchases.getPackagesForPurchase(capture(mainReference), capture(addOnReferences), any()) } answers {
            thirdArg<GetPackagesForPurchaseCallback>().onReceived(
                mainPackage, listOf(firstAddOn, secondAddOn, firstAddOn),
            )
        }
        val params = slot<PurchaseParams>()
        val callback = slot<PurchaseCallback>()
        every { purchases.purchase(capture(params), capture(callback)) } just Runs
        purchases.getOfferings(mockk(relaxed = true))

        purchasePackage(
            activity, "MONTHLY", context, "old-product", null, true, result,
            addOnPackages = listOf(
                rawReference("other-offering", "monthly"),
                rawReference("offering", "Extra"),
                rawReference("other-offering", "monthly"),
            ),
            storeReplacementModeString = "WITH_TIME_PRORATION",
        )

        assertTrue(params.isCaptured)
        assertEquals(PackagePurchaseReference("offering", "MONTHLY"), mainReference.captured)
        assertEquals(
            listOf(
                PackagePurchaseReference("other-offering", "monthly"),
                PackagePurchaseReference("offering", "Extra"),
                PackagePurchaseReference("other-offering", "monthly"),
            ),
            addOnReferences.captured,
        )
        val data = params.captured.purchasingDataForPreview as GooglePurchasingData.Subscription
        assertEquals("monthly-product", data.productId)
        assertEquals(
            listOf("other-product", "extra-product", "other-product"),
            data.addOnProducts?.map { it.productId },
        )
        val presented = PurchaseParams::class.members
            .first { it.name == "presentedOfferingContext" }.call(params.captured) as PresentedOfferingContext?
        assertEquals("offering", presented?.offeringIdentifier)
        assertEquals("upgrade-placement", presented?.placementIdentifier)
        assertEquals(7, presented?.targetingContext?.revision)
        assertEquals("upgrade-rule", presented?.targetingContext?.ruleId)
        assertEquals("old-product", params.captured.oldProductId)
        assertEquals(StoreReplacementMode.WITH_TIME_PRORATION, params.captured.replacementMode)
        assertEquals(true, params.captured.isPersonalizedPrice)

        ordinaryCallback.captured.onReceived(mockk())
        verify(exactly = 1) { purchases.getPackagesForPurchase(any(), any(), any()) }
        verify(exactly = 1) { purchases.purchase(any(), any()) }
        callback.captured.onCompleted(TestUtilities.createMockTransaction("monthly-product"), mockk(relaxed = true))
        verify(exactly = 1) { result.onReceived(any()) }
        verify(exactly = 0) { result.onError(any()) }
    }

    @Test
    fun `purchase lookup failure returns original error without purchasing`() {
        val expected = PurchasesError(PurchasesErrorCode.NetworkError, "purchase lookup failed")
        every { purchases.getPackagesForPurchase(any(), any(), any()) } answers {
            thirdArg<GetPackagesForPurchaseCallback>().onError(expected)
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
    fun `missing main package returns product not available without purchasing`() {
        every { purchases.getPackagesForPurchase(any(), any(), any()) } answers {
            thirdArg<GetPackagesForPurchaseCallback>().onError(
                PurchasesError(
                    PurchasesErrorCode.ProductNotAvailableForPurchaseError,
                    "Couldn't find product for package missing",
                ),
            )
        }

        purchasePackage(activity, "missing", context, null, null, null, result)

        verify(exactly = 1) {
            result.onError(match { it.code == PurchasesErrorCode.ProductNotAvailableForPurchaseError.code })
        }
        verify(exactly = 0) { purchases.purchase(any(), any()) }
    }

    @Test
    fun `missing later add on prevents partial purchase`() {
        every { purchases.getPackagesForPurchase(any(), any(), any()) } answers {
            thirdArg<GetPackagesForPurchaseCallback>().onError(
                PurchasesError(
                    PurchasesErrorCode.PurchaseInvalidError,
                    "Could not find package with identifier missing in offering with identifier offering",
                ),
            )
        }

        purchasePackage(
            activity,
            "monthly",
            context,
            null,
            null,
            null,
            result,
            addOnPackages = listOf(rawReference("offering", "Extra"), rawReference("offering", "missing")),
        )

        verify(exactly = 1) { result.onError(match { it.code == PurchasesErrorCode.PurchaseInvalidError.code }) }
        verify(exactly = 0) { purchases.purchase(any(), any()) }
    }

    @Test
    fun `add on entries without package identifiers are skipped`() {
        val references = slot<List<PackagePurchaseReference>>()
        every { purchases.getPackagesForPurchase(any(), capture(references), any()) } answers {
            thirdArg<GetPackagesForPurchaseCallback>().onReceived(mainPackage, emptyList())
        }
        every { purchases.purchase(any(), any()) } just Runs

        purchasePackage(
            activity,
            "monthly",
            context,
            null,
            null,
            null,
            result,
            addOnPackages = listOf(emptyMap(), mapOf("packageIdentifier" to 42)),
        )

        assertTrue(references.captured.isEmpty())
        verify(exactly = 1) { purchases.purchase(any(), any()) }
        verify(exactly = 0) { result.onError(any()) }
    }

    private fun rawReference(offeringId: String, packageId: String): Map<String, Any?> = mapOf(
        "packageIdentifier" to packageId,
        "presentedOfferingContext" to mapOf("offeringIdentifier" to offeringId, "placementIdentifier" to "addon-place"),
    )

    private fun googlePackage(offeringId: String, packageId: String, productId: String): Package {
        val data = GooglePurchasingData.Subscription(
            productId,
            "monthly-option",
            mockk(),
            "offer-token",
            billingPeriod = Period(1, Period.Unit.MONTH, "P1M"),
        )
        val product = mockk<StoreProduct>()
        every { product.purchasingData } returns data
        return Package(packageId, PackageType.CUSTOM, product, PresentedOfferingContext(offeringId))
    }
}
