package com.revenuecat.api_tests.java.mappers;

import com.revenuecat.purchases.Offerings;
import com.revenuecat.purchases.hybridcommon.mappers.OfferingsMapperKt;

import java.util.Map;

@SuppressWarnings("unused")
class OfferingsMapperApiTests {
    private void checkMap(Offerings offerings) {
        Map<String, Object> map = OfferingsMapperKt.map(offerings);
    }
}
