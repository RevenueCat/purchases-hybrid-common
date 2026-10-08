package com.revenuecat.purchases.hybridcommon.ui

import android.os.Looper
import androidx.fragment.app.FragmentActivity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class PaywallFragmentTest {

    @Test
    fun `presenting while Purchases is not configured delivers ERROR and removes the fragment`() {
        val activity = Robolectric.buildActivity(FragmentActivity::class.java).setup().get()
        val results = mutableListOf<String>()
        val resultListener = object : PaywallResultListener {
            override fun onPaywallResult(paywallResult: String) {
                results += paywallResult
            }
        }

        presentPaywallFromFragment(activity, PresentPaywallOptions(paywallResultListener = resultListener))
        shadowOf(Looper.getMainLooper()).idle()

        assertEquals(listOf("ERROR"), results)
        assertNull(activity.supportFragmentManager.findFragmentByTag(PaywallFragment.tag))
    }
}
