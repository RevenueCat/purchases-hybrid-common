import { PurchasesError } from "../errors";
import { withNormalizedErrors } from "../errorNormalizer";
import { capacitorError } from "./fixtures";

function capacitorStylePlugin() {
    return {
        succeeds: (): Promise<string> => Promise.resolve("ok"),
        rejects: (): Promise<never> => Promise.reject(capacitorError()),
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

    it("returns the same wrapper every time a method is read", () => {
        const plugin = withNormalizedErrors(capacitorStylePlugin());

        expect(plugin.synchronous).toBe(plugin.synchronous);
    });

    // React Native's TurboModules return promises backed by JSI host objects.
    // Copying their properties wholesale throws inside Hermes ("Cannot read
    // property 'length' of null"), which took the app down at startup.
    it("does not copy the properties of the returned promise wholesale", async () => {
        const hostBacked = Promise.resolve("configured");
        Object.defineProperty(hostBacked, "hostOnly", {
            enumerable: true,
            get() {
                throw new TypeError("Cannot read property 'length' of null");
            },
        });
        const plugin = withNormalizedErrors({ configure: () => hostBacked });

        await expect(plugin.configure()).resolves.toBe("configured");
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
