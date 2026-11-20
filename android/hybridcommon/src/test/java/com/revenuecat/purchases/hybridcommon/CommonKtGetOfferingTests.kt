package com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PackageType
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.hybridcommon.mappers.overrideMapperDispatcher
import com.revenuecat.purchases.interfaces.ReceiveOfferingsCallback
import com.revenuecat.purchases.models.Price
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.slot
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

@OptIn(ExperimentalCoroutinesApi::class)
internal class CommonKtGetOfferingTests {

    private val mockPurchases = mockk<Purchases>()

    private val currentOfferingIdentifier = "current_offering"
    private val otherOfferingIdentifier = "other_offering"
    private val targetingContext = PresentedOfferingContext.TargetingContext(revision = 2, ruleId = "test_rule")

    @BeforeEach
    fun setup() {
        mockkObject(Purchases)
        mockLogs()
        every { Purchases.sharedInstance } returns mockPurchases
        every { mockPurchases.store } returns Store.PLAY_STORE
        val testDispatcher = UnconfinedTestDispatcher()
        overrideMapperDispatcher = testDispatcher
        Dispatchers.setMain(testDispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `getOffering returns the current offering including its targeting context`() {
        // `Offerings.current` carries the targeting context while `all[identifier]` does not, which
        // is what the parser in purchases-android produces. Reading the wrong one silently drops
        // the targeting attribution.
        stubOfferings()

        var receivedMap: Map<String, Any?>? = null
        getOffering(currentOfferingIdentifier, onNullableResult { receivedMap = it })

        val packages = assertNotNull(receivedMap)["availablePackages"] as List<*>
        val presentedOfferingContext = (packages.first() as Map<*, *>)["presentedOfferingContext"] as Map<*, *>

        assertEquals(currentOfferingIdentifier, receivedMap!!["identifier"])
        assertEquals(
            mapOf("revision" to 2, "ruleId" to "test_rule"),
            presentedOfferingContext["targetingContext"],
        )
    }

    @Test
    fun `getOffering returns the catalog entry for an offering that is not current`() {
        stubOfferings()

        var receivedMap: Map<String, Any?>? = null
        getOffering(otherOfferingIdentifier, onNullableResult { receivedMap = it })

        val packages = assertNotNull(receivedMap)["availablePackages"] as List<*>
        val presentedOfferingContext = (packages.first() as Map<*, *>)["presentedOfferingContext"] as Map<*, *>

        assertEquals(otherOfferingIdentifier, receivedMap!!["identifier"])
        assertNull(presentedOfferingContext["targetingContext"])
    }

    @Test
    fun `getOffering returns null for an unknown identifier`() {
        stubOfferings()

        var called = false
        var receivedMap: Map<String, Any?>? = null
        getOffering(
            "doesnt exist",
            onNullableResult {
                called = true
                receivedMap = it
            },
        )

        assertEquals(true, called)
        assertNull(receivedMap)
    }

    /**
     * Mirrors what `OfferingParser` builds: `all` holds untargeted offerings, `current` is the same
     * offering re-created with the targeting context applied to its packages.
     */
    private fun stubOfferings() {
        val untargetedCurrent = stubOffering(currentOfferingIdentifier, targetingContext = null)
        val targetedCurrent = stubOffering(currentOfferingIdentifier, targetingContext = targetingContext)
        val other = stubOffering(otherOfferingIdentifier, targetingContext = null)

        val offerings = Offerings(
            current = targetedCurrent,
            all = mapOf(
                currentOfferingIdentifier to untargetedCurrent,
                otherOfferingIdentifier to other,
            ),
        )

        val callback = slot<ReceiveOfferingsCallback>()
        every { mockPurchases.getOfferings(capture(callback)) } answers {
            callback.captured.onReceived(offerings)
        }
    }

    private fun stubOffering(
        identifier: String,
        targetingContext: PresentedOfferingContext.TargetingContext?,
    ): Offering {
        // No subscription options, so the mapper does not try to format an intro price.
        val storeProduct = TestUtilities.stubStoreProduct(
            productId = "productIdentifier",
            defaultOption = null,
            subscriptionOptions = null,
            price = Price("$4.99", 4_990_000L, "USD"),
        )
        val availablePackage = Package(
            identifier = "packageIdentifier",
            packageType = PackageType.MONTHLY,
            product = storeProduct,
            presentedOfferingContext = PresentedOfferingContext(
                offeringIdentifier = identifier,
                placementIdentifier = null,
                targetingContext = targetingContext,
            ),
        )

        return Offering(
            identifier = identifier,
            serverDescription = "",
            availablePackages = listOf(availablePackage),
            metadata = emptyMap(),
        )
    }

    private fun onNullableResult(onReceived: (Map<String, Any?>?) -> Unit) = object : OnNullableResult {
        override fun onReceived(map: Map<String, *>?) {
            onReceived(map)
        }

        override fun onError(errorContainer: ErrorContainer) {
            throw AssertionError("Unexpected error: $errorContainer")
        }
    }
}
