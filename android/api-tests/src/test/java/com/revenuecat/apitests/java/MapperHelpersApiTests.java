package com.revenuecat.apitests.java.mappers;

import com.revenuecat.purchases.hybridcommon.mappers.MappersHelpersKt;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;
import java.util.Map;

@SuppressWarnings("unused")
class MapperHelpersApiTests {
    private void checkConvertToJson(Map<String, Object> map) {
        JSONObject json = MappersHelpersKt.convertToJson(map);
    }

    private void checkConvertToJsonArray(List<Object> list) {
        JSONArray jsonArray = MappersHelpersKt.convertToJsonArray(list);
    }

    private void checkConvertToMap(JSONObject json) {
        Map<String, String> map = MappersHelpersKt.convertToMap(json);
    }
}
