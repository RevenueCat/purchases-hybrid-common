package com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.ads.AdRewardConfiguration
import com.revenuecat.purchases.ads.ConfiguredAdRewards
import com.revenuecat.purchases.interfaces.GetAdRewardsCallback
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.slot
import io.mockk.unmockkObject
import io.mockk.verify
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

class ConfiguredAdRewardsTests {
    private val purchases = mockk<Purchases>()
    private val onResult = mockk<OnNullableResult>(relaxed = true)
    private val callback = slot<GetAdRewardsCallback>()

    @BeforeEach
    fun setup() {
        mockkObject(Purchases.Companion)
        every { Purchases.sharedInstance } returns purchases
        every { purchases.getAdRewards(any(), capture(callback)) } answers { }
    }

    @AfterEach
    fun teardown() {
        unmockkObject(Purchases.Companion)
    }

    @Test
    fun `forwards exact case sensitive ID and unavailable result`() {
        getAdRewards(" Ad-Unit-ID ", onResult)
        callback.captured.onReceived(null)

        verify(exactly = 1) { purchases.getAdRewards(" Ad-Unit-ID ", any()) }
        verify(exactly = 1) { onResult.onReceived(null) }
        verify(exactly = 0) { onResult.onError(any()) }
    }

    @Test
    fun `maps resolved native rewards to callback`() {
        val rewards = mockk<ConfiguredAdRewards>()
        every { rewards.reward } returns AdRewardConfiguration.UnsupportedReward
        every { rewards.moreRewards } returns emptyList()

        getAdRewards("unit", onResult)
        callback.captured.onReceived(rewards)

        verify(exactly = 1) {
            onResult.onReceived(
                mapOf(
                    "reward" to mapOf("type" to "unsupported_reward"),
                    "moreRewards" to emptyList<Map<String, Any>>(),
                ),
            )
        }
    }

    @Test
    fun `no configured reward is distinct from unavailable without retaining previous result`() {
        val noRewards = mockk<ConfiguredAdRewards>()
        every { noRewards.reward } returns null
        every { noRewards.moreRewards } returns emptyList()

        getAdRewards("unit", onResult)
        callback.captured.onReceived(noRewards)
        getAdRewards("unit", onResult)
        callback.captured.onReceived(null)

        verify(exactly = 2) { purchases.getAdRewards("unit", any()) }
        verify(exactly = 1) {
            onResult.onReceived(mapOf("reward" to null, "moreRewards" to emptyList<Map<String, Any>>()))
        }
        verify(exactly = 1) { onResult.onReceived(null) }
        verify(exactly = 0) { onResult.onError(any()) }
    }
}
