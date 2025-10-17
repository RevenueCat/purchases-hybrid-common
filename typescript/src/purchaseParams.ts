import {
  GoogleProductChangeInfo,
  PurchasesPackage, PurchasesPromotionalOffer,
  PurchasesStoreProduct,
  PurchasesWinBackOffer,
  SubscriptionOption
} from "./offerings";

/**
 * Holds parameters to initialize a purchase in our SDK.
 * @public
 */
export interface PurchaseParams {
  /**
   * The {@link PurchasesPackage}, {@link PurchasesStoreProduct} or {@link SubscriptionOption} to purchase.
   */
  itemToPurchase: PurchasesPackage | PurchasesStoreProduct | SubscriptionOption;
  /**
   * Google Play only. Optional {@link GoogleProductChangeInfo} you
   * wish to upgrade from containing the oldProductIdentifier and the optional prorationMode.
   */
  googleProductChangeInfo?: GoogleProductChangeInfo | null;
  /**
   * Google Play only. Optional boolean that indicates personalized pricing on products available for purchase in the EU.
   * For compliance with EU regulations. User will see "This price has been customized for you" in the purchase dialog when true.
   * See https://developer.android.com/google/play/billing/integrate#personalized-price for more info.
   */
  googleIsPersonalizedPrice?: boolean | null;
  /**
   * iOS only, requires iOS 18.0 or greater with StoreKit 2. Win-back offer to apply to this purchase.
   * Retrieve this using getEligibleWinBackOffersForPackage or getEligibleWinBackOffersForStoreProduct.
   */
  winBackOffer?: PurchasesWinBackOffer | null;
  /**
   * iOS only. Discount to apply to this purchase. Retrieve this discount using getPromotionalOffer.
   */
  discount?: PurchasesPromotionalOffer | null;
}
