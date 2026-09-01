type UnknownRecord = Record<string, unknown>;

/**
 * React Native nests `ErrorContainer.info` under `userInfo`, Capacitor under `data`,
 * and `purchases-js-hybrid-mappings` under `info`.
 */
const PAYLOAD_KEYS = ["userInfo", "data", "info"];

function isRecord(value: unknown): value is UnknownRecord {
    return typeof value === "object" && value !== null;
}

function readPayload(error: UnknownRecord): UnknownRecord {
    for (const key of PAYLOAD_KEYS) {
        const candidate = error[key];
        if (isRecord(candidate)) {
            return candidate;
        }
    }
    return {};
}

function stringOrEmpty(values: unknown[]): string {
    for (const value of values) {
        if (typeof value === "string") {
            return value;
        }
    }
    return "";
}

/**
 * Every code the SDK emits is a PURCHASES_ERROR_CODE value, which is always numeric.
 * Plugin level rejections use names such as "UNIMPLEMENTED" or "PAYWALL_ERROR" and are
 * not ours to touch. `purchases-js` sends the same value as a number.
 *
 * Deliberately looser than PURCHASES_ERROR_CODE membership: that enum omits codes the
 * native SDKs emit (36 to 41), and Android and iOS disagree on 28 and 36, so matching
 * against it would reject genuine errors. See RevenueCat/purchases-error-codes#18.
 */
function readCode(error: UnknownRecord, payload: UnknownRecord): string | undefined {
    for (const candidate of [error.code, payload.code]) {
        const code = String(candidate);
        if (/^\d+$/.test(code)) {
            return code;
        }
    }
    return undefined;
}

/**
 * Fills in the fields {@link PurchasesError} declares but the platform bridges
 * leave nested.
 *
 * Hybrid SDKs should call this on every error rejected by the native module,
 * then rethrow the returned value.
 *
 * The error is mutated in place and returned. Copying it into a new object
 * would discard its prototype and stack, which would break `instanceof Error`
 * for consumers and `instanceof CapacitorException` on Capacitor.
 *
 * Values the bridge did not send fall back to the same defaults the native
 * layer already applies, so the result always satisfies {@link PurchasesError}.
 *
 * Anything that is not an object, or that carries no error code, is returned
 * untouched.
 *
 * @public
 */
export function normalizePurchasesError(error: unknown): unknown {
    if (!isRecord(error)) {
        return error;
    }

    const payload = readPayload(error);
    const code = readCode(error, payload);
    if (code === undefined) {
        return error;
    }

    error.code = code;

    // Capacitor nests the payload under `data`, leaving userInfo empty, so lift it in.
    // On React Native the payload already is userInfo, and spreading it last keeps
    // everything the bridge put there.
    const existingUserInfo = isRecord(error.userInfo) ? error.userInfo : undefined;
    const userInfo: UnknownRecord = { ...payload, ...existingUserInfo };
    if (typeof userInfo.readableErrorCode !== "string") {
        userInfo.readableErrorCode = stringOrEmpty([payload.readableErrorCode, error.readableErrorCode]);
    }
    error.userInfo = userInfo;

    if (typeof error.message !== "string" || error.message === "") {
        error.message = stringOrEmpty([payload.message]);
    }
    if (typeof error.readableErrorCode !== "string") {
        error.readableErrorCode = userInfo.readableErrorCode;
    }
    if (typeof error.underlyingErrorMessage !== "string") {
        error.underlyingErrorMessage = stringOrEmpty([payload.underlyingErrorMessage]);
    }
    if (!("userCancelled" in error)) {
        const userCancelled = payload.userCancelled;
        error.userCancelled = typeof userCancelled === "boolean" ? userCancelled : null;
    }

    return error;
}

function normalizeRejection(result: Promise<unknown>): Promise<unknown> {
    const normalized = result.then(undefined, (error: unknown) => {
        throw normalizePurchasesError(error);
    });

    // Capacitor's addListener resolves a promise that also carries a `remove`
    // property, which chaining off it would otherwise drop. Copy it by name:
    // enumerating a React Native TurboModule promise's own keys throws inside
    // Hermes ("Cannot read property 'length' of null").
    const remove = (result as { remove?: unknown }).remove;
    if (typeof remove === "function") {
        (normalized as { remove?: unknown }).remove = remove;
    }

    return normalized;
}

/**
 * Wraps a native plugin so every method that rejects runs its error through
 * {@link normalizePurchasesError} first.
 *
 * Needs an ES2015 runtime: `Proxy` cannot be downlevelled to this package's es5
 * target. Hermes and every browser the SDKs support provide it.
 *
 * @public
 */
export function withNormalizedErrors<T extends object>(plugin: T): T {
    const wrapped = new Map<unknown, unknown>();

    return new Proxy(plugin, {
        get(target, property, receiver) {
            const value = Reflect.get(target, property, receiver);
            if (typeof value !== "function") {
                return value;
            }

            const cached = wrapped.get(value);
            if (cached !== undefined) {
                return cached;
            }

            const wrapper = function (this: unknown, ...args: unknown[]): unknown {
                const result = (value as (...callArgs: unknown[]) => unknown).apply(target, args);
                return result instanceof Promise ? normalizeRejection(result) : result;
            };
            wrapped.set(value, wrapper);
            return wrapper;
        },
    });
}
