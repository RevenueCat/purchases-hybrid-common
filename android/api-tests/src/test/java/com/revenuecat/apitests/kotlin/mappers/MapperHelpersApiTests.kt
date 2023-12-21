package com.revenuecat.apitests.kotlin.mappers

import com.revenuecat.purchases.hybridcommon.mappers.convertToJson
import com.revenuecat.purchases.hybridcommon.mappers.convertToJsonArray
import com.revenuecat.purchases.hybridcommon.mappers.convertToMap
import org.json.JSONArray
import org.json.JSONObject

@Suppress("unused", "UNUSED_VARIABLE")
private class MapperHelpersApiTests {
    fun checkConvertToJson(map: Map<String, *>) {
        val json: JSONObject = map.convertToJson()
    }

    fun checkConvertToJsonArray(list: List<*>) {
        val jsonArray: JSONArray = list.convertToJsonArray()
    }

    fun checkConvertToMap(json: JSONObject) {
        val map: Map<String, String?> = json.convertToMap()
    }
}
