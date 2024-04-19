import {
  CustomerInfo, PurchasesStoreTransaction
} from './customerInfo';
import {
  LOG_LEVEL
} from './enums';

/**
* Listener used on updated customer info
* @public
* @param customerInfo - Object containing info for the customer
*/
export type CustomerInfoUpdateListener = (customerInfo: CustomerInfo) => void;
/**
 * Listener used to determine if a user should be able to purchase a promo product.
 * @public
 */
export type ShouldPurchasePromoProductListener = (deferredPurchase: () => Promise<MakePurchaseResult>) => void;
/**
 * Result of a successful purchase
 * @public
 */
export type MakePurchaseResult = {
  /**
   * The product identifier of the purchased product
   */
  productIdentifier: string;
  /**
   * The Customer Info for the user.
   */
  customerInfo: CustomerInfo;
  /**
   * The transaction object for the purchase
   */
  transaction: PurchasesStoreTransaction;
};

/**
 * Listener used to receive log messages from the SDK.
 * @public
 */
export type LogHandler = (logLevel: LOG_LEVEL, message: string) => void;

/**
* Holds the logIn result
* @public
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
