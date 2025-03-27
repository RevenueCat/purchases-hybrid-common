package com.revenuecat.purchases.hybridcommon

import android.net.Uri
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.ExperimentalPreviewRevenueCatPurchasesAPI
import com.revenuecat.purchases.OwnershipType
import com.revenuecat.purchases.PeriodType
import com.revenuecat.purchases.Store
import com.revenuecat.purchases.SubscriptionInfo
import com.revenuecat.purchases.VirtualCurrencyInfo
import com.revenuecat.purchases.hybridcommon.mappers.map
import com.revenuecat.purchases.hybridcommon.mappers.toIso8601
import com.revenuecat.purchases.hybridcommon.mappers.toMillis
import com.revenuecat.purchases.models.Transaction
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.util.Date

internal class CustomerInfoMappersTests {
    val mockCustomerInfo = mockk<CustomerInfo>(relaxed = true)

    @Test
    fun `a CustomerInfo with a null managementURL, should map to a null managementURL`() {
        every { mockCustomerInfo.managementURL } returns null
        val map = mockCustomerInfo.map()
        assertThat(map["managementURL"]).isNull()
    }

    @Test
    fun `a CustomerInfo with a non-null managementURL, should map to a non-null managementURL`() {
        val expected = "https://www.url.com/"
        val mockkUri = mockk<Uri>(relaxed = true)
        every { mockCustomerInfo.managementURL } returns mockkUri
        every { mockkUri.toString() } returns expected
        val map = mockCustomerInfo.map()
        assertThat(map["managementURL"]).isEqualTo(expected)
    }

    @Test
    fun `a CustomerInfo with an originalPurchaseDate, should map to an originalPurchaseDate`() {
        val date = Date()
        every { mockCustomerInfo.originalPurchaseDate } returns date

        val map = mockCustomerInfo.map()
        assertThat(map["originalPurchaseDate"]).isEqualTo(date.toIso8601())
        assertThat(map["originalPurchaseDateMillis"]).isEqualTo(date.toMillis())
    }

    @Test
    fun `a CustomerInfo with empty non subscriptions, should map to an empty array of non subscriptions`() {
        every { mockCustomerInfo.nonSubscriptionTransactions } returns emptyList()
        val map = mockCustomerInfo.map()
        val mappedNonSubscriptionTransactions: List<Any> =
            map["nonSubscriptionTransactions"] as List<Any>
        assertThat(mappedNonSubscriptionTransactions).isEmpty()
    }

    @Test
    fun `a CustomerInfo with non empty non subscriptions, should map to a non empty array of non subscriptions`() {
        val transaction = Transaction(
            "transactionIdentifier",
            "transactionIdentifier",
            "productid",
            "productid",
            Date(),
            "storeTransactionId",
            Store.PLAY_STORE,
        )
        every { mockCustomerInfo.nonSubscriptionTransactions } returns listOf(transaction)

        val map = mockCustomerInfo.map()
        val mappedNonSubscriptionTransactions: List<Any> =
            map["nonSubscriptionTransactions"] as List<Any>
        assertThat(mappedNonSubscriptionTransactions).isNotEmpty

        val transactionDictionary = mappedNonSubscriptionTransactions[0] as Map<*, *>
        assertThat(transactionDictionary["transactionIdentifier"]).isEqualTo(transaction.transactionIdentifier)
        assertThat(transactionDictionary["revenueCatId"]).isEqualTo(transaction.transactionIdentifier)
        assertThat(transactionDictionary["productIdentifier"]).isEqualTo(transaction.productIdentifier)
        assertThat(transactionDictionary["productId"]).isEqualTo(transaction.productIdentifier)
        assertThat(transactionDictionary["purchaseDateMillis"]).isEqualTo(transaction.purchaseDate.toMillis())
        assertThat(transactionDictionary["purchaseDate"]).isEqualTo(transaction.purchaseDate.toIso8601())
    }

