import { CustomerInfo } from "./customerInfo";
import { PurchasesError } from "./errors";

export type WebPurchaseRedemption = {
    redemptionLink: string;
}

export enum WebPurchaseRedemptionResultType {
  SUCCESS = "SUCCESS",
  ERROR = "ERROR",
  ALREADY_REDEEMED = "ALREADY_REDEEMED",
  INVALID_TOKEN = "INVALID_TOKEN",
  EXPIRED = "EXPIRED",
}

export type WebPurchaseRedemptionResult =
  | { result: WebPurchaseRedemptionResultType.SUCCESS, customerInfo: CustomerInfo }
  | { result: WebPurchaseRedemptionResultType.ERROR, error: PurchasesError }
  | { result: WebPurchaseRedemptionResultType.ALREADY_REDEEMED }
  | { result: WebPurchaseRedemptionResultType.INVALID_TOKEN }
  | { result: WebPurchaseRedemptionResultType.EXPIRED, obfuscatedEmail: string }
