import { isPurchasesError, PURCHASES_ERROR_CODE } from "../errors";
import { normalizePurchasesError } from "../errorNormalizer";
import {
    capacitorError,
    flatError,
    reactNativeAndroidError,
    reactNativeIosError,
    webError,
} from "./fixtures";

function validError(): Record<string, unknown> {
    return {
        code: PURCHASES_ERROR_CODE.STORE_PROBLEM_ERROR,
        message: "Store problem",
        userInfo: { readableErrorCode: "STORE_PROBLEM" },
        underlyingErrorMessage: "",
    };
}

describe("isPurchasesError", () => {
    const fixtures: Array<[string, () => unknown]> = [
        ["react native android", reactNativeAndroidError],
        ["react native ios", reactNativeIosError],
        ["capacitor", capacitorError],
        ["web", webError],
        ["already flat", flatError],
    ];

    it.each(fixtures)("accepts a normalized %s error", (_name, makeFixture) => {
        expect(isPurchasesError(normalizePurchasesError(makeFixture()))).toBe(true);
    });

    it("accepts a value without the deprecated fields", () => {
        expect(isPurchasesError(validError())).toBe(true);
    });

    it.each(Object.values(PURCHASES_ERROR_CODE))("accepts code %s", (code) => {
        expect(isPurchasesError({ ...validError(), code })).toBe(true);
    });

    it.each([null, undefined, "error", 2, true])("rejects %p", (value) => {
        expect(isPurchasesError(value)).toBe(false);
    });

    it("rejects a raw native payload with a numeric code and no userInfo", () => {
        expect(isPurchasesError({
            code: 2,
            message: "Store problem",
            readableErrorCode: "STORE_PROBLEM",
            underlyingErrorMessage: "",
        })).toBe(false);
    });

    it.each(["9999", "UNIMPLEMENTED", ""])("rejects unknown code %p", (code) => {
        expect(isPurchasesError({ ...validError(), code })).toBe(false);
    });

    const invalidFields: Array<[string, Record<string, unknown>]> = [
        ["numeric code", { code: 2 }],
        ["missing code", { code: undefined }],
        ["non-string message", { message: 1 }],
        ["missing message", { message: undefined }],
        ["null userInfo", { userInfo: null }],
        ["non-object userInfo", { userInfo: "STORE_PROBLEM" }],
        ["userInfo without readableErrorCode", { userInfo: {} }],
        ["non-string readableErrorCode", { userInfo: { readableErrorCode: 2 } }],
        ["non-string underlyingErrorMessage", { underlyingErrorMessage: null }],
        ["missing underlyingErrorMessage", { underlyingErrorMessage: undefined }],
    ];

    it.each(invalidFields)("rejects %s", (_name, overrides) => {
        const error = { ...validError(), ...overrides };
        for (const [key, value] of Object.entries(overrides)) {
            if (value === undefined) {
                delete error[key];
            }
        }
        expect(isPurchasesError(error)).toBe(false);
    });
});
