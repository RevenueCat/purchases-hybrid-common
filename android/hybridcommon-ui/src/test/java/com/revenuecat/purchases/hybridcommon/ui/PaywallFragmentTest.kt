package com.revenuecat.purchases.hybridcommon.ui

import android.os.Bundle
import android.os.Looper
import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.PurchasesErrorCode
import com.revenuecat.purchases.interfaces.ReceiveCustomerInfoCallback
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.slot
import io.mockk.unmockkAll
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class PaywallFragmentTest {

    private val results = mutableListOf<String>()
    private val resultListener = object : PaywallResultListener {
        override fun onPaywallResult(paywallResult: String) {
            results += paywallResult
        }
    }

    @After
    fun tearDown() {
        unmockkAll()
    }

    @Test
    fun `presenting while Purchases is not configured delivers ERROR and removes the fragment`() {
        val activity = Robolectric.buildActivity(FragmentActivity::class.java).setup().get()

        presentPaywallFromFragment(activity, PresentPaywallOptions(paywallResultListener = resultListener))
        shadowOf(Looper.getMainLooper()).idle()

        assertEquals(listOf("ERROR"), results)
        assertNull(activity.supportFragmentManager.findFragmentByTag(PaywallFragment.tag))
    }

    @Test
    fun `CustomerInfo error after the activity saved its state delivers NOT_PRESENTED and removes the fragment`() {
        val customerInfoCallback = slot<ReceiveCustomerInfoCallback>()
        val purchases = mockk<Purchases>(relaxed = true)
        every { purchases.getCustomerInfo(capture(customerInfoCallback)) } returns Unit
        mockkObject(Purchases)
        every { Purchases.isConfigured } returns true
        every { Purchases.sharedInstance } returns purchases
        val controller = Robolectric.buildActivity(FragmentActivity::class.java).setup()
        val activity = controller.get()

        presentPaywallFromFragment(
            activity,
            PresentPaywallOptions(paywallResultListener = resultListener, requiredEntitlementIdentifier = "pro"),
        )
        shadowOf(Looper.getMainLooper()).idle()

        controller.pause().stop().saveInstanceState(Bundle())
        customerInfoCallback.captured.onError(PurchasesError(PurchasesErrorCode.NetworkError))
        controller.start().resume()
        shadowOf(Looper.getMainLooper()).idle()

        assertEquals(listOf("NOT_PRESENTED"), results)
        assertNull(activity.supportFragmentManager.findFragmentByTag(PaywallFragment.tag))
    }
}
