/**
 * @deprecated, use PRODUCT_CATEGORY
 */
export enum PURCHASE_TYPE {
  /**
   * A type of SKU for in-app products.
   */
  INAPP = "inapp",

  /**
   * A type of SKU for subscriptions.
   */
  SUBS = "subs",
}

/**
 * Enum for billing features.
 * Currently, these are only relevant for Google Play Android users:
 * https://developer.android.com/reference/com/android/billingclient/api/BillingClient.FeatureType
 */
export enum BILLING_FEATURE {
  /**
   * Purchase/query for subscriptions.
   */
  SUBSCRIPTIONS,

  /**
   * Subscriptions update/replace.
   */
  SUBSCRIPTIONS_UPDATE,

  /**
   * Purchase/query for in-app items on VR.
   */
  IN_APP_ITEMS_ON_VR,

  /**
   * Purchase/query for subscriptions on VR.
   */
  SUBSCRIPTIONS_ON_VR,

  /**
   * Launch a price change confirmation flow.
   */
  PRICE_CHANGE_CONFIRMATION,
}

export enum REFUND_REQUEST_STATUS {
  /**
   * Apple has received the refund request.
   */
  SUCCESS,

  /**
   * User canceled submission of the refund request.
   */
  USER_CANCELLED,

  /**
   * There was an error with the request. See message for more details.
   */
  ERROR
}

export enum LOG_LEVEL {
  VERBOSE = "VERBOSE",
  DEBUG = "DEBUG",
  INFO = "INFO",
  WARN = "WARN",
  ERROR = "ERROR"
}

/**
 * Enum for in-app message types.
 * This can be used if you disable automatic in-app message from showing automatically.
 * Then, you can pass what type of messages you want to show in the `showInAppMessages`
 * method in Purchases.
 */
export enum IN_APP_MESSAGE_TYPE {
  /**
   * In-app messages to indicate there has been a billing issue charging the user.
   */
  BILLING_ISSUE,

  /**
   * iOS-only. This message will show if you increase the price of a subscription and 
   * the user needs to opt-in to the increase.
   */
  PRICE_INCREASE_CONSENT,

  /**
   * iOS-only. StoreKit generic messages.
   */
  GENERIC
}