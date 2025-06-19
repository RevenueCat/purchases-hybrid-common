package com.revenuecat.apitests.java.mappers;

import com.revenuecat.purchases.hybridcommon.mappers.StoreProductMapperKt;
import com.revenuecat.purchases.models.StoreProduct;

import java.util.List;
import java.util.Map;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

@SuppressWarnings("unused")
class StoreProductMapperApiTests {
    private void checkItemMap(StoreProduct product) {
        Map<String, Object> map = StoreProductMapperKt.map(product);
    }

    private void checkListMapAsync(List<StoreProduct> products, Function1<? super List<? extends Map<String, ?>>, Unit> callback) {
        StoreProductMapperKt.mapAsync(products, callback);
    }
}
