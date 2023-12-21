package com.revenuecat.api_tests.kotlin

import com.revenuecat.purchases.hybridcommon.collectDeviceIdentifiers
import com.revenuecat.purchases.hybridcommon.setAd
import com.revenuecat.purchases.hybridcommon.setAdGroup
import com.revenuecat.purchases.hybridcommon.setAdjustID
import com.revenuecat.purchases.hybridcommon.setAirshipChannelID
import com.revenuecat.purchases.hybridcommon.setAppsflyerID
import com.revenuecat.purchases.hybridcommon.setAttributes
import com.revenuecat.purchases.hybridcommon.setCampaign
import com.revenuecat.purchases.hybridcommon.setCreative
import com.revenuecat.purchases.hybridcommon.setDisplayName
import com.revenuecat.purchases.hybridcommon.setEmail
import com.revenuecat.purchases.hybridcommon.setFBAnonymousID
import com.revenuecat.purchases.hybridcommon.setKeyword
import com.revenuecat.purchases.hybridcommon.setMediaSource
import com.revenuecat.purchases.hybridcommon.setMparticleID
import com.revenuecat.purchases.hybridcommon.setOnesignalID
import com.revenuecat.purchases.hybridcommon.setPhoneNumber
import com.revenuecat.purchases.hybridcommon.setPushToken

@Suppress("unused")
private class SubscriberAttributesApiTests {

    // region Attribution IDs

    fun checkCollectDeviceIdentifiers() {
        collectDeviceIdentifiers()
    }

    fun checkSetAdjustID(id: String?) {
        setAdjustID(id)
    }

    fun checkSetAppsflyerID(id: String?) {
        setAppsflyerID(id)
    }

    fun checkSetFBAnonymousID(id: String?) {
        setFBAnonymousID(id)
    }

    fun checkSetMparticleID(id: String?) {
        setMparticleID(id)
    }

    fun checkSetOnesignalID(id: String?) {
        setOnesignalID(id)
    }

    fun checkSetAirshipChannelID(id: String?) {
        setAirshipChannelID(id)
    }

    // endregion
    // region Campaign parameters

    fun checkSetMediaSource(mediaSource: String?) {
        setMediaSource(mediaSource)
    }

    fun checkSetCampaign(campaign: String?) {
        setCampaign(campaign)
    }

    fun checkSetAdGroup(adGroup: String?) {
        setAdGroup(adGroup)
    }

    fun checkSetAd(ad: String?) {
        setAd(ad)
    }

    fun checkSetKeyword(keyword: String?) {
        setKeyword(keyword)
    }

    fun checkSetCreative(creative: String?) {
        setCreative(creative)
    }

    // endregion
    // region subscriber attributes

    fun checkSetAttributes(attributes: Map<String, String?>) {
        setAttributes(attributes)
    }

    fun checkSetEmail(email: String?) {
        setEmail(email)
    }

    fun checkSetPhoneNumber(phoneNumber: String?) {
        setPhoneNumber(phoneNumber)
    }

    fun checkSetDisplayName(displayName: String?) {
        setDisplayName(displayName)
    }

    fun checkSetPushToken(fcmToken: String?) {
        setPushToken(fcmToken)
    }

    // endregion
}
