/**
 * Holds parameters to initialize the SDK.
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
   */
  observerMode?: boolean;
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
}
