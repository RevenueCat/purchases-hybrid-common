package com.revenuecat.purchases.hybridcommon

import android.app.Activity
import android.app.Application
import android.content.Context
import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.PurchaseParams
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesAreCompletedBy
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.hybridcommon.mappers.overrideMapperDispatcher
import com.revenuecat.purchases.interfaces.GetStoreProductsCallback
import com.revenuecat.purchases.interfaces.PurchaseCallback
import com.revenuecat.purchases.interfaces.ReceiveOfferingsCallback
import com.revenuecat.purchases.models.Period
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
import org.junit.jupiter.api.fail
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
internal class CommonKtPurchaseTests {

    private val mockApplicationContext = mockk<Application>(relaxed = true)
    private val mockContext = mockk<Context>(relaxed = true)
    private val mockPurchases = mockk<Purchases>()
    private val mockActivity = mockk<Activity>(relaxed = true)

    @BeforeEach
    fun setup() {
        mockkObject(Purchases)
        mockLogs()
        every {
            Purchases.configure(configuration = any())
        } returns mockPurchases
        every { mockContext.applicationContext } returns mockApplicationContext
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
    fun `purchase with packageIdentifier calls purchasePackage`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP.name,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val expectedPackageIdentifier = "monthly"
        var receivedResponse: MutableMap<String, *>? = null

        val mockStoreProduct = TestUtilities.stubStoreProduct("product_id")
        val mockTransaction = TestUtilities.createMockTransaction("product_id")
        val (offeringIdentifier, _, offerings) = TestUtilities.getOfferings(
            mockStoreProduct,
            packageIdentifier = expectedPackageIdentifier,
        )

        val capturedReceiveOfferingsCallback = slot<ReceiveOfferingsCallback>()
        every {
            mockPurchases.getOfferings(capture(capturedReceiveOfferingsCallback))
        } answers {
            capturedReceiveOfferingsCallback.captured.onReceived(offerings)
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()
        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        val options = mapOf(
            "packageIdentifier" to expectedPackageIdentifier,
            "presentedOfferingContext" to mapOf(
                "offeringIdentifier" to offeringIdentifier,
                "placementIdentifier" to "placement_id",
            ),
        )

        purchase(
            activity = mockActivity,
            options = options,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(error: ErrorContainer) {
                    fail("Expected success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals("product_id", receivedResponse!!["productIdentifier"])
    }

    @Test
    fun `purchase with packageIdentifier with add on store products with base plans calls purchasePackage`() {
        testPurchaseWithPackageIdentifierAndAddOnStoreProduct(
            baseProductId = "product_id:base_plan",
            addOnProductIds = listOf("addon_product:addon_base_plan"),
        )
    }

    @Test
    fun `purchase with packageIdentifier with add on store products without base plans calls purchasePackage`() {
        testPurchaseWithPackageIdentifierAndAddOnStoreProduct(
            baseProductId = "product_id",
            addOnProductIds = listOf("addon_product"),
        )
    }

    @Test
    fun `purchase with packageIdentifier with multiple add on store products calls purchasePackage`() {
        testPurchaseWithPackageIdentifierAndAddOnStoreProduct(
            baseProductId = "product_id",
            addOnProductIds = listOf("addon_product_one", "addon_product_two"),
        )
    }

    @Suppress("LongMethod")
    private fun testPurchaseWithPackageIdentifierAndAddOnStoreProduct(
        baseProductId: String,
        addOnProductIds: List<String>,
    ) {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP.name,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val expectedPackageIdentifier = "monthly"
        var receivedResponse: MutableMap<String, *>? = null

        val mockStoreProduct = TestUtilities.stubStoreProduct(baseProductId)
        val addOnStoreProducts = addOnProductIds.map { TestUtilities.stubStoreProduct(it) }
        val mockTransaction = TestUtilities.createMockTransaction(baseProductId)
        val (offeringIdentifier, _, offerings) = TestUtilities.getOfferings(
            mockStoreProduct,
            packageIdentifier = expectedPackageIdentifier,
        )

        val capturedReceiveOfferingsCallback = slot<ReceiveOfferingsCallback>()
        every {
            mockPurchases.getOfferings(capture(capturedReceiveOfferingsCallback))
        } answers {
            capturedReceiveOfferingsCallback.captured.onReceived(offerings)
        }

        val capturedProductIds = slot<List<String>>()
        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        every {
            mockPurchases.getProducts(
                capture(capturedProductIds),
                ProductType.SUBS,
                capture(capturedGetStoreProductsCallback)
            )
        } answers {
            capturedGetStoreProductsCallback.captured.onReceived(addOnStoreProducts)
        }

        val purchaseParamsSlot = slot<PurchaseParams>()
        val capturedPurchaseCallback = slot<PurchaseCallback>()
        every {
            mockPurchases.purchase(capture(purchaseParamsSlot), capture(capturedPurchaseCallback))
        } answers {
            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        val options = mapOf(
            "packageIdentifier" to expectedPackageIdentifier,
            "presentedOfferingContext" to mapOf(
                "offeringIdentifier" to offeringIdentifier,
                "placementIdentifier" to "placement_id",
            ),
            "addOnStoreProducts" to addOnProductIds.map {
                mapOf(
                    "productIdentifier" to it,
                    "type" to "subs",
                )
            },
        )

        purchase(
            activity = mockActivity,
            options = options,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(error: ErrorContainer) {
                    fail("Expected success")
                }
            },
        )

        val response = requireNotNull(receivedResponse) { "Expected response to be received" }
        assertEquals(baseProductId, response["productIdentifier"])
        assertTrue(purchaseParamsSlot.isCaptured)
        assertEquals(
            addOnProductIds.map { it.split(":").first() },
            capturedProductIds.captured,
        )
    }

    @Test
    fun `purchase with productIdentifier calls purchaseProduct`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP.name,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val expectedProductIdentifier = "product_id"
        var receivedResponse: MutableMap<String, *>? = null

        val mockStoreProduct = TestUtilities.stubStoreProduct(expectedProductIdentifier, type = ProductType.INAPP)
        val mockTransaction = TestUtilities.createMockTransaction(expectedProductIdentifier)

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        every {
            mockPurchases.getProducts(
                listOf(expectedProductIdentifier),
                ProductType.INAPP,
                capture(capturedGetStoreProductsCallback),
            )
        } answers {
            capturedGetStoreProductsCallback.captured.onReceived(listOf(mockStoreProduct))
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()
        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        val options = mapOf(
            "productIdentifier" to expectedProductIdentifier,
            "type" to "inapp",
        )

        purchase(
            activity = mockActivity,
            options = options,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(error: ErrorContainer) {
                    fail("Expected success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse!!["productIdentifier"])
    }

    @Test
    fun `purchase with productIdentifier includes add on store products with base plan calls purchaseProduct`() {
        testPurchaseWithProductIdentifierAndAddOnStoreProduct(
            baseProductId = "product_id:base_plan",
            addOnProductIds = listOf("addon_product:addon_base_plan"),
        )
    }

    @Test
    fun `purchase with productIdentifier includes add on store products without base plan calls purchaseProduct`() {
        testPurchaseWithProductIdentifierAndAddOnStoreProduct(
            baseProductId = "product_id",
            addOnProductIds = listOf("addon_product"),
        )
    }

    @Test
    fun `purchase with productIdentifier includes multiple add on store products calls purchaseProduct`() {
        testPurchaseWithProductIdentifierAndAddOnStoreProduct(
            baseProductId = "product_id",
            addOnProductIds = listOf("addon_product_one", "addon_product_two"),
        )
    }

    private fun testPurchaseWithProductIdentifierAndAddOnStoreProduct(
        baseProductId: String,
        addOnProductIds: List<String>,
    ) {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP.name,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        var receivedResponse: MutableMap<String, *>? = null

        val mockStoreProduct = TestUtilities.stubStoreProduct(baseProductId)
        val addOnStoreProducts = addOnProductIds.map { TestUtilities.stubStoreProduct(it) }
        val mockTransaction = TestUtilities.createMockTransaction(baseProductId)

        val capturedProductIds = slot<List<String>>()
        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        every {
            mockPurchases.getProducts(
                capture(capturedProductIds),
                ProductType.SUBS,
                capture(capturedGetStoreProductsCallback)
            )
        } answers {
            capturedGetStoreProductsCallback.captured.onReceived(listOf(mockStoreProduct) + addOnStoreProducts)
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()
        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        val options = mapOf(
            "productIdentifier" to baseProductId,
            "type" to "subs",
            "addOnStoreProducts" to addOnProductIds.map {
                mapOf(
                    "productIdentifier" to it,
                    "type" to "subs",
                )
            },
        )

        purchase(
            activity = mockActivity,
            options = options,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(error: ErrorContainer) {
                    fail("Expected success")
                }
            },
        )

        val response = requireNotNull(receivedResponse) { "Expected response to be received" }
        assertEquals(baseProductId, response["productIdentifier"])
        assertTrue(capturedPurchaseCallback.isCaptured)

        val expectedFetchedProductIds = listOf(baseProductId.split(":").first()) +
            addOnProductIds.map { it.split(":").first() }
        assertEquals(expectedFetchedProductIds, capturedProductIds.captured)
    }

    @Test
    fun `purchase with optionIdentifier and productIdentifier calls purchaseSubscriptionOption`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP.name,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val expectedProductIdentifier = "subscription_product"
        val expectedOptionIdentifier = "monthly_option"
        var receivedResponse: MutableMap<String, *>? = null

        val mockSubscriptionOption = TestUtilities.stubSubscriptionOption(
            expectedOptionIdentifier,
            expectedProductIdentifier,
            Period(1, Period.Unit.MONTH, "P1M"),
        )
        val mockStoreProduct = TestUtilities.stubStoreProduct(
            expectedProductIdentifier,
            subscriptionOptions = listOf(mockSubscriptionOption),
        )
        val mockTransaction = TestUtilities.createMockTransaction(expectedProductIdentifier)

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        every {
            mockPurchases.getProducts(
                listOf(expectedProductIdentifier),
                ProductType.SUBS,
                capture(capturedGetStoreProductsCallback),
            )
        } answers {
            capturedGetStoreProductsCallback.captured.onReceived(listOf(mockStoreProduct))
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()
        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        val options = mapOf(
            "productIdentifier" to expectedProductIdentifier,
            "optionIdentifier" to expectedOptionIdentifier,
        )

        purchase(
            activity = mockActivity,
            options = options,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(error: ErrorContainer) {
                    fail("Expected success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse!!["productIdentifier"])
    }

    @Test
    fun `purchase subscription option with add on store products with base plan calls purchaseSubscriptionOption`() {
        testPurchaseSubscriptionOptionWithAddOnStoreProduct(
            productIdentifier = "subscription_product:base_plan",
            addOnProductIdentifiers = listOf("addon_product:addon_base_plan"),
        )
    }

    @Test
    fun `purchase subscription option with add on store products without base plan calls purchaseSubscriptionOption`() {
        testPurchaseSubscriptionOptionWithAddOnStoreProduct(
            productIdentifier = "subscription_product",
            addOnProductIdentifiers = listOf("addon_product"),
        )
    }

    @Test
    fun `purchase subscription option with multiple add on store products calls purchaseSubscriptionOption`() {
        testPurchaseSubscriptionOptionWithAddOnStoreProduct(
            productIdentifier = "subscription_product",
            addOnProductIdentifiers = listOf("addon_product_one", "addon_product_two"),
        )
    }

    private fun testPurchaseSubscriptionOptionWithAddOnStoreProduct(
        productIdentifier: String,
        addOnProductIdentifiers: List<String>,
    ) {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP.name,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        var receivedResponse: MutableMap<String, *>? = null

        val mockSubscriptionOption = TestUtilities.stubSubscriptionOption(
            "monthly_option",
            productIdentifier,
        )
        val mockStoreProduct = TestUtilities.stubStoreProduct(
            productId = productIdentifier,
            subscriptionOptions = listOf(mockSubscriptionOption),
            defaultOption = mockSubscriptionOption,
            purchasingDataProductId = productIdentifier,
        )
        val addOnStoreProducts = addOnProductIdentifiers.map { TestUtilities.stubStoreProduct(it) }
        val mockTransaction = TestUtilities.createMockTransaction(productIdentifier)

        val capturedProductIds = slot<List<String>>()
        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        every {
            mockPurchases.getProducts(
                capture(capturedProductIds),
                ProductType.SUBS,
                capture(capturedGetStoreProductsCallback)
            )
        } answers {
            capturedGetStoreProductsCallback.captured.onReceived(
                listOf(mockStoreProduct) + addOnStoreProducts,
            )
        }

        val purchaseParamsSlot = slot<PurchaseParams>()
        val capturedPurchaseCallback = slot<PurchaseCallback>()
        every {
            mockPurchases.purchase(capture(purchaseParamsSlot), capture(capturedPurchaseCallback))
        } answers {
            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        val options = mapOf(
            "productIdentifier" to productIdentifier,
            "optionIdentifier" to "monthly_option",
            "addOnStoreProducts" to addOnProductIdentifiers.map {
                mapOf(
                    "productIdentifier" to it,
                    "type" to "subs",
                )
            },
        )

        purchase(
            activity = mockActivity,
            options = options,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(error: ErrorContainer) {
                    fail("Expected success")
                }
            },
        )

        val response = requireNotNull(receivedResponse) { "Expected response to be received" }
        assertEquals(productIdentifier, response["productIdentifier"])
        assertTrue(purchaseParamsSlot.isCaptured)
        assertEquals(listOf(productIdentifier), capturedProductIds.captured)
    }

    @Test
    fun `purchase with invalid options returns error`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP.name,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        var receivedError: ErrorContainer? = null

        val options = mapOf<String, Any?>() // Empty options

        purchase(
            activity = mockActivity,
            options = options,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    fail("Unexpected success: $map")
                }

                override fun onError(error: ErrorContainer) {
                    receivedError = error
                }
            },
        )

        assertNotNull(receivedError, "Expected error.")
        assertEquals(
            PurchasesErrorCode.PurchaseInvalidError.code,
            receivedError!!.code,
            "Expected error code ${PurchasesErrorCode.PurchaseInvalidError.code} but got ${receivedError!!.code}",
        )
    }

    @Test
    fun `purchase validates presentedOfferingContext with invalid keys`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP.name,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val expectedProductIdentifier = "product_id"
        var receivedResponse: MutableMap<String, *>? = null

        val mockStoreProduct = TestUtilities.stubStoreProduct(expectedProductIdentifier, type = ProductType.INAPP)
        val mockTransaction = TestUtilities.createMockTransaction(expectedProductIdentifier)

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        every {
            mockPurchases.getProducts(
                listOf(expectedProductIdentifier),
                ProductType.INAPP,
                capture(capturedGetStoreProductsCallback),
            )
        } answers {
            capturedGetStoreProductsCallback.captured.onReceived(listOf(mockStoreProduct))
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()
        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        val options = mapOf(
            "productIdentifier" to expectedProductIdentifier,
            "type" to "inapp",
            "presentedOfferingContext" to mapOf(
                123 to "invalid_key_type", // Non-string key should be filtered out
                "offeringIdentifier" to "default",
            ),
        )

        purchase(
            activity = mockActivity,
            options = options,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(error: ErrorContainer) {
                    fail("Expected success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse!!["productIdentifier"])
    }
}
