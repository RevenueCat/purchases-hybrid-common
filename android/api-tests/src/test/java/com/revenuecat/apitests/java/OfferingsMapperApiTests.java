package com.revenuecat.apitests.java.mappers;

import com.revenuecat.purchases.Offerings;
import com.revenuecat.purchases.hybridcommon.mappers.OfferingsMapperKt;

import java.util.Map;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

@SuppressWarnings("unused")
class OfferingsMapperApiTests {
    private void checkMapAsync(Offerings offerings, Function1<? super Map<String, ?>, Unit> callback) {
        OfferingsMapperKt.mapAsync(offerings, callback);
    }
}
