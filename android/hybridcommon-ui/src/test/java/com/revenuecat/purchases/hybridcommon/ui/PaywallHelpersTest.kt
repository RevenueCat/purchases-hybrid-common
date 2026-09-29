package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.slot
import io.mockk.unmockkStatic
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test

class PaywallHelpersTest {

    @Before
    fun setUp() {
        mockkStatic(Log::class)
        every { Log.w(any<String>(), any<String>()) } returns 0
    }

    @After
    fun tearDown() {
        unmockkStatic(Log::class)
    }

    @Test
    fun `presenting while the activity is not started does not keep the listener`() {
        val activity = mockk<FragmentActivity>(relaxed = true)
        every { activity.lifecycle.currentState } returns Lifecycle.State.CREATED
        val uiThreadWork = slot<Runnable>()
        every { activity.runOnUiThread(capture(uiThreadWork)) } answers { uiThreadWork.captured.run() }
        val results = mutableListOf<String>()
        val resultListener = object : PaywallResultListener {
            override fun onPaywallResult(paywallResult: String) {
                results += paywallResult
            }
        }

        presentPaywallFromFragment(
            activity,
            PresentPaywallOptions(
                paywallResultListener = resultListener,
                paywallListener = mockk(relaxed = true),
            ),
        )

        assertEquals(listOf("ERROR"), results)
        assertNull(PaywallFragmentNonSerializableArgsStore.get(System.identityHashCode(resultListener).toString()))
    }
}