    @Test
    fun `a CustomerInfo with SubscriptionInfo, should map to a non empty map of subscription infos`() {
        val mockDate = Date()
        every { mockCustomerInfo.subscriptionsByProductIdentifier } returns mapOf(
            "productIdentifier" to SubscriptionInfo(
                productIdentifier = "productIdentifier",
                purchaseDate = mockDate,
                originalPurchaseDate = mockDate,
                expiresDate = mockDate,
                store = Store.PLAY_STORE,
                unsubscribeDetectedAt = mockDate,
                isSandbox = true,
                billingIssuesDetectedAt = mockDate,
                gracePeriodExpiresDate = mockDate,
                ownershipType = OwnershipType.PURCHASED,
                periodType = PeriodType.NORMAL,
                refundedAt = mockDate,
                storeTransactionId = "storeTransactionId",
                requestDate = mockDate,
            ),
        )

        val map = mockCustomerInfo.map()
        val mappedSubscriptionInfos = map["subscriptionsByProductIdentifier"] as Map<*, *>
        assertThat(mappedSubscriptionInfos).hasSize(1)
        val mappedSubscriptionInfo = mappedSubscriptionInfos["productIdentifier"] as Map<*, *>
        assertThat(mappedSubscriptionInfo["productIdentifier"]).isEqualTo("productIdentifier")
        assertThat(mappedSubscriptionInfo["purchaseDate"]).isEqualTo(mockDate.toIso8601())
        assertThat(mappedSubscriptionInfo["originalPurchaseDate"]).isEqualTo(mockDate.toIso8601())
        assertThat(mappedSubscriptionInfo["expiresDate"]).isEqualTo(mockDate.toIso8601())
        assertThat(mappedSubscriptionInfo["store"]).isEqualTo("PLAY_STORE")
        assertThat(mappedSubscriptionInfo["unsubscribeDetectedAt"]).isEqualTo(mockDate.toIso8601())
        assertThat(mappedSubscriptionInfo["isSandbox"]).isEqualTo(true)
        assertThat(mappedSubscriptionInfo["billingIssuesDetectedAt"]).isEqualTo(mockDate.toIso8601())
        assertThat(mappedSubscriptionInfo["gracePeriodExpiresDate"]).isEqualTo(mockDate.toIso8601())
        assertThat(mappedSubscriptionInfo["ownershipType"]).isEqualTo("PURCHASED")
        assertThat(mappedSubscriptionInfo["periodType"]).isEqualTo("NORMAL")
        assertThat(mappedSubscriptionInfo["refundedAt"]).isEqualTo(mockDate.toIso8601())
        assertThat(mappedSubscriptionInfo["storeTransactionId"]).isEqualTo("storeTransactionId")
        assertThat(mappedSubscriptionInfo["isActive"]).isEqualTo(false)
        assertThat(mappedSubscriptionInfo["willRenew"]).isEqualTo(false)
    }

    @OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
    @Test
    fun `a CustomerInfo with empty virtualCurrencies, should map to having an empty map of virtualCurrencies`() {
        every { mockCustomerInfo.virtualCurrencies } returns emptyMap()

        val map = mockCustomerInfo.map()
        val mappedVirtualCurrencies = map["virtualCurrencies"] as Map<*, *>

        assertThat(mappedVirtualCurrencies).isEmpty()
    }

    @OptIn(ExperimentalPreviewRevenueCatPurchasesAPI::class)
    @Test
    fun `a CustomerInfo with virtualCurrencies, should map to having a non-empty map of virtualCurrencies`() {
        val virtualCurrencyId = "REV_CAT"
        val virtualCurrencyBalance = 100L
        val mockVirtualCurrencyInfo = mockk<VirtualCurrencyInfo>()
        every { mockVirtualCurrencyInfo.balance } returns virtualCurrencyBalance

        every { mockCustomerInfo.virtualCurrencies } returns mapOf(
            virtualCurrencyId to mockVirtualCurrencyInfo,
        )

        val map = mockCustomerInfo.map()
        val mappedVirtualCurrencies = map["virtualCurrencies"] as Map<*, *>

        assertThat(mappedVirtualCurrencies).hasSize(1)
        val mappedVirtualCurrency = mappedVirtualCurrencies[virtualCurrencyId] as Map<*, *>
        assertThat(mappedVirtualCurrency["balance"]).isEqualTo(virtualCurrencyBalance)
    }
}
