package com.revenuecat.apitests.java.mappers;

import com.revenuecat.purchases.CustomerInfo;
import com.revenuecat.purchases.hybridcommon.mappers.CustomerInfoMapperKt;

import java.util.Map;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

@SuppressWarnings("unused")
class CustomerInfoMapperApiTests {
    private void checkMapAsync(CustomerInfo customerInfo, Function1<? super Map<String, ?>, Unit> callback) {
        CustomerInfoMapperKt.mapAsync(customerInfo, callback);
    }
}
