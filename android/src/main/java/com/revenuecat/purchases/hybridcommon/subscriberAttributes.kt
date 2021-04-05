package com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.Purchases
import org.json.JSONObject

// region attribution v1
fun addAttributionData(
    data: Map<String, String>,
    network: Int,
    networkUserId: String?
) {
    for (attributionNetwork in Purchases.AttributionNetwork.values()) {
        if (attributionNetwork.serverValue == network) {
            @Suppress("DEPRECATION")
            Purchases.addAttributionData(data, attributionNetwork, networkUserId)
        }
    }
}

fun addAttributionData(
    data: JSONObject,
    network: Int,
    networkUserId: String?
) {
    for (attributionNetwork in Purchases.AttributionNetwork.values()) {
        if (attributionNetwork.serverValue == network) {
            @Suppress("DEPRECATION")
            Purchases.addAttributionData(data, attributionNetwork, networkUserId)
        }
    }
}

// endregion
// region Attribution IDs

fun collectDeviceIdentifiers() {
    Purchases.sharedInstance.collectDeviceIdentifiers()
}

fun setAdjustID(adjustID: String?) {
    Purchases.sharedInstance.setAdjustID(adjustID)
}

fun setAppsflyerID(appsflyerID: String?) {
    Purchases.sharedInstance.setAppsflyerID(appsflyerID)
}

fun setFBAnonymousID(fbAnonymousID: String?) {
    Purchases.sharedInstance.setFBAnonymousID(fbAnonymousID)
}

fun setMparticleID(mparticleID: String?) {
    Purchases.sharedInstance.setMparticleID(mparticleID)
}

fun setOnesignalID(onesignalID: String?) {
    Purchases.sharedInstance.setOnesignalID(onesignalID)
}

// endregion
// region Campaign parameters

fun setMediaSource(mediaSource: String?) {
    Purchases.sharedInstance.setMediaSource(mediaSource)
}

fun setCampaign(campaign: String?) {
    Purchases.sharedInstance.setCampaign(campaign)
}

fun setAdGroup(adGroup: String?) {
    Purchases.sharedInstance.setAdGroup(adGroup)
}

fun setAd(ad: String?) {
    Purchases.sharedInstance.setAd(ad)
}

fun setKeyword(keyword: String?) {
    Purchases.sharedInstance.setKeyword(keyword)
}

fun setCreative(creative: String?) {
    Purchases.sharedInstance.setCreative(creative)
}

// endregion
// region subscriber attributes

fun setAttributes(attributes: Map<String, String?>) {
    Purchases.sharedInstance.setAttributes(attributes)
}

fun setEmail(email: String?) {
    Purchases.sharedInstance.setEmail(email)
}

fun setPhoneNumber(phoneNumber: String?) {
    Purchases.sharedInstance.setPhoneNumber(phoneNumber)
}

fun setDisplayName(displayName: String?) {
    Purchases.sharedInstance.setDisplayName(displayName)
}

fun setPushToken(fcmToken: String?) {
    Purchases.sharedInstance.setPushToken(fcmToken)
}

// endregion
