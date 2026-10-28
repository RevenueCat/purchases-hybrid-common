package com.revenuecat.purchases.hybridcommon.ui

import android.util.Log
import com.revenuecat.purchases.ui.revenuecatui.CustomVariableValue

/**
 * Maps the untyped custom variables hybrid SDKs pass to [CustomVariableValue]. Unsupported values are dropped.
 */
internal fun Map<String, Any?>?.toCustomVariableValues(): Map<String, CustomVariableValue>? {
    return this
        ?.mapNotNull { (key, value) ->
            when (value) {
                is String -> key to CustomVariableValue.String(value)
                is Boolean -> key to CustomVariableValue.Boolean(value)
                is Number -> key to CustomVariableValue.Number(value.toDouble())
                null -> null
                else -> {
                    Log.w(
                        "Purchases",
                        "Custom variable '$key' has unsupported type ${value::class.simpleName}. " +
                            "Only String, Number, and Boolean values are supported. This variable will be ignored.",
                    )
                    null
                }
            }
        }
        ?.toMap()
        ?.takeIf { it.isNotEmpty() }
}
