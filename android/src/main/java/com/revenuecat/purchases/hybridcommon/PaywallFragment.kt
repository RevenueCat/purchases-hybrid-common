package com.revenuecat.purchases.hybridcommon

import android.os.Bundle
import androidx.fragment.app.Fragment
import com.revenuecat.purchases.ui.revenuecatui.ExperimentalPreviewRevenueCatUIPurchasesAPI
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallActivityLauncher
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResult
import com.revenuecat.purchases.ui.revenuecatui.activity.PaywallResultHandler

@OptIn(ExperimentalPreviewRevenueCatUIPurchasesAPI::class)
internal class PaywallFragment(
    private val requiredEntitlementIdentifier: String?
): Fragment(), PaywallResultHandler {

    private lateinit var launcher: PaywallActivityLauncher

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        launcher = PaywallActivityLauncher(
            this,
            this
        )

        requiredEntitlementIdentifier?.let {
            launcher.launchIfNeeded(requiredEntitlementIdentifier = it)
        } ?: launcher.launch()
    }

    companion object {
        const val tag: String = "revenuecat-paywall-fragment"
    }

    override fun onActivityResult(result: PaywallResult) = Unit

}
