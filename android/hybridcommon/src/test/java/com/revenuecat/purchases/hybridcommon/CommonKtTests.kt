package com.revenuecat.purchases.hybridcommon

import android.app.Activity
import android.app.Application
import android.content.Context
import com.android.billingclient.api.ProductDetails
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.LogLevel
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PackageType
import com.revenuecat.purchases.PresentedOfferingContext
import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.PurchaseParams
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesAreCompletedBy
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.hybridcommon.mappers.MappedProductCategory
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.interfaces.Callback
import com.revenuecat.purchases.interfaces.GetStoreProductsCallback
import com.revenuecat.purchases.interfaces.LogInCallback
import com.revenuecat.purchases.interfaces.PurchaseCallback
import com.revenuecat.purchases.interfaces.ReceiveCustomerInfoCallback
import com.revenuecat.purchases.interfaces.ReceiveOfferingsCallback
import com.revenuecat.purchases.models.BillingFeature
import com.revenuecat.purchases.models.GoogleProrationMode
import com.revenuecat.purchases.models.GoogleStoreProduct
import com.revenuecat.purchases.models.Period
import com.revenuecat.purchases.models.Price
import com.revenuecat.purchases.models.PricingPhase
import com.revenuecat.purchases.models.PurchasingData
import com.revenuecat.purchases.models.RecurrenceMode
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.models.StoreTransaction
import com.revenuecat.purchases.models.SubscriptionOption
import com.revenuecat.purchases.models.SubscriptionOptions
import io.mockk.Runs
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.runs
import io.mockk.slot
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.RepeatedTest
import org.junit.jupiter.api.Test
import java.net.URL
import kotlin.random.Random
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertIs
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlin.test.fail

internal class CommonKtTests {

    private val mockApplicationContext = mockk<Application>(relaxed = true)
    private val mockContext = mockk<Context>(relaxed = true)
    private val mockPurchases = mockk<Purchases>()
    private val mockActivity = mockk<Activity>(relaxed = true)

    @BeforeEach
    fun setup() {
        mockkObject(Purchases)
        every {
            Purchases.configure(configuration = any())
        } returns mockPurchases
        every { mockContext.applicationContext } returns mockApplicationContext
        every { Purchases.sharedInstance } returns mockPurchases
        every { mockPurchases.store } returns Store.PLAY_STORE
    }

    @Test
    fun `Calling setProxyURLString, sets the proxyURL correctly from a valid URL`() {
        assertEquals(Purchases.proxyURL, null)

        val urlString = "https://revenuecat.com"
        setProxyURLString(urlString)

        assertEquals(Purchases.proxyURL.toString(), urlString)
    }

    @Test
    fun `Calling setProxyURLString, sets the proxyURL to null from a null string`() {
        Purchases.proxyURL = URL("https://revenuecat.com")

        setProxyURLString(null)

        assertEquals(Purchases.proxyURL, null)
    }

    @Test
    fun `Calling setProxyURLString, raises exception if url string can't be parsed into a URL`() {
        assertFailsWith<java.net.MalformedURLException> {
            setProxyURLString("this is not a url")
        }
    }

    @RepeatedTest(5)
    fun `canMakePayments result successfully passed back`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val receivedCanMakePayments = Random.nextBoolean()

        val capturedCallback = slot<Callback<Boolean>>()
        every {
            Purchases.canMakePayments(mockContext, listOf(), capture(capturedCallback))
        } answers {
            capturedCallback.captured.also {
                it.onReceived(receivedCanMakePayments)
            }
        }

        val onResult = mockk<OnResultAny<Boolean>>()
        val returnedResult = slot<Boolean>()
        every { onResult.onReceived(capture(returnedResult)) } just runs

        canMakePayments(
            mockContext,
            listOf(),
            onResult,
        )

