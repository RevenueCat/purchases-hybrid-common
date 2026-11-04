package com.revenuecat.purchases.hybridcommon.mappers

import com.revenuecat.purchases.ads.AdRewardConfiguration
import com.revenuecat.purchases.ads.ConfiguredAdRewards
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import kotlin.time.Duration.Companion.seconds

class ConfiguredAdRewardsMapperTests {

    @Test
    fun `no configured reward maps to explicit null and empty list`() {
        val configured = mockk<ConfiguredAdRewards>()
        every { configured.reward } returns null
        every { configured.moreRewards } returns emptyList()

        assertThat(configured.map()).isEqualTo(
            mapOf("reward" to null, "moreRewards" to emptyList<Map<String, Any>>()),
        )
    }

    @Test
    fun `maps primary and additional rewards in order`() {
        val currency = mockk<AdRewardConfiguration.VirtualCurrency>()
        every { currency.code } returns "GLD"
        every { currency.amount } returns 100
        val entitlement = mockk<AdRewardConfiguration.Entitlement>()
        every { entitlement.identifier } returns "premium"
        every { entitlement.duration } returns 1800.seconds
        val configured = mockk<ConfiguredAdRewards>()
        every { configured.reward } returns currency
        every { configured.moreRewards } returns listOf(entitlement, AdRewardConfiguration.UnsupportedReward, currency)

        assertThat(configured.map()).isEqualTo(
            mapOf(
                "reward" to mapOf("type" to "virtual_currency", "code" to "GLD", "amount" to 100),
                "moreRewards" to listOf(
                    mapOf("type" to "entitlement", "identifier" to "premium", "durationSeconds" to 1800.0),
                    mapOf("type" to "unsupported_reward"),
                    mapOf("type" to "virtual_currency", "code" to "GLD", "amount" to 100),
                ),
            ),
        )
    }

    @Test
    fun `unsupported primary remains a configured reward`() {
        val configured = mockk<ConfiguredAdRewards>()
        every { configured.reward } returns AdRewardConfiguration.UnsupportedReward
        every { configured.moreRewards } returns emptyList()

        assertThat(configured.map()["reward"]).isEqualTo(mapOf("type" to "unsupported_reward"))
    }

    @Test
    fun `unknown reward implementations preserve their positions`() {
        val unknown = mockk<AdRewardConfiguration>()
        val configured = mockk<ConfiguredAdRewards>()
        every { configured.reward } returns unknown
        every { configured.moreRewards } returns listOf(AdRewardConfiguration.UnsupportedReward, unknown)

        assertThat(configured.map()).isEqualTo(
            mapOf(
                "reward" to mapOf("type" to "unsupported_reward"),
                "moreRewards" to listOf(
                    mapOf("type" to "unsupported_reward"),
                    mapOf("type" to "unsupported_reward"),
                ),
            ),
        )
    }
}
