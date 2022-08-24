package com.revenuecat.purchases.hybridcommon

import android.net.Uri
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.hybridcommon.mappers.toIso8601
import com.revenuecat.purchases.hybridcommon.mappers.toMillis
import com.revenuecat.purchases.hybridcommon.mappers.map
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
            val transaction = Transaction("transactionIdentifier", "transactionIdentifier", "productid", "productid", Date())
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
}
