package apitests.kotlin.com.revenuecat.purchases.hybridcommon

import com.revenuecat.purchases.hybridcommon.*

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
