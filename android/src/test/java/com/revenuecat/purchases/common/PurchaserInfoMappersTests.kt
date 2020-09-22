package com.revenuecat.purchases.common

import android.net.Uri
import com.revenuecat.purchases.PurchaserInfo
import com.revenuecat.purchases.common.mappers.map
import com.revenuecat.purchases.common.mappers.toIso8601
import com.revenuecat.purchases.common.mappers.toMillis
import com.revenuecat.purchases.models.Transaction
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe
import java.util.Date
import java.util.Dictionary

object PurchaserInfoMappersTests : Spek({

    describe("when mapping a PurchaserInfo") {
        val mockPurchaserInfo by memoized { mockk<PurchaserInfo>(relaxed = true) }

        context("with a null managementURL") {
            it("should map to a null managementURL") {
                every { mockPurchaserInfo.managementURL } returns null
                val map = mockPurchaserInfo.map()
                assertThat(map["managementURL"]).isNull()
            }
        }

        context("with a non-null managementURL") {
            it("should map to a non-null managementURL") {
                val expected = "https://www.url.com/"
                val mockkUri = mockk<Uri>(relaxed = true)
                every { mockPurchaserInfo.managementURL } returns mockkUri
                every { mockkUri.toString() } returns expected
                val map = mockPurchaserInfo.map()
                assertThat(map["managementURL"]).isEqualTo(expected)
            }
        }

        context("with an originalPurchaseDate") {
            it("should map to an originalPurchaseDate") {
                val date = Date()
                every { mockPurchaserInfo.originalPurchaseDate } returns date

                val map = mockPurchaserInfo.map()
                assertThat(map["originalPurchaseDate"]).isEqualTo(date.toIso8601())
                assertThat(map["originalPurchaseDateMillis"]).isEqualTo(date.toMillis())
            }
        }

        context("with empty non subscriptions") {
            it("should map to an empty array of non subscriptions") {
                every { mockPurchaserInfo.nonSubscriptionTransactions } returns emptyList()
                val map = mockPurchaserInfo.map()
                val mappedNonSubscriptionTransactions : List<Any> = map["nonSubscriptionTransactions"] as List<Any>
                assertThat(mappedNonSubscriptionTransactions).isEmpty()
            }
        }

        context("with non empty non subscriptions") {
            it("should map to a non empty array of non subscriptions") {
                val transaction = Transaction("revenuecatid", "productid", Date())
                every { mockPurchaserInfo.nonSubscriptionTransactions } returns listOf(transaction)

                val map = mockPurchaserInfo.map()
                val mappedNonSubscriptionTransactions : List<Any> = map["nonSubscriptionTransactions"] as List<Any>
                assertThat(mappedNonSubscriptionTransactions).isNotEmpty

                val transactionDictionary = mappedNonSubscriptionTransactions[0] as Map<*, *>
                assertThat(transactionDictionary["revenueCatId"]).isEqualTo(transaction.revenuecatId)
                assertThat(transactionDictionary["productId"]).isEqualTo(transaction.productId)
                assertThat(transactionDictionary["purchaseDateMillis"]).isEqualTo(transaction.purchaseDate.toMillis())
                assertThat(transactionDictionary["purchaseDate"]).isEqualTo(transaction.purchaseDate.toIso8601())

            }
        }

    }

})