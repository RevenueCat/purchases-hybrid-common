package com.revenuecat.apitests.java.mappers;

import com.revenuecat.purchases.EntitlementInfos;
import com.revenuecat.purchases.hybridcommon.mappers.EntitlementInfosMapperKt;

import java.util.Map;

@SuppressWarnings("unused")
class EntitlementInfosMapperApiTests {
    private void checkMap(EntitlementInfos entitlementInfos) {
        Map<String, Object> map = EntitlementInfosMapperKt.map(entitlementInfos);
    }
}
