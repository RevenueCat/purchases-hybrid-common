import { PurchasesError } from "../errors";
import { withNormalizedErrors } from "../errorNormalizer";

function capacitorStylePlugin() {
    return {
        succeeds: (): Promise<string> => Promise.resolve("ok"),
        rejects: (): Promise<never> =>
            Promise.reject(
                Object.assign(new Error("There was a credentials issue."), {
                    code: "11",
                    data: {
                        code: 11,
                        message: "There was a credentials issue.",
                        readableErrorCode: "InvalidCredentialsError",
                        underlyingErrorMessage: "Invalid API Key.",
                    },
                })
            ),
        rejectsWithoutCode: (): Promise<never> => Promise.reject(new Error("boom")),
        synchronous: (): string => "not a promise",
        notAFunction: 42,
    };
}

describe("withNormalizedErrors", () => {
    it("leaves resolved values alone", async () => {
        const plugin = withNormalizedErrors(capacitorStylePlugin());

        await expect(plugin.succeeds()).resolves.toBe("ok");
    });

    it("normalizes a rejection", async () => {
        const plugin = withNormalizedErrors(capacitorStylePlugin());

        const error: PurchasesError = await plugin.rejects().catch((caught) => caught);

        expect(error.readableErrorCode).toBe("InvalidCredentialsError");
        expect(error.underlyingErrorMessage).toBe("Invalid API Key.");
        expect(error.userInfo.readableErrorCode).toBe("InvalidCredentialsError");
        expect(error.userCancelled).toBeNull();
    });

    it("keeps the rejected error's identity", async () => {
        const original = capacitorStylePlugin();
        const plugin = withNormalizedErrors(original);

        const caught = await plugin.rejects().catch((error) => error);

        expect(caught).toBeInstanceOf(Error);
        expect(typeof caught.stack).toBe("string");
    });

    it("passes through a rejection that is not ours", async () => {
        const plugin = withNormalizedErrors(capacitorStylePlugin());

        const caught = await plugin.rejectsWithoutCode().catch((error) => error);

        expect(caught).toBeInstanceOf(Error);
        expect(caught.userInfo).toBeUndefined();
    });

    // Wrapping a UI plugin, whose rejections carry names rather than error
    // codes, must leave those rejections untouched.
    it("passes through a rejection carrying a named code", async () => {
        const plugin = withNormalizedErrors({
            presentPaywall: (): Promise<never> =>
                Promise.reject(Object.assign(new Error("not supported"), { code: "PAYWALL_ERROR" })),
        });

        const caught = await plugin.presentPaywall().catch((error) => error);

        expect(caught.code).toBe("PAYWALL_ERROR");
        expect(caught.userInfo).toBeUndefined();
    });

    it("passes through non promise return values", () => {
        const plugin = withNormalizedErrors(capacitorStylePlugin());

        expect(plugin.synchronous()).toBe("not a promise");
    });

    it("passes through properties that are not functions", () => {
        const plugin = withNormalizedErrors(capacitorStylePlugin());

        expect(plugin.notAFunction).toBe(42);
    });

    it("returns the same wrapper on repeated reads", () => {
        const plugin = withNormalizedErrors(capacitorStylePlugin());

        expect(plugin.succeeds).toBe(plugin.succeeds);
    });

    // Capacitor attaches `remove` to the promise addListener returns, for the
    // deprecated call style that does not await it.
    it("preserves own properties attached to the returned promise", () => {
        const remove = jest.fn();
        const plugin = withNormalizedErrors({
            addListener: () => Object.assign(Promise.resolve({ id: 1 }), { remove }),
        });

        const returned = plugin.addListener() as Promise<unknown> & { remove: () => void };

        expect(returned.remove).toBe(remove);
    });
});
