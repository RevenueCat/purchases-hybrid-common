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
