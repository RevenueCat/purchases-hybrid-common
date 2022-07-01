package apitests.java;

import com.revenuecat.purchases.hybridcommon.SubscriberAttributesKt;

import java.util.Map;

@SuppressWarnings("unused")
class SubscriberAttributesApiTests {
    // region Attribution IDs

    private void checkCollectDeviceIdentifiers() {
        SubscriberAttributesKt.collectDeviceIdentifiers();
    }

    private void checkSetAdjustID(String id) {
        SubscriberAttributesKt.setAdjustID(id);
    }

    private void checkSetAppsflyerId(String id) {
        SubscriberAttributesKt.setAppsflyerID(id);
    }

    private void checkSetFBAnonymousID(String id) {
        SubscriberAttributesKt.setFBAnonymousID(id);
    }

    private void checkSetMparticleID(String id) {
        SubscriberAttributesKt.setMparticleID(id);
    }

    private void checkSetOnesignalID(String id) {
        SubscriberAttributesKt.setOnesignalID(id);
    }

    private void checkSetAirshipChannelID(String id) {
        SubscriberAttributesKt.setAirshipChannelID(id);
    }

    // endregion
    // region Campaign parameters

    private void checkSetMediaSource(String mediaSource) {
        SubscriberAttributesKt.setMediaSource(mediaSource);
    }

    private void checkSetCampaign(String campaign) {
        SubscriberAttributesKt.setCampaign(campaign);
    }

    private void checkSetAdGroup(String adGroup) {
        SubscriberAttributesKt.setAdGroup(adGroup);
    }

    private void checkSetAd(String ad) {
        SubscriberAttributesKt.setAd(ad);
    }

    private void checkSetKeyword(String keyword) {
        SubscriberAttributesKt.setKeyword(keyword);
    }

    private void checkSetCreative(String creative) {
        SubscriberAttributesKt.setCreative(creative);
    }

    // endregion
    // region subscriber attributes

    private void checkSetAttributes(Map<String, String> attributes) {
        SubscriberAttributesKt.setAttributes(attributes);
    }

    private void checkSetEmail(String email) {
        SubscriberAttributesKt.setEmail(email);
    }

    private void checkSetPhoneNumber(String phoneNumber) {
        SubscriberAttributesKt.setPhoneNumber(phoneNumber);
    }

    private void checkSetDisplayName(String displayName) {
        SubscriberAttributesKt.setDisplayName(displayName);
    }

    private void checkSetPushToken(String pushToken) {
        SubscriberAttributesKt.setPushToken(pushToken);
    }

    // endregion
}
