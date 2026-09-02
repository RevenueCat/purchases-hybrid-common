import { PurchasesError, UninitializedPurchasesError } from "../errors";
import { normalizePurchasesError } from "../errorNormalizer";
import {
    CapacitorException,
    capacitorError,
    flatError,
    reactNativeAndroidError,
    reactNativeIosError,
    webError,
} from "./fixtures";

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
        assertPurchasesError(normalizePurchasesError(makeFixture()));
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
            const input = Object.assign(new Error("outer"), {
                code: "2",
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
            const result = normalizePurchasesError({ code: "2", message: "Store problem" });

            assertPurchasesError(result);
            expect(result.underlyingErrorMessage).toBe("");
        });

        // Capacitor nests everything under data, so without lifting it the two
        // platforms would expose different userInfo.
        it("gives capacitor the same userInfo react native gets", () => {
            const result = normalizePurchasesError(capacitorError());

            assertPurchasesError(result);
            const userInfo = result.userInfo as unknown as Record<string, unknown>;
            expect(userInfo.underlyingErrorMessage).toBe("Invalid API Key.");
            expect(userInfo.readable_error_code).toBe("InvalidCredentialsError");
        });

        it("derives userInfo from a top level readableErrorCode", () => {
            const result = normalizePurchasesError(flatError());

            assertPurchasesError(result);
            expect(result.userInfo.readableErrorCode).toBe("USER_CANCELLED");
        });

        it("normalizes a numeric code to the string the enum uses", () => {
            const result = normalizePurchasesError({ code: 2, message: "Store problem" });

            assertPurchasesError(result);
            expect(result.code).toBe("2");
        });

        // mapPurchasesError nests the backend diagnostics under `info` rather than
        // `userInfo`, so without reading that key web would be the one platform
        // whose userInfo stays empty.
        it("lifts the web payload into userInfo", () => {
            const result = normalizePurchasesError(webError());

            assertPurchasesError(result);
            const userInfo = result.userInfo as unknown as Record<string, unknown>;
            expect(userInfo.statusCode).toBe(503);
            expect(userInfo.backendErrorCode).toBe(7638);
        });

        it("reads the code from the payload when the top level one is not a number", () => {
            const input = { code: null, userInfo: { code: 2, message: "Store problem" } };

            const result = normalizePurchasesError(input);

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

        // Both UI plugins and Capacitor itself reject with names rather than
        // PURCHASES_ERROR_CODE values.
        it.each([
            ["a capacitor plugin exception", "UNIMPLEMENTED"],
            ["a paywall plugin rejection", "PAYWALL_ERROR"],
            ["a negative number", -1],
        ])("does not touch %s", (_name, code) => {
            const input = { code, message: "not ours" } as Record<string, unknown>;

            const result = normalizePurchasesError(input) as Record<string, unknown>;

            expect(result).toBe(input);
            expect(result.userInfo).toBeUndefined();
            expect(result.underlyingErrorMessage).toBeUndefined();
            expect(result.userCancelled).toBeUndefined();
        });

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
