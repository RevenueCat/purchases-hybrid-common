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
    fun `Setting the store to APP STORE correctly adds APP_STORE to the dictionary`() {
        val expectedDictionaryValue = "APP_STORE"
        val mockEntitlementInfo = generateMockEntitlementInfo(store = Store.APP_STORE)
        val dictionary = mockEntitlementInfo.map()

        assertThat(dictionary[storeDictionaryKey]).isEqualTo(expectedDictionaryValue)
    }

    @Test
    fun `Setting the store to MAC APP STORE correctly adds MAC_APP_STORE to the dictionary`() {
        val expectedDictionaryValue = "MAC_APP_STORE"
        val mockEntitlementInfo = generateMockEntitlementInfo(store = Store.MAC_APP_STORE)
        val dictionary = mockEntitlementInfo.map()

        assertThat(dictionary[storeDictionaryKey]).isEqualTo(expectedDictionaryValue)
    }

    @Test
    fun `Setting the store to PLAY STORE correctly adds PLAY_STORE to the dictionary`() {
        val expectedDictionaryValue = "PLAY_STORE"
        val mockEntitlementInfo = generateMockEntitlementInfo(store = Store.PLAY_STORE)
        val dictionary = mockEntitlementInfo.map()

        assertThat(dictionary[storeDictionaryKey]).isEqualTo(expectedDictionaryValue)
    }

    @Test
    fun `Setting the store to STRIPE correctly adds STRIPE to the dictionary`() {
        val expectedDictionaryValue = "STRIPE"
        val mockEntitlementInfo = generateMockEntitlementInfo(store = Store.STRIPE)
        val dictionary = mockEntitlementInfo.map()

        assertThat(dictionary[storeDictionaryKey]).isEqualTo(expectedDictionaryValue)
    }

    @Test
    fun `Setting the store to PROMOTIONAL correctly adds PROMOTIONAL to the dictionary`() {
        val expectedDictionaryValue = "PROMOTIONAL"
        val mockEntitlementInfo = generateMockEntitlementInfo(store = Store.PROMOTIONAL)
        val dictionary = mockEntitlementInfo.map()

        assertThat(dictionary[storeDictionaryKey]).isEqualTo(expectedDictionaryValue)
    }

    @Test
    fun `Setting the store to UNKNOWN correctly adds UNKNOWN to the dictionary`() {
        val expectedDictionaryValue = "UNKNOWN_STORE"
        val mockEntitlementInfo = generateMockEntitlementInfo(store = Store.UNKNOWN_STORE)
        val dictionary = mockEntitlementInfo.map()

        assertThat(dictionary[storeDictionaryKey]).isEqualTo(expectedDictionaryValue)
    }

    @Test
    fun `Setting the store to AMAZON correctly adds AMAZON to the dictionary`() {
        val expectedDictionaryValue = "AMAZON"
        val mockEntitlementInfo = generateMockEntitlementInfo(store = Store.AMAZON)
        val dictionary = mockEntitlementInfo.map()

        assertThat(dictionary[storeDictionaryKey]).isEqualTo(expectedDictionaryValue)
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