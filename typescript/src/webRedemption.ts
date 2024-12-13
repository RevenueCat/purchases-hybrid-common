import { CustomerInfo } from "./customerInfo";
import { PurchasesError } from "./errors";

/**
 * An object containing the redemption link to be redeemed.
 * @public
 */
export type WebPurchaseRedemption = {
  /**
   * The redemption link to be redeemed.
   */
  redemptionLink: string;
}

/**
 * The result type of a Redemption Link redemption attempt.
 * @public
 */
export enum WebPurchaseRedemptionResultType {
  /**
   * The redemption was successful.
   */
  SUCCESS = "SUCCESS",
  /**
   * The redemption failed.
   */
  ERROR = "ERROR",
  /**
   * The purchase associated to the link belongs to another user.
   */
  PURCHASE_BELONGS_TO_OTHER_USER = "PURCHASE_BELONGS_TO_OTHER_USER",
  /**
   * The token is invalid.
   */
  INVALID_TOKEN = "INVALID_TOKEN",
  /**
   * The token has expired. A new Redemption Link will be sent to the email used during purchase.
   */
  EXPIRED = "EXPIRED",
}

/**
 * The result of a redemption attempt.
 * @public
 */
export type WebPurchaseRedemptionResult =
  | { result: WebPurchaseRedemptionResultType.SUCCESS, customerInfo: CustomerInfo }
  | { result: WebPurchaseRedemptionResultType.ERROR, error: PurchasesError }
  | { result: WebPurchaseRedemptionResultType.PURCHASE_BELONGS_TO_OTHER_USER }
  | { result: WebPurchaseRedemptionResultType.INVALID_TOKEN }
  | { result: WebPurchaseRedemptionResultType.EXPIRED, obfuscatedEmail: string }
