type UnknownRecord = Record<string, unknown>;

/**
 * Each host framework nests `ErrorContainer.info` under a different key:
 * React Native under `userInfo`, Capacitor under `data`, and
 * purchases-js-hybrid-mappings under `info`.
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

function asString(value: unknown, fallback: string): string {
    return typeof value === "string" ? value : fallback;
}

/**
 * `purchases-js` types its error code as a numeric enum, while the native
 * bridges send it as a string.
 */
function readCode(error: UnknownRecord, payload: UnknownRecord): string | undefined {
    const raw = error.code !== undefined ? error.code : payload.code;
    if (typeof raw === "number") {
        return String(raw);
    }
    return typeof raw === "string" ? raw : undefined;
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

    const existingUserInfo = isRecord(error.userInfo) ? error.userInfo : undefined;
    const readableErrorCode = asString(
        payload.readableErrorCode !== undefined
            ? payload.readableErrorCode
            : existingUserInfo && existingUserInfo.readableErrorCode,
        ""
    );

    error.code = code;

    // Preserve the richer userInfo React Native already provides; only guarantee
    // the one field ErrorInfo declares.
    if (existingUserInfo) {
        if (typeof existingUserInfo.readableErrorCode !== "string") {
            existingUserInfo.readableErrorCode = readableErrorCode;
        }
    } else {
        error.userInfo = { readableErrorCode };
    }

    if (typeof error.message !== "string" || error.message === "") {
        error.message = asString(payload.message, "");
    }
    if (typeof error.readableErrorCode !== "string") {
        error.readableErrorCode = readableErrorCode;
    }
    if (typeof error.underlyingErrorMessage !== "string") {
        error.underlyingErrorMessage = asString(payload.underlyingErrorMessage, "");
    }
    if (!("userCancelled" in error)) {
        const userCancelled = payload.userCancelled;
        error.userCancelled = typeof userCancelled === "boolean" ? userCancelled : null;
    }

    return error;
}

function isPromiseLike(value: unknown): value is PromiseLike<unknown> {
    return isRecord(value) && typeof value.then === "function";
}

function normalizeRejection(result: PromiseLike<unknown>): PromiseLike<unknown> {
    const normalized = result.then(undefined, (error: unknown) => {
        throw normalizePurchasesError(error);
    });

    // Capacitor's addListener resolves a promise that also carries a `remove`
    // property, which chaining off it would otherwise drop.
    const source = result as unknown as UnknownRecord;
    const destination = normalized as unknown as UnknownRecord;
    Object.keys(source).forEach((key) => {
        destination[key] = source[key];
    });

    return normalized;
}

/**
 * Wraps a native plugin so every method that rejects runs its error through
 * {@link normalizePurchasesError} first.
 *
 * Methods are wrapped lazily and memoized, so repeated reads of the same
 * method return the same function.
 *
 * @public
 */
export function withNormalizedErrors<T extends object>(plugin: T): T {
    const wrapped = new Map<PropertyKey, unknown>();

    return new Proxy(plugin, {
        get(target, property, receiver) {
            const value = Reflect.get(target, property, receiver);
            if (typeof value !== "function") {
                return value;
            }

            if (!wrapped.has(property)) {
                wrapped.set(property, function (this: unknown, ...args: unknown[]): unknown {
                    const result = (value as (...callArgs: unknown[]) => unknown).apply(target, args);
                    return isPromiseLike(result) ? normalizeRejection(result) : result;
                });
            }
            return wrapped.get(property);
        },
    });
}
