package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.hybridcommon.PurchasableItem
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

internal class PurchasableItemMapperTests {

    @Test
    fun `fromMap returns product when identifier and type are present`() {
        val input = mapOf(
            "productIdentifier" to "product_id",
            "type" to "SUBS",
            "googleBasePlanId" to "base_plan",
        )

        val result = PurchasableItem.Product.fromMap(input)

        assertThat(result).isEqualTo(
            PurchasableItem.Product(
                productIdentifier = "product_id",
                type = "SUBS",
                googleBasePlanId = "base_plan",
            ),
        )
    }

    @Test
    fun `fromMap returns product when base plan id is omitted`() {
        val input = mapOf(
            "productIdentifier" to "product_id",
            "type" to "INAPP",
        )

        val result = PurchasableItem.Product.fromMap(input)

        assertThat(result).isEqualTo(
            PurchasableItem.Product(
                productIdentifier = "product_id",
                type = "INAPP",
                googleBasePlanId = null,
            ),
        )
    }

    @Test
    fun `fromMap returns null when product identifier is missing`() {
        val input = mapOf(
            "type" to "SUBS",
            "googleBasePlanId" to "base_plan",
        )

        val result = PurchasableItem.Product.fromMap(input)

        assertThat(result).isNull()
    }

    @Test
    fun `fromMap returns null when identifier and type are both null`() {
        val input = mapOf(
            "productIdentifier" to null,
            "type" to null,
        )

        val result = PurchasableItem.Product.fromMap(input)

        assertThat(result).isNull()
    }

    @Test
    fun `fromMap returns null when product identifier is blank`() {
        val input = mapOf(
            "productIdentifier" to " ",
            "type" to "SUBS",
        )

        val result = PurchasableItem.Product.fromMap(input)

        assertThat(result).isNull()
    }

    @Test
    fun `fromMap returns null when identifier and type are both blank`() {
        val input = mapOf(
            "productIdentifier" to " ",
            "type" to "",
        )

        val result = PurchasableItem.Product.fromMap(input)

        assertThat(result).isNull()
    }

    @Test
    fun `fromMap returns null when type is missing`() {
        val input = mapOf(
            "productIdentifier" to "product_id",
        )

        val result = PurchasableItem.Product.fromMap(input)

        assertThat(result).isNull()
    }

    @Test
    fun `fromMap returns null when type is blank`() {
        val input = mapOf(
            "productIdentifier" to "product_id",
            "type" to " ",
        )

        val result = PurchasableItem.Product.fromMap(input)

        assertThat(result).isNull()
    }
}
