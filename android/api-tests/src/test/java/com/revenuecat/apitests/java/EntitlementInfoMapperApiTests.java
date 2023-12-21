package com.revenuecat.apitests.java.mappers;

import com.revenuecat.purchases.EntitlementInfo;
import com.revenuecat.purchases.hybridcommon.mappers.EntitlementInfoMapperKt;

import java.util.Map;

@SuppressWarnings("unused")
class EntitlementInfoMapperApiTests {
    private void checkMap(EntitlementInfo entitlementInfo) {
        Map<String, Object> map = EntitlementInfoMapperKt.map(entitlementInfo);
    }
}
