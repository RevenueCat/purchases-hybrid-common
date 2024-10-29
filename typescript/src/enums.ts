/**
 * @deprecated Use PRODUCT_CATEGORY
 * @public
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
 * @public
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

/**
 * Enum for possible refund request results.
 * @public
 */
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
  ERROR,
}

/**
 * Enum for possible log levels to print.
 * @public
 */
export enum LOG_LEVEL {
  VERBOSE = "VERBOSE",
  DEBUG = "DEBUG",
  INFO = "INFO",
  WARN = "WARN",
  ERROR = "ERROR",
}

/**
 * Enum for in-app message types.
 * This can be used if you disable automatic in-app message from showing automatically.
 * Then, you can pass what type of messages you want to show in the `showInAppMessages`
 * method in Purchases.
 * @public
 */
export enum IN_APP_MESSAGE_TYPE {
  // Make sure the enum values are in sync with those defined in iOS/Android
  /**
   * In-app messages to indicate there has been a billing issue charging the user.
   */
  BILLING_ISSUE = 0,

  /**
   * iOS-only. This message will show if you increase the price of a subscription and
   * the user needs to opt-in to the increase.
   */
  PRICE_INCREASE_CONSENT = 1,

  /**
   * iOS-only. StoreKit generic messages.
   */
  GENERIC = 2,

  /**
   * iOS-only. This message will show if the subscriber is eligible for an iOS win-back
   * offer and will allow the subscriber to redeem the offer.
   */
  WIN_BACK_OFFER = 3,
}

/**
 * Enum of entitlement verification modes.
 * @public
 */
export enum ENTITLEMENT_VERIFICATION_MODE {
  /**
   * The SDK will not perform any entitlement verification.
   */
  DISABLED = "DISABLED",

  /**
   * Enable entitlement verification.
   *
   * If verification fails, this will be indicated with [VerificationResult.FAILED] in
   * the [EntitlementInfos.verification] and [EntitlementInfo.verification] properties but parsing will not fail
   * (i.e. Entitlements will still be granted).
   *
   * This can be useful if you want to handle verification failures to display an error/warning to the user
   * or to track this situation but still grant access.
   */
  INFORMATIONAL = "INFORMATIONAL",

  // Add ENFORCED mode once we're ready to ship it.
  // ENFORCED = "ENFORCED"
}

/**
 * The result of the verification process. For more details check: http://rev.cat/trusted-entitlements
 *
 * This is accomplished by preventing MiTM attacks between the SDK and the RevenueCat server.
 * With verification enabled, the SDK ensures that the response created by the server was not
 * modified by a third-party, and the response received is exactly what was sent.
 *
 * - Note: Verification is only performed if enabled using PurchasesConfiguration's
 * entitlementVerificationMode property. This is disabled by default.
 *
 * @public
 */
export enum VERIFICATION_RESULT {
  /**
   * No verification was done.
   *
   * This value is returned when verification is not enabled in PurchasesConfiguration
   */
  NOT_REQUESTED = "NOT_REQUESTED",

  /**
   * Verification with our server was performed successfully.
   */
  VERIFIED = "VERIFIED",

  /**
   * Verification failed, possibly due to a MiTM attack.
   */
  FAILED = "FAILED",

  /**
   * Verification was performed on device.
   */
  VERIFIED_ON_DEVICE = "VERIFIED_ON_DEVICE",
}

/**
 * The result of presenting a paywall. This will be the last situation the user experienced before the
 * paywall closed.
 *
 * @public
 */
export enum PAYWALL_RESULT {
  /**
   * If the paywall wasn't presented. Only returned when using "presentPaywallIfNeeded"
   */
  NOT_PRESENTED = "NOT_PRESENTED",

  /**
   * If an error happened during purchase/restoration.
   */
  ERROR = "ERROR",

  /**
   * If the paywall was closed without performing an operation
   */
  CANCELLED = "CANCELLED",

  /**
   * If a successful purchase happened inside the paywall
   */
  PURCHASED = "PURCHASED",

  /**
   * If a successful restore happened inside the paywall
   */
  RESTORED = "RESTORED",
}

/**
 * Defines which version of StoreKit may be used
 * @public
 */
export enum STOREKIT_VERSION {
  /**
   * Always use StoreKit 1.
   */
  STOREKIT_1 = "STOREKIT_1",

  /**
   * Always use StoreKit 2 (StoreKit 1 will be used if StoreKit 2 is not available in the current device.)
   * - Warning: Make sure you have an In-App Purchase Key configured in your app.
   * Please see https://rev.cat/in-app-purchase-key-configuration for more info.
   */
  STOREKIT_2 = "STOREKIT_2",

  /**
   * Let RevenueCat use the most appropriate version of StoreKit
   */
  DEFAULT = "DEFAULT",
}

/**
 * Modes for completing the purchase process.
 * @public
 */
export enum PURCHASES_ARE_COMPLETED_BY_TYPE {
  /**
   * RevenueCat will **not** automatically acknowledge any purchases. You will have to do so manually.
   *
   * **Note:** failing to acknowledge a purchase within 3 days will lead to Google Play automatically issuing a
   * refund to the user.
   *
   * For more info, see [revenuecat.com](https://docs.revenuecat.com/docs/observer-mode#option-2-client-side).
   */
  MY_APP = "MY_APP",

  /**
   * RevenueCat will automatically acknowledge verified purchases. No action is required by you.
   */
  REVENUECAT = "REVENUECAT",
}

/**
 * Configuration option that specifies that your app will complete purchases.
 * @public
 */
export type PurchasesAreCompletedByMyApp = {
  type: PURCHASES_ARE_COMPLETED_BY_TYPE.MY_APP;

  /**
   * The version of StoreKit that your app is using to make purchases. This value is ignored
   * on Android, so if your app is Android-only, you may provide any value.
   */
  storeKitVersion: STOREKIT_VERSION;
};

/**
 * Allows you to specify whether you want RevenueCat to complete your app's purchases
 * or if your app will do so.
 *
 * You can configure RevenueCat to complete your purchases like so:
 * ```typescript
 * Purchases.configure({
 *  apiKey: "123",
 *  purchasesAreCompletedBy: PURCHASES_ARE_COMPLETED_BY.REVENUECAT,
 * });
 * ```
 *
 * You can specify that purchase are completed by your app like so:
 * ```typescript
 * Purchases.configure({
 *  apiKey: "123",
 *  purchasesAreCompletedBy: {
 *    type: PURCHASES_ARE_COMPLETED_BY.MY_APP,
 *    storeKitVersion: STOREKIT_VERSION.STOREKIT_1
 *  },
 * });
 * ```
 * @public
 */
export type PurchasesAreCompletedBy =
  | PURCHASES_ARE_COMPLETED_BY_TYPE.REVENUECAT
  | PurchasesAreCompletedByMyApp;
