package com.revenuecat.apitests.java.mappers;

import com.revenuecat.purchases.hybridcommon.mappers.StoreProductMapperKt;
import com.revenuecat.purchases.models.StoreProduct;

import java.util.List;
import java.util.Map;

@SuppressWarnings("unused")
class StoreProductMapperApiTests {
    private void checkItemMap(StoreProduct product) {
        Map<String, Object> map = StoreProductMapperKt.map(product);
    }

    private void checkListMap(List<StoreProduct> products) {
        List<Map<String, Object>> listOfMaps = StoreProductMapperKt.map(products);
    }
}
