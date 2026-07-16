package com.revenuecat.purchases.hybridcommon

@RequiresOptIn(
    level = RequiresOptIn.Level.ERROR,
    message = "This API bridges an experimental or internal RevenueCat API " +
        "and may change or break without a major version bump.",
)
@Retention(AnnotationRetention.BINARY)
@Target(
    AnnotationTarget.CLASS,
    AnnotationTarget.FUNCTION,
    AnnotationTarget.PROPERTY,
    AnnotationTarget.CONSTRUCTOR,
    AnnotationTarget.TYPEALIAS,
)
annotation class ExperimentalPreviewHybridCommonAPI
