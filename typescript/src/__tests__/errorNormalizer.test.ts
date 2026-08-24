import { PurchasesError, UninitializedPurchasesError } from "../errors";
import { normalizePurchasesError } from "../errorNormalizer";

/**
 * Stand-in for `@capacitor/core`'s CapacitorException, which assigns `message`,
 * `code` and `data` onto an Error subclass.
 */
class CapacitorException extends Error {
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

function assignOnto<T extends object>(target: T, source: Record<string, unknown>): T {
    Object.keys(source).forEach((key) => {
        (target as Record<string, unknown>)[key] = source[key];
    });
    return target;
}

// React Native merges the native error payload onto a fresh Error
// (NativeModules.js, `Object.assign(error, errorData)`).
function reactNativeAndroidError(): Error {
    return assignOnto(new Error("Store problem"), {
        code: "2",
        message: "Store problem",
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

// On iOS, React Native forwards NSError.userInfo, which carries readableErrorCode
// but not underlyingErrorMessage.
function reactNativeIosError(): Error {
    return assignOnto(new Error("Store problem"), {
        code: "2",
        message: "Store problem",
        domain: "RevenueCat.ErrorCode",
        userInfo: {
            NSLocalizedDescription: "Store problem",
            readable_error_code: "STORE_PROBLEM_ERROR",
            readableErrorCode: "STORE_PROBLEM_ERROR",
        },
        nativeStackIOS: [],
    });
}

function capacitorError(): CapacitorException {
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
function flatError(): Record<string, unknown> {
    return {
        code: "1",
        message: "User cancelled",
        readableErrorCode: "USER_CANCELLED",
        underlyingErrorMessage: "The user cancelled",
    };
}

// purchases-js-hybrid-mappings throws the result of mapPurchasesError, whose
// code comes from a numeric enum.
function webError(): Record<string, unknown> {
    return {
        code: 2,
        message: "Store problem",
        underlyingErrorMessage: undefined,
        info: { statusCode: 500, backendErrorCode: 7110 },
    };
}

/**
 * Asserting rather than returning gives the tests below a compile-time proof
 * that the normalized error is assignable to PurchasesError.
 */
function assertPurchasesError(value: unknown): asserts value is PurchasesError {
    const candidate = value as Record<string, unknown>;
    expect(typeof candidate).toBe("object");
    expect(typeof candidate.code).toBe("string");
    expect(typeof candidate.message).toBe("string");
    expect(typeof candidate.readableErrorCode).toBe("string");
    expect(typeof candidate.underlyingErrorMessage).toBe("string");
    expect(typeof candidate.userInfo).toBe("object");
    expect(typeof (candidate.userInfo as Record<string, unknown>).readableErrorCode).toBe("string");
    expect(["boolean", "object"]).toContain(typeof candidate.userCancelled);
}

describe("normalizePurchasesError", () => {
    const fixtures: Array<[string, () => unknown]> = [
        ["react native android", reactNativeAndroidError],
        ["react native ios", reactNativeIosError],
        ["capacitor", capacitorError],
        ["web", webError],
        ["already flat", flatError],
    ];

    it.each(fixtures)("satisfies PurchasesError for %s", (_name, makeFixture) => {
        const result = normalizePurchasesError(makeFixture());

        assertPurchasesError(result);
        expect(result.userInfo.readableErrorCode).toEqual(expect.any(String));
    });

    describe("error identity", () => {
        it("returns the same object rather than a copy", () => {
            const input = capacitorError();
            expect(normalizePurchasesError(input)).toBe(input);
        });

        it.each([
            ["react native android", reactNativeAndroidError],
            ["react native ios", reactNativeIosError],
            ["capacitor", capacitorError],
        ])("preserves the prototype and stack of %s", (_name, makeFixture) => {
            const result = normalizePurchasesError(makeFixture());

            expect(result).toBeInstanceOf(Error);
            expect(typeof (result as Error).stack).toBe("string");
        });

        it("preserves a Capacitor exception's own class", () => {
            const input = capacitorError();
            expect(input).toBeInstanceOf(CapacitorException);

            expect(normalizePurchasesError(input)).toBeInstanceOf(CapacitorException);
        });
    });

    describe("existing fields", () => {
        it("keeps the richer userInfo react native already provides", () => {
            const result = normalizePurchasesError(reactNativeAndroidError());

            assertPurchasesError(result);
            expect((result.userInfo as unknown as Record<string, unknown>).underlyingErrorMessage)
                .toBe("Billing unavailable");
            expect(result.userInfo.readableErrorCode).toBe("StoreProblemError");
        });

        it("does not overwrite an existing top level message", () => {
            const input = assignOnto(new Error("outer"), {
                code: "2",
                message: "outer",
                userInfo: { readableErrorCode: "StoreProblemError", message: "inner" },
            });

            const result = normalizePurchasesError(input);

            assertPurchasesError(result);
            expect(result.message).toBe("outer");
        });

        it("keeps the capacitor data payload in place", () => {
            const result = normalizePurchasesError(capacitorError()) as unknown as Record<string, unknown>;

            expect(result.data).toEqual(
                expect.objectContaining({ underlyingErrorMessage: "Invalid API Key." })
            );
        });
    });

    describe("filled in fields", () => {
        it("lifts the nested payload onto the error", () => {
            const result = normalizePurchasesError(capacitorError());

            assertPurchasesError(result);
            expect(result.readableErrorCode).toBe("InvalidCredentialsError");
            expect(result.underlyingErrorMessage).toBe("Invalid API Key.");
            expect(result.userInfo.readableErrorCode).toBe("InvalidCredentialsError");
            expect(result.userCancelled).toBeNull();
        });

        it("defaults underlyingErrorMessage when the bridge omits it", () => {
            const result = normalizePurchasesError(reactNativeIosError());

            assertPurchasesError(result);
            expect(result.underlyingErrorMessage).toBe("");
        });

        it("derives userInfo from a top level readableErrorCode", () => {
            const result = normalizePurchasesError(flatError());

            assertPurchasesError(result);
            expect(result.userInfo.readableErrorCode).toBe("USER_CANCELLED");
            expect(result.readableErrorCode).toBe("USER_CANCELLED");
        });

        it("coerces the numeric code used on web", () => {
            const result = normalizePurchasesError(webError());

            assertPurchasesError(result);
            expect(result.code).toBe("2");
        });
    });

    describe("values it leaves alone", () => {
        it.each([["a string", "boom"], ["null", null], ["undefined", undefined]])(
            "returns %s unchanged",
            (_name, input) => {
                expect(normalizePurchasesError(input)).toBe(input);
            }
        );

        it("does not touch an error that carries no code", () => {
            const input = new UninitializedPurchasesError();

            const result = normalizePurchasesError(input) as Record<string, unknown>;

            expect(result).toBe(input);
            expect(result.userInfo).toBeUndefined();
            expect(result.underlyingErrorMessage).toBeUndefined();
            expect(result.readableErrorCode).toBeUndefined();
        });
    });
});
