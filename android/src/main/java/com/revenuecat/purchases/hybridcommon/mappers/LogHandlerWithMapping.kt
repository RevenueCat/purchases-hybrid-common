package com.revenuecat.purchases.hybridcommon.mappers

class LogHandlerWithMapping(
    private val callback: (logData: Map<String, String>) -> Unit
) : com.revenuecat.purchases.LogHandler {
    override fun d(tag: String, msg: String) {
        invokeCallback("debug", msg)
    }

    override fun e(tag: String, msg: String, throwable: Throwable?) {
        val message = throwable?.let { "$msg. Throwable: $it" } ?: msg
        invokeCallback("error", message)
    }

    override fun i(tag: String, msg: String) {
        invokeCallback("info", msg)
    }

    override fun v(tag: String, msg: String) {
        invokeCallback("verbose", msg)
    }

    override fun w(tag: String, msg: String) {
        invokeCallback("warn", msg)
    }

    private fun invokeCallback(c: String, msg: String) {
        callback(mapOf("logLevel" to "debug", "message" to msg))
    }
}