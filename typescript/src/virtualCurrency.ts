/**
 * The VirtualCurrencies object contains all the virtual currencies associated to the user.
 * @public
 */
export interface PurchasesVirtualCurrencies {
  /**
   * Map of all VirtualCurrency (`PurchasesVirtualCurrency`) objects keyed by virtual currency code.
   */
  readonly all: { [key: string]: PurchasesVirtualCurrency };
}

/**
 * The VirtualCurrency object represents information about a virtual currency in the app.
 * Use this object to access information about a virtual currency, such as its current balance.
 *
 * @public
 */
export interface PurchasesVirtualCurrency {
  /**
   * The virtual currency's balance.
   */
  readonly balance: number;

  /**
   * The virtual currency's name.
   */
  readonly name: string;

  /**
   * The virtual currency's code.
   */
  readonly code: string;

  /**
   * The virtual currency's description defined in the RevenueCat dashboard.
   */
  readonly serverDescription: string | null;
}
