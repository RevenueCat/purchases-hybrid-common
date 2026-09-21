/* tslint:disable:max-classes-per-file */
import { PURCHASES_ERROR_CODE } from "./generated/error-codes";

export { PURCHASES_ERROR_CODE };

/**
 * Type encapsulating an error in an SDK operation.
 * @public
 */
export interface PurchasesError {
    code: PURCHASES_ERROR_CODE;
    message: string;
    /**
     * @deprecated access readableErrorCode through userInfo.readableErrorCode
     */
    readableErrorCode: string;
    userInfo: ErrorInfo;
    underlyingErrorMessage: string;
    /**
     * @deprecated use code === Purchases.PURCHASES_ERROR_CODE.PURCHASE_CANCELLED_ERROR instead
     */
    userCancelled: boolean | null;
}

/**
 * Type encapsulating extra info on an error in an SDK operation.
 * @public
 */
export interface ErrorInfo {
    readableErrorCode: string;
}

/**
 * @internal
 */
export class UninitializedPurchasesError extends Error {
    constructor() {
        super("There is no singleton instance. " +
        "Make sure you configure Purchases before trying to get the default instance. " +
        "More info here: https://errors.rev.cat/configuring-sdk");

        // Set the prototype explicitly.
        Object.setPrototypeOf(this, UninitializedPurchasesError.prototype);
    }
}

/**
 * @internal
 */
export class UnsupportedPlatformError extends Error {
    constructor() {
        super("This method is not available in the current platform.");

        // Set the prototype explicitly.
        Object.setPrototypeOf(this, UnsupportedPlatformError.prototype);
    }
}

/**
 * Returns whether the given value is a {@link PurchasesError} thrown by the SDK.
 *
 * A value qualifies when it's schema matches {@link PurchasesError} and a `code` that is one of the
 * {@link PURCHASES_ERROR_CODE} values.
 *
 * @public
 */
export function isPurchasesError(error: unknown): error is PurchasesError {
    if (typeof error !== "object" || error === null) {
        return false;
    }

    if (!("code" in error) || typeof error.code !== "string") {
        return false;
    }

    if (!("message" in error) || typeof error.message !== "string") {
        return false;
    }

    if (!("userInfo" in error) || typeof error.userInfo !== "object" || error.userInfo == null) {
        return false;
    }

    if (!(("readableErrorCode") in error.userInfo) || typeof error.userInfo.readableErrorCode !== "string") {
        return false;
    }

    if (!("underlyingErrorMessage" in error) || typeof error.underlyingErrorMessage !== "string") {
        return false;
    }

    const { code } = error;

    const knownErrorCodes: ReadonlySet<string> = new Set(Object.values(PURCHASES_ERROR_CODE))

    return typeof code === "string" && knownErrorCodes.has(code);
}