        assertEquals(receivedCanMakePayments, returnedResult.captured)
    }

    @Test
    fun `calling canMakePayments with empty list correctly passes through to Purchases`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        every {
            Purchases.canMakePayments(mockContext, any(), any())
        } just Runs

        val onResult = mockk<OnResultAny<Boolean>>()
        every { onResult.onReceived(any()) } just Runs

        canMakePayments(
            mockContext,
            listOf(),
            onResult,
        )

        verify(exactly = 1) {
            Purchases.canMakePayments(
                mockContext,
                listOf(),
                any(),
            )
        }
    }

    @Test
    fun `canMakePayments correctly maps all integer values to BillingFeature enum type`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        every { Purchases.canMakePayments(mockContext, any(), any()) } just runs

        val onResult = mockk<OnResultAny<Boolean>>()
        every { onResult.onReceived(any()) } just runs

        val billingFeatureValues = BillingFeature.values()

        billingFeatureValues.forEachIndexed { index, billingFeature ->
            canMakePayments(
                mockContext,
                listOf(index),
                onResult,
            )

            verify(exactly = 1) {
                Purchases.canMakePayments(
                    mockContext,
                    listOf(billingFeature),
                    any(),
                )
            }
        }
    }

    @Test
    fun `calling canMakePayments with invalid integer results in error`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        every { Purchases.canMakePayments(mockContext, any(), any()) } just runs

        val onResultAny = mockk<OnResultAny<Boolean>>()
        every { onResultAny.onError(any()) } just runs

        canMakePayments(
            mockContext,
            listOf(8),
            onResultAny,
        )

        verify(exactly = 1) {
            onResultAny.onError(any())
        }
    }

    @Test
    fun `calling logIn correctly passes call to Purchases`() {
        val appUserID = "appUserID"

        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        every { mockPurchases.logIn(appUserID, any()) } just runs

        logIn(
            appUserID = appUserID,
            onResult = object : OnResult {
                override fun onReceived(map: Map<String, *>) {}
                override fun onError(errorContainer: ErrorContainer) {}
            },
        )

        verify(exactly = 1) { mockPurchases.logIn(appUserID, any()) }
    }

    @Test
    fun `calling logIn correctly calls onReceived`() {
        val appUserID = "appUserID"

        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val mockInfo = mockk<CustomerInfo>(relaxed = true)
        val mockCreated = Random.nextBoolean()

        val logInCallback = slot<LogInCallback>()
        every {
            mockPurchases.logIn(
                newAppUserID = appUserID,
                capture(logInCallback),
            )
        } just runs

        val onResult = mockk<OnResult>(relaxed = true)

        logIn(appUserID = appUserID, onResult = onResult)
        logInCallback.captured.onReceived(mockInfo, mockCreated)

        val mockInfoMap = mockInfo.map()

        verify(exactly = 1) {
            onResult.onReceived(
                mapOf(
                    "created" to mockCreated,
                    "customerInfo" to mockInfoMap,
                ),
            )
        }
    }

    @Test
    fun `calling logIn with error calls onError`() {
        val appUserID = "appUserID"

        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val mockError = mockk<PurchasesError>(relaxed = true)

        val logInCallback = slot<LogInCallback>()
        every {
            mockPurchases.logIn(
                newAppUserID = appUserID,
                capture(logInCallback),
            )
        } just runs

        val onResult = mockk<OnResult>()
        every { onResult.onReceived(any()) } just runs
        every { onResult.onError(any()) } just runs

        logIn(appUserID = appUserID, onResult = onResult)
        logInCallback.captured.onError(mockError)

        val mockErrorMap = mockError.map()
        verify(exactly = 1) {
            onResult.onError(mockErrorMap)
        }
    }

    @Test
    fun `calling logOut correctly passes call to Purchases`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        every { mockPurchases.logOut(any() as ReceiveCustomerInfoCallback?) } just runs

        logOut(
            onResult = object : OnResult {
                override fun onReceived(map: Map<String, *>) {}
                override fun onError(errorContainer: ErrorContainer) {}
            },
        )

        verify(exactly = 1) { mockPurchases.logOut(any() as ReceiveCustomerInfoCallback?) }
    }

    @Test
    fun `calling logOut correctly calls onReceived`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val mockInfo = mockk<CustomerInfo>(relaxed = true)
        val receiveCustomerInfoListener = slot<ReceiveCustomerInfoCallback>()

        every { mockPurchases.logOut(capture(receiveCustomerInfoListener)) } just runs
        val onResult = mockk<OnResult>()
        every { onResult.onReceived(any()) } just runs
        every { onResult.onError(any()) } just runs

        logOut(onResult)

        receiveCustomerInfoListener.captured.onReceived(mockInfo)

        val mockInfoMap = mockInfo.map()
        verify(exactly = 1) { onResult.onReceived(mockInfoMap) }
    }

    @Test
    fun `calling logOut with error calls onError`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )

        val mockError = mockk<PurchasesError>(relaxed = true)
        val receiveCustomerInfoListener = slot<ReceiveCustomerInfoCallback>()

        every { mockPurchases.logOut(capture(receiveCustomerInfoListener)) } just runs
        val onResult = mockk<OnResult>()
        every { onResult.onReceived(any()) } just runs
        every { onResult.onError(any()) } just runs

        logOut(onResult)

        receiveCustomerInfoListener.captured.onError(mockError)

        val mockErrorMap = mockError.map()
        verify(exactly = 1) { onResult.onError(mockErrorMap) }
    }

    @Test
    fun `getPaymentDiscount returns an error`() {
        val error = getPromotionalOffer()
        assertEquals(PurchasesErrorCode.UnsupportedError.code, error.code)
        assertTrue(error.message.isNotEmpty())
    }

    @SuppressWarnings("LongMethod")
    @Test
    fun `purchaseProduct passes correct productIdentifier after a successful purchase`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedProductIdentifier = "product"
        val expectedTransactionIdentifier = "1"
        val expectedPurchaseDate: Long = 1000
        var receivedResponse: MutableMap<String, *>? = null

        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockTransaction = createMockTransaction(expectedProductIdentifier)

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
            val params = it.invocation.args.first() as PurchaseParams
            assertNull(params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchaseProduct(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            type = MappedProductCategory.SUBSCRIPTION.value,
            googleBasePlanId = null,
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            presentedOfferingContext = null,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))

        val transaction = receivedResponse?.get("transaction")
        assertIs<Map<String, Any>>(transaction)

        assertEquals(expectedTransactionIdentifier, transaction["transactionIdentifier"])
        assertEquals(expectedProductIdentifier, transaction["productIdentifier"])
        assertEquals(expectedPurchaseDate, transaction["purchaseDateMillis"])
    }

    @Test
    fun `purchaseProduct passes correct productIdentifier and legacy product type after a successful purchase`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedProductIdentifier = "product"
        var receivedResponse: MutableMap<String, *>? = null

        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockTransaction = createMockTransaction(expectedProductIdentifier)

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
            val params = it.invocation.args.first() as PurchaseParams
            assertNull(params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchaseProduct(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            type = "subs",
            googleBasePlanId = null,
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            presentedOfferingContext = null,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchaseProduct passes productIdentifier after successful purchase with presented offering identifier`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedOfferingIdentifier = "my-offer"
        val expectedProductIdentifier = "product"

        var receivedResponse: MutableMap<String, *>? = null

        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockTransaction = createMockTransaction(expectedProductIdentifier)

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
            val params = it.invocation.args.first() as PurchaseParams
            assertNull(params.isPersonalizedPrice)

            val presentedOfferingContext = getPresentedOfferingContext(params)
            assertEquals(PresentedOfferingContext(expectedOfferingIdentifier), presentedOfferingContext)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchaseProduct(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            type = "subs",
            googleBasePlanId = null,
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            presentedOfferingContext = PresentedOfferingContext(expectedOfferingIdentifier).map(),
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchaseProduct with base plan id in productIdentifier passes productIdentifier after successful purchase`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedProductIdentifier = "product"
        val expectedBasePlanIdentifier = "monthly"
        val expectedStoreProductIdentifier = "$expectedProductIdentifier:$expectedBasePlanIdentifier"

        var receivedResponse: MutableMap<String, *>? = null

        val mockTransaction = createMockTransaction(expectedProductIdentifier)

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        val mockStoreProduct = stubStoreProduct(expectedStoreProductIdentifier)

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
            val params = it.invocation.args.first() as PurchaseParams
            assertNull(params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchaseProduct(
            mockActivity,
            productIdentifier = expectedStoreProductIdentifier,
            type = "subs",
            googleBasePlanId = null,
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            presentedOfferingContext = null,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchaseProduct with base plan id passes correct productIdentifier after a successful purchase`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedProductIdentifier = "product"
        val expectedBasePlanIdentifier = "monthly"

        var receivedResponse: MutableMap<String, *>? = null

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()

        val mockPurchasingData = mockk<PurchasingData>(relaxed = true)
        every { mockPurchasingData.productId } returns expectedProductIdentifier

        val mockSubscriptionOption = mockk<SubscriptionOption>(relaxed = true)
        every { mockSubscriptionOption.purchasingData } returns mockPurchasingData

        val mockStoreProduct = GoogleStoreProduct(
            productId = expectedProductIdentifier,
            basePlanId = expectedBasePlanIdentifier,
            type = ProductType.SUBS,
            price = Price("", 0, ""),
            title = "",
            description = "",
            period = null,
            subscriptionOptions = SubscriptionOptions(listOf(mockSubscriptionOption)),
            defaultOption = mockSubscriptionOption,
            productDetails = mockk<ProductDetails>(relaxed = true),
        )

        val mockTransaction = createMockTransaction(expectedProductIdentifier)

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
            val params = it.invocation.args.first() as PurchaseParams
            assertNull(params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchaseProduct(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            type = "subs",
            googleBasePlanId = expectedBasePlanIdentifier,
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            presentedOfferingContext = null,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchaseProduct passes correct productIdentifier after a successful purchase with isPersonalizedPrice`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedProductIdentifier = "product"
        var receivedResponse: MutableMap<String, *>? = null

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)

        val mockTransaction = createMockTransaction(expectedProductIdentifier)

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
            val params = it.invocation.args.first() as PurchaseParams
            assertEquals(true, params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchaseProduct(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            type = "subs",
            googleBasePlanId = null,
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = true,
            presentedOfferingContext = null,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchasePackage passes correct productIdentifier after a successful purchase`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedProductIdentifier = "product"
        var receivedResponse: MutableMap<String, *>? = null

        val capturedReceiveOfferingsCallback = slot<ReceiveOfferingsCallback>()
        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockTransaction = createMockTransaction(expectedProductIdentifier)

        val (offeringIdentifier, packageToPurchase, offerings) = getOfferings(mockStoreProduct)

        every {
            mockPurchases.getOfferings(capture(capturedReceiveOfferingsCallback))
        } answers {
            capturedReceiveOfferingsCallback.captured.onReceived(offerings)
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()

        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            val params = it.invocation.args.first() as PurchaseParams
            assertNull(params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchasePackage(
            mockActivity,
            packageIdentifier = "packageIdentifier",
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
            presentedOfferingContext = PresentedOfferingContext(offeringIdentifier).map(),
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchasePackage passes correct productIdentifier after a successful purchase with isPersonalizedPrice`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedProductIdentifier = "product"
        var receivedResponse: MutableMap<String, *>? = null

        val capturedReceiveOfferingsCallback = slot<ReceiveOfferingsCallback>()
        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockTransaction = createMockTransaction(expectedProductIdentifier)

        val (offeringIdentifier, packageToPurchase, offerings) = getOfferings(mockStoreProduct)

        every {
            mockPurchases.getOfferings(capture(capturedReceiveOfferingsCallback))
        } answers {
            capturedReceiveOfferingsCallback.captured.onReceived(offerings)
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()

        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            val params = it.invocation.args.first() as PurchaseParams
            assertEquals(true, params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchasePackage(
            mockActivity,
            packageIdentifier = "packageIdentifier",
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = true,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
            presentedOfferingContext = PresentedOfferingContext(offeringIdentifier).map(),
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchaseSubscriptionOption passes correct productIdentifier after a successful purchase`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedProductIdentifier = "product"
        val expectedOptionIdentifier = "monthly"
        var receivedResponse: MutableMap<String, *>? = null

        val subscriptionOption = stubSubscriptionOption(
            expectedOptionIdentifier,
            productId = expectedProductIdentifier,
        )

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        val mockStoreProduct = stubStoreProduct(
            expectedProductIdentifier,
            defaultOption = subscriptionOption,
        )
        val mockTransaction = createMockTransaction(expectedProductIdentifier)

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
            val params = it.invocation.args.first() as PurchaseParams
            assertNull(params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchaseSubscriptionOption(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            optionIdentifier = expectedOptionIdentifier,
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            presentedOfferingContext = null,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchaseSubscriptionOption passes productIdentifier after successful purchase with presented offeringId`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            purchasesAreCompletedBy = PurchasesAreCompletedBy.MY_APP,
            platformInfo = PlatformInfo("flavor", "version"),
        )
        val expectedOfferingIdentifier = "my-offers"

        val expectedProductIdentifier = "product"
        val expectedOptionIdentifier = "monthly"
        var receivedResponse: MutableMap<String, *>? = null

        val subscriptionOption = stubSubscriptionOption(
            expectedOptionIdentifier,
            productId = expectedProductIdentifier,
        )

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        val mockStoreProduct = stubStoreProduct(
            expectedProductIdentifier,
            defaultOption = subscriptionOption,
        )
        val mockTransaction = createMockTransaction(expectedProductIdentifier)

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
            val params = it.invocation.args.first() as PurchaseParams
            assertNull(params.isPersonalizedPrice)

            val presentedOfferingContext = getPresentedOfferingContext(params)
            assertEquals(PresentedOfferingContext(expectedOfferingIdentifier), presentedOfferingContext)

            capturedPurchaseCallback.captured.onCompleted(mockTransaction, mockk(relaxed = true))
        }

        purchaseSubscriptionOption(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            optionIdentifier = expectedOptionIdentifier,
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            presentedOfferingContext = PresentedOfferingContext(expectedOfferingIdentifier).map(),
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    receivedResponse = map
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("Should be success")
                }
            },
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `purchaseSubscriptionOption errors when store is Amazon`() {
        every { mockPurchases.store } returns Store.AMAZON

        var receivedErrorContainer: ErrorContainer? = null

        purchaseSubscriptionOption(
            mockActivity,
            productIdentifier = "product",
            optionIdentifier = "option",
            googleOldProductId = null,
            googleProrationMode = null,
            googleIsPersonalizedPrice = null,
            presentedOfferingContext = null,
            onResult = object : OnResult {
                override fun onReceived(map: MutableMap<String, *>) {
                    fail("Should be success")
                }

                override fun onError(errorContainer: ErrorContainer) {
                    receivedErrorContainer = errorContainer
                }
            },
        )

        assertNotNull(receivedErrorContainer)
    }

    @Test
    fun `logs are passed correctly to LogHandler`() {
        val expectedMessage = "a message"
        LogLevel.values().forEach { logLevel ->
            setLogHandler { logDetails ->
                assertEquals(logLevel.name.uppercase(), logDetails["logLevel"])
                assertEquals(expectedMessage, logDetails["message"])
            }
            when (logLevel) {
                LogLevel.VERBOSE -> Purchases.logHandler.v("Purchases", expectedMessage)
                LogLevel.DEBUG -> Purchases.logHandler.d("Purchases", expectedMessage)
                LogLevel.INFO -> Purchases.logHandler.i("Purchases", expectedMessage)
                LogLevel.WARN -> Purchases.logHandler.w("Purchases", expectedMessage)
                LogLevel.ERROR -> Purchases.logHandler.e("Purchases", expectedMessage, null)
            }
        }
    }

    @Test
    fun `logs are passed correctly to LogHandlerWithOnResult`() {
        val expectedMessage = "a message"
        LogLevel.values().forEach { logLevel ->
            setLogHandlerWithOnResult(object : OnResult {
                override fun onReceived(logDetails: MutableMap<String, *>) {
                    assertEquals(logLevel.name.uppercase(), logDetails["logLevel"])
                    assertEquals(expectedMessage, logDetails["message"])
                }

                override fun onError(errorContainer: ErrorContainer) {
                    fail("onError shouldn't be called")
                }
            })
            when (logLevel) {
                LogLevel.VERBOSE -> Purchases.logHandler.v("Purchases", expectedMessage)
                LogLevel.DEBUG -> Purchases.logHandler.d("Purchases", expectedMessage)
                LogLevel.INFO -> Purchases.logHandler.i("Purchases", expectedMessage)
                LogLevel.WARN -> Purchases.logHandler.w("Purchases", expectedMessage)
                LogLevel.ERROR -> Purchases.logHandler.e("Purchases", expectedMessage, null)
            }
        }
    }

    @Test
    fun `error logs include error in message`() {
        val expectedMessage = "a message"
        setLogHandler { logDetails ->
            assertEquals("ERROR", logDetails["logLevel"])
            assertEquals(
                "$expectedMessage. Throwable: java.lang.ClassCastException: what a pity",
                logDetails["message"],
            )
        }
        Purchases.logHandler.e("Purchases", expectedMessage, java.lang.ClassCastException("what a pity"))
    }

    @Test
    fun `getGoogleProrationMode returns null if null prorationModeIndex`() {
        val prorationModeInt: Int? = null

        val mode = getGoogleProrationMode(prorationModeInt)
        assertEquals(mode, null)
    }

    @Test
    fun `getGoogleProrationMode returns IMMEDIATE_WITHOUT_PRORATION for 3`() {
        val prorationModeInt: Int? = 3

        val mode = getGoogleProrationMode(prorationModeInt)
        assertEquals(mode, GoogleProrationMode.IMMEDIATE_WITHOUT_PRORATION)
    }

    @Test
    fun `getGoogleProrationMode returns IMMEDIATE_WITH_TIME_PRORATION for 1`() {
        val prorationModeInt: Int? = 1

        val mode = getGoogleProrationMode(prorationModeInt)
        assertEquals(mode, GoogleProrationMode.IMMEDIATE_WITH_TIME_PRORATION)
    }

    @Test
    fun `getGoogleProrationMode throws exception for negative out of bounds number`() {
        val prorationModeInt: Int? = -1

        var catchWasCalled = false
        try {
            val mode = getGoogleProrationMode(prorationModeInt)
        } catch (e: InvalidProrationModeException) {
            catchWasCalled = true
        }

        assertTrue(catchWasCalled)
    }

    @Test
    fun `getGoogleProrationMode throws exception for position out of bounds number`() {
        val prorationModeInt: Int? = 1000

        var catchWasCalled = false
        try {
            val mode = getGoogleProrationMode(prorationModeInt)
        } catch (e: InvalidProrationModeException) {
            catchWasCalled = true
        }

        assertTrue(catchWasCalled)
    }

    @Test
    fun `mapStringToProductType returns ProductType SUBS for subs`() {
        val productType = mapStringToProductType("subs")
        assertEquals(ProductType.SUBS, productType)
    }

    @Test
    fun `mapStringToProductType returns ProductType SUBS for SUBSCRIPTION`() {
        val productType = mapStringToProductType("SUBSCRIPTION")
        assertEquals(ProductType.SUBS, productType)
    }

    @Test
    fun `mapStringToProductType returns ProductType INAPP for inapp`() {
        val productType = mapStringToProductType("inapp")
        assertEquals(ProductType.INAPP, productType)
    }

    @Test
    fun `mapStringToProductType returns ProductType INAPP for NON_SUBSCRIPTION`() {
        val productType = mapStringToProductType("NON_SUBSCRIPTION")
        assertEquals(ProductType.INAPP, productType)
    }

    @Test
    fun `offerings maps with empty metadata`() {
        val productIdentifier = "product"
        val mockStoreProduct = stubStoreProduct(productIdentifier)
        val (offeringIdentifier, packageToPurchase, offerings) = getOfferings(mockStoreProduct, metadata = emptyMap())

        val mappedOffering = offerings.map()["current"] as Map<*, *>
        val mappedMetadata = mappedOffering["metadata"] as Map<*, *>

        assertEquals(emptyMap<String, Any>(), mappedMetadata)
    }

    @Test
    fun `offerings maps with metadata`() {
        val metadata = mapOf(
            "int" to 5,
            "double" to 5.5,
            "boolean" to true,
            "string" to "five",
            "array" to listOf("five"),
            "dictionary" to mapOf(
                "string" to "five",
            ),
        )

        val productIdentifier = "product"
        val mockStoreProduct = stubStoreProduct(productIdentifier)
        val (offeringIdentifier, packageToPurchase, offerings) = getOfferings(mockStoreProduct, metadata = metadata)

        val mappedOffering = offerings.map()["current"] as Map<*, *>
        val mappedMetadata = mappedOffering["metadata"] as Map<*, *>

        assertEquals(metadata, mappedMetadata)
    }

    private fun getOfferings(
        mockStoreProduct: StoreProduct,
        metadata: Map<String, Any> = emptyMap(),
    ): Triple<String, Package, Offerings> {
        val offeringIdentifier = "offering"
        val packageToPurchase = Package(
            identifier = "packageIdentifier",
            packageType = PackageType.ANNUAL,
            product = mockStoreProduct,
            offering = offeringIdentifier,
        )
        val offering = Offering(
            identifier = offeringIdentifier,
            serverDescription = "",
            availablePackages = listOf(packageToPurchase),
            metadata = metadata,
        )
        val offerings = Offerings(current = offering, all = mapOf(offeringIdentifier to offering))
        return Triple(offeringIdentifier, packageToPurchase, offerings)
    }
}

const val MICROS_MULTIPLIER = 1_000_000

fun getPresentedOfferingContext(purchaseParams: PurchaseParams): PresentedOfferingContext? {
    // Uses reflection to test presentedOfferingContext exists in purchasing params
    val prop = PurchaseParams::class.members.firstOrNull { member -> member.name == "presentedOfferingContext" }
    return prop!!.call(purchaseParams) as? PresentedOfferingContext?
}

@SuppressWarnings("EmptyFunctionBlock", "LongParameterList")
fun stubStoreProduct(
    productId: String,
    description: String = "",
    title: String = "",
    name: String = "",
    type: ProductType = ProductType.SUBS,
    defaultOption: SubscriptionOption? = stubSubscriptionOption(
        "monthly_base_plan",
        productId,
        Period(1, Period.Unit.MONTH, "P1M"),
    ),
    subscriptionOptions: List<SubscriptionOption>? = defaultOption?.let { listOf(defaultOption) } ?: emptyList(),
    price: Price = subscriptionOptions?.firstOrNull()?.fullPricePhase!!.price,
    presentedOfferingContext: PresentedOfferingContext? = null,
): StoreProduct = object : StoreProduct {
    override val id: String
        get() = productId
    override val type: ProductType
        get() = type
    override val price: Price
        get() = price
    override val title: String
        get() = title
    override val name: String
        get() = name
    override val description: String
        get() = description
    override val period: Period?
        get() = subscriptionOptions?.firstOrNull { it.isBasePlan }?.pricingPhases?.get(0)?.billingPeriod
    override val presentedOfferingContext: PresentedOfferingContext?
        get() = presentedOfferingContext
    override val presentedOfferingIdentifier: String?
        get() = presentedOfferingContext?.offeringIdentifier
    override val subscriptionOptions: SubscriptionOptions?
        get() = subscriptionOptions?.let { SubscriptionOptions(it) }
    override val defaultOption: SubscriptionOption?
        get() = defaultOption
    override val purchasingData: PurchasingData
        get() = StubPurchasingData(
            productId = productId.split(":").first(),
        )
    override val sku: String
        get() = productId
    override fun copyWithOfferingId(offeringId: String): StoreProduct {
        return copyWithPresentedOfferingContext(PresentedOfferingContext(offeringId))
    }
    override fun copyWithPresentedOfferingContext(
        presentedOfferingContext: PresentedOfferingContext?,
    ): StoreProduct {
        fun SubscriptionOption.applyOfferingContext(
            presentedOfferingContext: PresentedOfferingContext?,
        ): SubscriptionOption {
            return stubSubscriptionOption(
                id,
                productId,
                presentedOfferingContext = presentedOfferingContext,
            )
        }

        return stubStoreProduct(
            productId,
            description,
            title,
            name,
            type,
            defaultOption?.let {
                it.applyOfferingContext(presentedOfferingContext)
            },
            subscriptionOptions?.map {
                it.applyOfferingContext(presentedOfferingContext)
            },
            price,
            presentedOfferingContext,
        )
    }
}

@SuppressWarnings("EmptyFunctionBlock")
fun stubSubscriptionOption(
    id: String,
    productId: String,
    duration: Period = Period(1, Period.Unit.MONTH, "P1M"),
    pricingPhases: List<PricingPhase> = listOf(stubPricingPhase(billingPeriod = duration)),
    presentedOfferingContext: PresentedOfferingContext? = null,
): SubscriptionOption = object : SubscriptionOption {
    override val id: String
        get() = id
    override val presentedOfferingContext: PresentedOfferingContext?
        get() = presentedOfferingContext
    override val presentedOfferingIdentifier: String?
        get() = presentedOfferingContext?.offeringIdentifier
    override val pricingPhases: List<PricingPhase>
        get() = pricingPhases
    override val tags: List<String>
        get() = listOf("tag")
    override val purchasingData: PurchasingData
        get() = StubPurchasingData(
            productId = productId,
        )
}

private fun createMockTransaction(
    productIdentifier: String,
    transactionIdentifier: String = "1",
    purchaseDate: Long = 1000,
): StoreTransaction {
    val mockTransaction = mockk<StoreTransaction>()
    every {
        mockTransaction.productIds
    } returns ArrayList(listOf(productIdentifier, "other"))
    every {
        mockTransaction.orderId
    } returns transactionIdentifier
    every {
        mockTransaction.purchaseTime
    } returns purchaseDate

    return mockTransaction
}

@SuppressWarnings("MatchingDeclarationName")
private data class StubPurchasingData(
    override val productId: String,
) : PurchasingData {
    override val productType: ProductType
        get() = ProductType.SUBS
}

fun stubPricingPhase(
    billingPeriod: Period = Period(1, Period.Unit.MONTH, "P1M"),
    priceCurrencyCodeValue: String = "USD",
    priceFormatted: String = "$4.99",
    price: Double = 4.99,
    recurrenceMode: RecurrenceMode = RecurrenceMode.INFINITE_RECURRING,
    billingCycleCount: Int = 0,
): PricingPhase = PricingPhase(
    billingPeriod,
    recurrenceMode,
    billingCycleCount,
    Price(priceFormatted, price.times(MICROS_MULTIPLIER).toLong(), priceCurrencyCodeValue),
)
