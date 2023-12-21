package com.revenuecat.api_tests.java.mappers;

import com.revenuecat.purchases.CustomerInfo;
import com.revenuecat.purchases.hybridcommon.mappers.CustomerInfoMapperKt;

import java.util.Map;

@SuppressWarnings("unused")
class CustomerInfoMapperApiTests {
    private void checkMap(CustomerInfo customerInfo) {
        Map<String, Object> map = CustomerInfoMapperKt.map(customerInfo);
    }
}
