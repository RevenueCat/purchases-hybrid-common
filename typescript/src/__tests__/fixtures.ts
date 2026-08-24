/**
 * Stand-in for `@capacitor/core`'s CapacitorException, which assigns `message`,
 * `code` and `data` onto an Error subclass.
 */
export class CapacitorException extends Error {
    public code?: string;
    public data?: unknown;

    constructor(message: string, code?: string, data?: unknown) {
        super(message);
        this.message = message;
        this.code = code;
        this.data = data;

        // This package targets es5, which downlevels `extends Error` and drops
        // the prototype link. @capacitor/core ships es2015+, where it survives.
        Object.setPrototypeOf(this, CapacitorException.prototype);
    }
}

// React Native merges the native error payload onto a fresh Error
// (NativeModules.js, `Object.assign(error, errorData)`).
export function reactNativeAndroidError(): Error {
    return Object.assign(new Error("Store problem"), {
        code: "2",
        name: "com.revenuecat.purchases.PurchasesException",
        userInfo: {
            code: 2,
            message: "Store problem",
            readableErrorCode: "StoreProblemError",
            readable_error_code: "StoreProblemError",
            underlyingErrorMessage: "Billing unavailable",
        },
        nativeStackAndroid: [],
    });
}

// On iOS, React Native forwards NSError.userInfo, into which RNPurchases.m merges
// the error container's info payload. readable_error_code is ErrorCode.codeName.
export function reactNativeIosError(): Error {
    return Object.assign(new Error("Store problem"), {
        code: "2",
        domain: "RevenueCat.ErrorCode",
        userInfo: {
            NSLocalizedDescription: "Store problem",
            code: 2,
            message: "Store problem",
            readable_error_code: "STORE_PROBLEM",
            readableErrorCode: "STORE_PROBLEM",
            underlyingErrorMessage: "",
        },
        nativeStackIOS: [],
    });
}

export function capacitorError(): CapacitorException {
    return new CapacitorException("There was a credentials issue.", "11", {
        code: 11,
        message: "There was a credentials issue.",
        readableErrorCode: "InvalidCredentialsError",
        readable_error_code: "InvalidCredentialsError",
        underlyingErrorMessage: "Invalid API Key.",
    });
}

// cordova and unity deliver info flat, and some callers already build errors in
// the shape PurchasesError declares.
export function flatError(): Record<string, unknown> {
    return {
        code: "1",
        message: "User cancelled",
        readableErrorCode: "USER_CANCELLED",
        underlyingErrorMessage: "The user cancelled",
    };
}

// purchases-js-hybrid-mappings throws the result of mapPurchasesError, whose
// code comes from a numeric enum.
export function webError(): Record<string, unknown> {
    return {
        code: 2,
        message: "Store problem",
        underlyingErrorMessage: undefined,
    };
}
