package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.EntitlementInfo
import com.revenuecat.purchases.OwnershipType
import com.revenuecat.purchases.PeriodType
import com.revenuecat.purchases.Store
import org.assertj.core.api.Assertions.assertThat
import org.json.JSONObject
import org.junit.jupiter.api.Test
import java.time.Instant
import java.util.Date

class EntitlementInfoMapperTests {

    private val storeDictionaryKey = "store"

    @Test
    fun `EntitlementInfo Store is correctly added to the dictionary`() {
        val expectations = arrayOf(
            Pair(Store.APP_STORE, "APP_STORE"),
            Pair(Store.MAC_APP_STORE, "MAC_APP_STORE"),
            Pair(Store.PLAY_STORE, "PLAY_STORE"),
            Pair(Store.STRIPE, "STRIPE"),
            Pair(Store.PROMOTIONAL, "PROMOTIONAL"),
            Pair(Store.UNKNOWN_STORE, "UNKNOWN_STORE"),
            Pair(Store.AMAZON, "AMAZON"),
        )

        for (expectation in expectations) {
            val (store, expectedDictionaryValue) = expectation
            val dictionary = generateMockEntitlementInfo(store = store).map()

            assertThat(dictionary[storeDictionaryKey])
                .`as`("Expected the dictionary's \"store\" value to equal \"$expectedDictionaryValue\" for the store value $store, but instead found \"${dictionary[storeDictionaryKey]}\".")
                .isEqualTo(expectedDictionaryValue)
        }
    }

    private fun generateMockEntitlementInfo(store: Store): EntitlementInfo {
        val purchaseDate = Date.from(Instant.EPOCH)

        return EntitlementInfo(
            identifier = "entitlement_id",
            isActive = true,
            willRenew = true,
            periodType = PeriodType.NORMAL,
            latestPurchaseDate = purchaseDate,
            originalPurchaseDate = purchaseDate,
            expirationDate = Date.from(Instant.ofEpochSecond(253370768400)), // Jan 1, 9999 @ 00:00:00UTC
            store = store,
            productIdentifier = "product_id",
            isSandbox = false,
            unsubscribeDetectedAt = null,
            billingIssueDetectedAt = null,
            ownershipType = OwnershipType.PURCHASED,
            jsonObject = JSONObject()
        )
    }
}
