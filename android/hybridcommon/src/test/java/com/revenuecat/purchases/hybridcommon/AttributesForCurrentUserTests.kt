@file:OptIn(InternalRevenueCatAPI::class)

package com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.CustomerAttribute
import com.revenuecat.purchases.InternalRevenueCatAPI
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.hybridcommon.mappers.toIso8601
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import java.util.Date

internal class AttributesForCurrentUserTests {

    private val mockPurchases = mockk<Purchases>()

    @BeforeEach
    fun setup() {
        mockkObject(Purchases)
        every { Purchases.sharedInstance } returns mockPurchases
    }

    @Test
    fun `maps each attribute`() {
        val date = Date(1_700_000_000_123)
        every { mockPurchases.attributesForCurrentUser } returns listOf(attribute("\$email", "a@b.com", date))

        val attributes = getAttributesForCurrentUser()

        assertThat(attributes).containsExactly(
            mapOf(
                "key" to "\$email",
                "value" to "a@b.com",
                "lastUpdatedDate" to date.toIso8601(),
            ),
        )
    }

    @Test
    fun `sorts attributes by key`() {
        every { mockPurchases.attributesForCurrentUser } returns listOf(
            attribute("zeta", "1"),
            attribute("alpha", "2"),
            attribute("mid", "3"),
        )

        assertThat(getAttributesForCurrentUser().map { it["key"] }).containsExactly("alpha", "mid", "zeta")
    }

    @Test
    fun `returns an empty list without attributes`() {
        every { mockPurchases.attributesForCurrentUser } returns emptyList()

        assertThat(getAttributesForCurrentUser()).isEmpty()
    }

    private fun attribute(key: String, value: String, date: Date = Date(0)): CustomerAttribute {
        val attribute = mockk<CustomerAttribute>()
        every { attribute.key } returns key
        every { attribute.value } returns value
        every { attribute.lastUpdatedDate } returns date
        return attribute
    }
}
