import { ENTITLEMENT_VERIFICATION_MODE, PURCHASES_ARE_COMPLETED_BY } from "./enums";

/**
 * Holds parameters to initialize the SDK.
 * @public
 */
export interface PurchasesConfiguration {
  /**
   * RevenueCat API Key. Needs to be a string
   */
  apiKey: string;
  /**
   * A unique id for identifying the user
   */
  appUserID?: string | null;
  /**
   * An optional boolean. Set this to TRUE if you have your own IAP implementation and
   * want to use only RevenueCat's backend. Default is FALSE. If you are on Android and setting this to ON, you will have
   * to acknowledge the purchases yourself.
   * @deprecated Use purchasesAreCompletedBy instead.
   */
  observerMode?: boolean;
  /**
   * Set this to MY_APP if you have your own IAP implementation and
   * want to use only RevenueCat's backend. Default is REVENUECAT. If you are on Android and setting this to MY_APP, you will have
   * to acknowledge the purchases yourself.
   */
  purchasesAreCompletedBy?: PURCHASES_ARE_COMPLETED_BY,
  /**
   * An optional string. iOS-only, will be ignored for Android.
   * Set this if you would like the RevenueCat SDK to store its preferences in a different NSUserDefaults
   * suite, otherwise it will use standardUserDefaults. Default is null, which will make the SDK use standardUserDefaults.
   */
  userDefaultsSuiteName?: string;
  /**
   * iOS-only, will be ignored for Android.
   * Set this to TRUE to enable StoreKit2.
   * Default is FALSE.
   *
   * @deprecated RevenueCat currently uses StoreKit 1 for purchases, as its stability in production scenarios has
   * proven to be more performant than StoreKit 2.
   * We're collecting more data on the best approach, but StoreKit 1 vs StoreKit 2 is an implementation detail
   * that you shouldn't need to care about.
   * We recommend not using this parameter, letting RevenueCat decide for you which StoreKit implementation to use.
   */
  usesStoreKit2IfAvailable?: boolean;
  /**
   * An optional boolean. Android only. Required to configure the plugin to be used in the Amazon Appstore.
   */
  useAmazon?: boolean;
  /**
   * Whether we should show store in-app messages automatically. Both Google Play and the App Store provide in-app
   * messages for some situations like billing issues. By default, those messages will be shown automatically.
   * This allows to disable that behavior, so you can display those messages at your convenience. For more information,
   * check: https://rev.cat/storekit-message and https://rev.cat/googleplayinappmessaging
   */
  shouldShowInAppMessagesAutomatically?: boolean;

  /**
   * Verification strictness levels for [EntitlementInfo].
   * See https://rev.cat/trusted-entitlements for more info.
   */
  entitlementVerificationMode?: ENTITLEMENT_VERIFICATION_MODE;

  /**
   * Enable this setting if you want to allow pending purchases for prepaid subscriptions (only supported
   * in Google Play). Note that entitlements are not granted until payment is done.
   * Disabled by default.
   */
  pendingTransactionsForPrepaidPlansEnabled?: boolean;
}
