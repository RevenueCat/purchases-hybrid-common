package com.revenuecat.purchases.hybridcommon


import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Parcel
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.SkuDetails
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PackageType
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.LogLevel
import com.revenuecat.purchases.ProductType
import com.revenuecat.purchases.PurchaseParams
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.common.PlatformInfo
import com.revenuecat.purchases.google.toStoreProduct
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.interfaces.Callback
import com.revenuecat.purchases.interfaces.GetStoreProductsCallback
import com.revenuecat.purchases.interfaces.LogInCallback
import com.revenuecat.purchases.interfaces.PurchaseCallback
import com.revenuecat.purchases.interfaces.ReceiveCustomerInfoCallback
import com.revenuecat.purchases.interfaces.ReceiveOfferingsCallback
import com.revenuecat.purchases.models.BillingFeature
import com.revenuecat.purchases.models.Period
import com.revenuecat.purchases.models.Price
import com.revenuecat.purchases.models.PricingPhase
import com.revenuecat.purchases.models.PurchasingData
import com.revenuecat.purchases.models.StoreProduct
import com.revenuecat.purchases.models.StoreTransaction
import com.revenuecat.purchases.models.SubscriptionOption
import com.revenuecat.purchases.models.SubscriptionOptions
import com.revenuecat.purchases.models.toRecurrenceMode
import com.revenuecat.purchases.purchaseWith
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
import kotlin.test.assertNotNull
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
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
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

        canMakePayments(mockContext,
            listOf(),
            onResult)

        assertEquals(receivedCanMakePayments, returnedResult.captured)
    }

    @Test
    fun `calling canMakePayments with empty list correctly passes through to Purchases`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every {
            Purchases.canMakePayments(mockContext, any(), any())
        } just Runs

        val onResult = mockk<OnResultAny<Boolean>>()
        every { onResult.onReceived(any()) } just Runs

        canMakePayments(mockContext,
                listOf(),
                onResult)

        verify(exactly = 1) {
            Purchases.canMakePayments(
                    mockContext,
                    listOf(),
                    any())
        }
    }

    @Test
    fun `canMakePayments correctly maps all integer values to BillingFeature enum type`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.canMakePayments(mockContext, any(), any()) } just runs

        val onResult = mockk<OnResultAny<Boolean>>()
        every { onResult.onReceived(any()) } just runs

        val billingFeatureValues = BillingFeature.values()

        billingFeatureValues.forEachIndexed { index, billingFeature ->
            canMakePayments(mockContext,
                    listOf(index),
                    onResult)

            verify(exactly = 1) {
                Purchases.canMakePayments(
                        mockContext,
                        listOf(billingFeature),
                        any())
            }
        }
    }

    @Test
    fun `calling canMakePayments with invalid integer results in error`() {
        configure(
                context = mockContext,
                apiKey = "api_key",
                appUserID = "appUserID",
                observerMode = true,
                platformInfo = PlatformInfo("flavor", "version")
        )

        every { Purchases.canMakePayments(mockContext, any(), any()) } just runs

        val onResultAny = mockk<OnResultAny<Boolean>>()
        every { onResultAny.onError(any())} just runs

        canMakePayments(mockContext,
                listOf(8),
                onResultAny)

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
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        every { mockPurchases.logIn(appUserID, any()) } just runs

        logIn(appUserID = appUserID, onResult = object : OnResult {
            override fun onReceived(map: Map<String, *>) {}
            override fun onError(errorContainer: ErrorContainer) {}
        })

        verify(exactly = 1) { mockPurchases.logIn(appUserID, any()) }
    }

    @Test
    fun `calling logIn correctly calls onReceived`() {
        val appUserID = "appUserID"

        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        val mockInfo = mockk<CustomerInfo>(relaxed = true)
        val mockCreated = Random.nextBoolean()

        val logInCallback = slot<LogInCallback>()
        every {
            mockPurchases.logIn(
                newAppUserID = appUserID,
                capture(logInCallback)
            )
        } just runs

        val onResult = mockk<OnResult>(relaxed = true)

        logIn(appUserID = appUserID, onResult = onResult)
        logInCallback.captured.onReceived(mockInfo, mockCreated)

        val mockInfoMap = mockInfo.map()

        verify(exactly = 1) {
            onResult.onReceived(mapOf(
                "created" to mockCreated,
                "customerInfo" to mockInfoMap
            ))
        }
    }

    @Test
    fun `calling logIn with error calls onError`() {
        val appUserID = "appUserID"

        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        val mockError = mockk<PurchasesError>(relaxed = true)

        val logInCallback = slot<LogInCallback>()
        every {
            mockPurchases.logIn(
                newAppUserID = appUserID,
                capture(logInCallback)
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
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )

        every { mockPurchases.logOut(any() as ReceiveCustomerInfoCallback?) } just runs

        logOut(onResult = object : OnResult {
            override fun onReceived(map: Map<String, *>) {}
            override fun onError(errorContainer: ErrorContainer) {}
        })

        verify(exactly = 1) { mockPurchases.logOut(any() as ReceiveCustomerInfoCallback?) }
    }

    @Test
    fun `calling logOut correctly calls onReceived`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
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
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
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

    @Test
    fun `purchaseProduct passes correct productIdentifier after a successful purchase`() {
        configure(
            context = mockContext,
            apiKey = "api_key",
            appUserID = "appUserID",
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )
        val expectedProductIdentifier = "product"
        var receivedResponse: MutableMap<String, *>? = null

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockPurchase = mockk<StoreTransaction>()
        every {
            mockPurchase.productIds
        } returns ArrayList(listOf(expectedProductIdentifier, "other"))

        every {
            mockPurchases.getProducts(listOf(expectedProductIdentifier), ProductType.SUBS, capture(capturedGetStoreProductsCallback))
        } answers {
            capturedGetStoreProductsCallback.captured.onReceived(listOf(mockStoreProduct))
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()
        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            val params = it.invocation.args.first() as PurchaseParams
            assertEquals(false, params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockPurchase, mockk(relaxed = true))
        }

        purchaseProduct(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            type = "subs",
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
            }
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
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )
        val expectedProductIdentifier = "product"
        var receivedResponse: MutableMap<String, *>? = null

        val capturedGetStoreProductsCallback = slot<GetStoreProductsCallback>()
        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockPurchase = mockk<StoreTransaction>()
        every {
            mockPurchase.productIds
        } returns ArrayList(listOf(expectedProductIdentifier, "other"))

        every {
            mockPurchases.getProducts(
                listOf(expectedProductIdentifier),
                ProductType.SUBS,
                capture(capturedGetStoreProductsCallback)
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

            capturedPurchaseCallback.captured.onCompleted(mockPurchase, mockk(relaxed = true))
        }

        purchaseProduct(
            mockActivity,
            productIdentifier = expectedProductIdentifier,
            type = "subs",
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
            }
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
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )
        val expectedProductIdentifier = "product"
        var receivedResponse: MutableMap<String, *>? = null

        val capturedReceiveOfferingsCallback = slot<ReceiveOfferingsCallback>()
        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockPurchase = mockk<StoreTransaction>()
        every {
            mockPurchase.productIds
        } returns ArrayList(listOf(expectedProductIdentifier, "other"))

        val (offeringIdentifier, packageToPurchase, offerings) = getOfferings(mockStoreProduct)

        every {
            mockPurchases.getOfferings(capture(capturedReceiveOfferingsCallback))
        } answers {
            capturedReceiveOfferingsCallback.captured.onReceived(offerings)
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()
2
        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            val params = it.invocation.args.first() as PurchaseParams
            assertEquals(false, params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockPurchase, mockk(relaxed = true))
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
            offeringIdentifier = offeringIdentifier
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
            observerMode = true,
            platformInfo = PlatformInfo("flavor", "version")
        )
        val expectedProductIdentifier = "product"
        var receivedResponse: MutableMap<String, *>? = null

        val capturedReceiveOfferingsCallback = slot<ReceiveOfferingsCallback>()
        val mockStoreProduct = stubStoreProduct(expectedProductIdentifier)
        val mockPurchase = mockk<StoreTransaction>()
        every {
            mockPurchase.productIds
        } returns ArrayList(listOf(expectedProductIdentifier, "other"))

        val (offeringIdentifier, packageToPurchase, offerings) = getOfferings(mockStoreProduct)

        every {
            mockPurchases.getOfferings(capture(capturedReceiveOfferingsCallback))
        } answers {
            capturedReceiveOfferingsCallback.captured.onReceived(offerings)
        }

        val capturedPurchaseCallback = slot<PurchaseCallback>()
        2
        every {
            mockPurchases.purchase(any<PurchaseParams>(), capture(capturedPurchaseCallback))
        } answers {
            val params = it.invocation.args.first() as PurchaseParams
            assertEquals(true, params.isPersonalizedPrice)

            capturedPurchaseCallback.captured.onCompleted(mockPurchase, mockk(relaxed = true))
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
            offeringIdentifier = offeringIdentifier
        )

        assertNotNull(receivedResponse)
        assertEquals(expectedProductIdentifier, receivedResponse?.get("productIdentifier"))
    }

    @Test
    fun `logs are passed correctly to LogHandler`() {
        val expectedMessage = "a message"
        LogLevel.values().forEach { logLevel ->
            setLogHandler { logDetails ->
                assertEquals(logLevel.name.uppercase(), logDetails["logLevel"])
                assertEquals(expectedMessage, logDetails["message"])
            }
            when(logLevel) {
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
            when(logLevel) {
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
            assertEquals("$expectedMessage. Throwable: java.lang.ClassCastException: what a pity", logDetails["message"])
        }
        Purchases.logHandler.e("Purchases", expectedMessage, java.lang.ClassCastException("what a pity"))
    }

    private fun getOfferings(mockStoreProduct: StoreProduct): Triple<String, Package, Offerings> {
        val offeringIdentifier = "offering"
        val packageToPurchase = Package(
            identifier = "packageIdentifier",
            packageType = PackageType.ANNUAL,
            product = mockStoreProduct,
            offering = offeringIdentifier
        )
        val offering = Offering(
            identifier = offeringIdentifier,
            serverDescription = "",
            availablePackages = listOf(packageToPurchase)
        )
        val offerings = Offerings(current = offering, all = mapOf(offeringIdentifier to offering))
        return Triple(offeringIdentifier, packageToPurchase, offerings)
    }

//    private fun mockSubscriptionProduct(expectedProductIdentifier: String): StoreProduct {
//        val mockSkuDetails = mockSkuDetails(
//            productId = expectedProductIdentifier,
//            type = BillingClient.SkuType.SUBS
//        )
//        return mockSkuDetails.toStoreProduct()
//    }
//
//    private fun mockSkuDetails(
//        productId: String = "monthly_intro_pricing_one_week",
//        @BillingClient.SkuType type: String = BillingClient.SkuType.SUBS,
//        price: Double = 4.99,
//        subscriptionPeriod: String = "P1M",
//        freeTrialPeriod: String? = null,
//    ): SkuDetails {
//        val mockedSkuDetails = mockk<SkuDetails>()
//        every { mockedSkuDetails.sku } returns productId
//        every { mockedSkuDetails.type } returns type
//        every { mockedSkuDetails.price } returns "${'$'}$price"
//        every { mockedSkuDetails.priceAmountMicros } returns price.times(1_000_000).toLong()
//        every { mockedSkuDetails.priceCurrencyCode } returns "USD"
//        every { mockedSkuDetails.subscriptionPeriod } returns subscriptionPeriod
//        every { mockedSkuDetails.freeTrialPeriod } returns (freeTrialPeriod ?: "")
//        every { mockedSkuDetails.introductoryPrice } returns ""
//        every { mockedSkuDetails.introductoryPricePeriod } returns ""
//        every { mockedSkuDetails.introductoryPriceAmountMicros } returns 0
//        every { mockedSkuDetails.introductoryPriceCycles } returns 0
//        every { mockedSkuDetails.iconUrl } returns ""
//        every { mockedSkuDetails.originalJson } returns """
//            {
//            "skuDetailsToken":"AEuhp4KxWQR-b-OAOXVicqHM4QqnqK9vkPnOXw0vSB9zWPBlTsW8TmtjSEJ_rJ6f0_-i",
//            "productId":"$productId",
//            "type":"$type",
//            "price":"${'$'}$price",
//            "price_amount_micros":${price.times(1_000_000)},
//            "price_currency_code":"USD",
//            "subscriptionPeriod":"$subscriptionPeriod",
//            "freeTrialPeriod":"$freeTrialPeriod",
//            "introductoryPricePeriod":"",
//            "introductoryPriceAmountMicros":0,
//            "introductoryPrice":"",
//            "introductoryPriceCycles":0,
//            "title":"Monthly Product Intro Pricing One Week (PurchasesSample)",
//            "description":"Monthly Product Intro Pricing One Week"
//        }
//        """.trimIndent()
//        every { mockedSkuDetails.title } returns "Monthly Product Intro Pricing One Week (PurchasesSample)"
//        every { mockedSkuDetails.description } returns "Monthly Product Intro Pricing One Week"
//        every { mockedSkuDetails.originalPrice } returns mockedSkuDetails.price
//        every { mockedSkuDetails.originalPriceAmountMicros } returns mockedSkuDetails.priceAmountMicros
//        return mockedSkuDetails
//    }
}

const val MICROS_MULTIPLIER = 1_000_000

@SuppressWarnings("EmptyFunctionBlock")
fun stubStoreProduct(
    productId: String,
    defaultOption: SubscriptionOption? = stubSubscriptionOption(
        "monthly_base_plan", productId,
        Period(1, Period.Unit.MONTH, "P1M"),
    ),
    subscriptionOptions: List<SubscriptionOption> = defaultOption?.let { listOf(defaultOption) } ?: emptyList(),
    price: Price = subscriptionOptions.first().fullPricePhase!!.price
): StoreProduct = object : StoreProduct {
    override val id: String
        get() = productId
    override val type: ProductType
        get() = ProductType.SUBS
    override val price: Price
        get() = price
    override val title: String
        get() = ""
    override val description: String
        get() = ""
    override val period: Period?
        get() = subscriptionOptions.firstOrNull { it.isBasePlan }?.pricingPhases?.get(0)?.billingPeriod
    override val subscriptionOptions: SubscriptionOptions
        get() = SubscriptionOptions(subscriptionOptions)
    override val defaultOption: SubscriptionOption?
        get() = defaultOption
    override val purchasingData: PurchasingData
        get() = StubPurchasingData(
            productId = productId
        )
    override val sku: String
        get() = productId

    override fun describeContents(): Int = 0

    override fun writeToParcel(dest: Parcel?, flags: Int) {}
}

@SuppressWarnings("EmptyFunctionBlock")
fun stubSubscriptionOption(
    id: String,
    productId: String,
    duration: Period = Period(1, Period.Unit.MONTH, "P1M"),
    pricingPhases: List<PricingPhase> = listOf(stubPricingPhase(billingPeriod = duration))
): SubscriptionOption = object : SubscriptionOption {
    override val id: String
        get() = id
    override val pricingPhases: List<PricingPhase>
        get() = pricingPhases
    override val tags: List<String>
        get() = listOf("tag")
    override val purchasingData: PurchasingData
        get() = StubPurchasingData(
            productId = productId
        )

    override fun describeContents(): Int = 0
    override fun writeToParcel(dest: Parcel?, flags: Int) {}
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
    price: Double = 4.99,
    recurrenceMode: Int = ProductDetails.RecurrenceMode.INFINITE_RECURRING,
    billingCycleCount: Int = 0
): PricingPhase = PricingPhase(
    billingPeriod,
    recurrenceMode.toRecurrenceMode(),
    billingCycleCount,
    Price(if (price == 0.0) "Free" else "${'$'}$price", price.times(MICROS_MULTIPLIER).toLong(), priceCurrencyCodeValue)
)