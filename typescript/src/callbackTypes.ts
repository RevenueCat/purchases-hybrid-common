import {
  CustomerInfo
} from './customerInfo';
import {
  LOG_LEVEL
} from './enums';

/**
* Listener used on updated customer info
* @callback CustomerInfoUpdateListener
* @param {Object} customerInfo Object containing info for the customer
*/
export type CustomerInfoUpdateListener = (customerInfo: CustomerInfo) => void;
export type ShouldPurchasePromoProductListener = (deferredPurchase: () => Promise<MakePurchaseResult>) => void;
export type MakePurchaseResult = { productIdentifier: string; customerInfo: CustomerInfo; };
export type LogHandler = (logLevel: LOG_LEVEL, message: string) => void;

/**
* Holds the logIn result
*/
export interface LogInResult {
  /**
   * The Customer Info for the user.
   */
  readonly customerInfo: CustomerInfo;
  /**
   * True if the call resulted in a new user getting created in the RevenueCat backend.
   */
  readonly created: boolean;
}