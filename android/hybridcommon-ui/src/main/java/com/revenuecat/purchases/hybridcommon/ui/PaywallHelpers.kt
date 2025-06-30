package com.revenuecat.purchases.hybridcommon.ui

import androidx.fragment.app.FragmentActivity
import com.revenuecat.purchases.Offering
import com.revenuecat.purchases.ui.revenuecatui.fonts.PaywallFontFamily

@JvmOverloads
@Deprecated(
    message = "Use presentPaywallFromFragment with Options instead",
    replaceWith = ReplaceWith(
        expression = "presentPaywallFromFragment(fragment, options)",
        imports = ["com.revenuecat.purchases.hybridcommon.ui.presentPaywallFromFragment"],
    ),
)
fun presentPaywallFromFragment(
    activity: FragmentActivity,
    paywallResultListener: PaywallResultListener,
    requiredEntitlementIdentifier: String? = null,
    shouldDisplayDismissButton: Boolean? = null,
    offering: Offering? = null,
) {
    presentPaywallFromFragment(
        activity,
        PresentPaywallOptions(
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            paywallResultListener = paywallResultListener,
            shouldDisplayDismissButton = shouldDisplayDismissButton,
            paywallSource = offering?.let { PaywallSource.Offering(it) } ?: PaywallSource.DefaultOffering,
        ),
    )
}

fun presentPaywallFromFragment(
    activity: FragmentActivity,
    options: PresentPaywallOptions,
) {
    with(options) {
        val requestKey = System.identityHashCode(paywallResultListener).toString()

        activity.runOnUiThread {
            activity.supportFragmentManager.setFragmentResultListener(requestKey, activity) { _, result ->
                val paywallResult = result.getString(PaywallFragment.ResultKey.PAYWALL_RESULT.key)
                    ?: error("PaywallResult not found in result bundle.")
                paywallResultListener.onPaywallResult(paywallResult)
                activity.supportFragmentManager.clearFragmentResultListener(requestKey)
            }

            activity
                .supportFragmentManager
                .beginTransaction()
                .add(
                    PaywallFragment.newInstance(
                        requestKey,
                        requiredEntitlementIdentifier,
                        shouldDisplayDismissButton,
                        paywallSource,
                        fontFamily,
                    ),
                    PaywallFragment.tag,
                )
                .commit()
        }
    }
}

data class PresentPaywallOptions @JvmOverloads constructor(
    val paywallResultListener: PaywallResultListener,
    val paywallSource: PaywallSource = PaywallSource.DefaultOffering,
    val requiredEntitlementIdentifier: String? = null,
    val shouldDisplayDismissButton: Boolean? = null,
    val fontFamily: PaywallFontFamily? = null,
)
