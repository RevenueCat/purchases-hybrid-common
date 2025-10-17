import {
  ENTITLEMENT_VERIFICATION_MODE,
  STOREKIT_VERSION,
  PurchasesAreCompletedBy,
} from "./enums";

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
   * Set this to MY_APP and provide a STOREKIT_VERSION if you have your own IAP implementation and
   * want to only use RevenueCat's backend. Defaults to PURCHASES_ARE_COMPLETED_BY_TYPE.REVENUECAT.
   *
   * If you are on Android and setting this to MY_APP, will have to acknowledge the purchases yourself.
   * If your app is only on Android, you may specify any StoreKit version, as it is ignored by the
   * Android SDK.
   */
  purchasesAreCompletedBy?: PurchasesAreCompletedBy;
  /**
   * An optional string. iOS-only, will be ignored for Android.
   * Set this if you would like the RevenueCat SDK to store its preferences in a different NSUserDefaults
   * suite, otherwise it will use standardUserDefaults. Default is null, which will make the SDK use standardUserDefaults.
   */
  userDefaultsSuiteName?: string;
  /**
   * iOS-only, will be ignored for Android.
   *
   * By selecting the DEFAULT value, RevenueCat will automatically select the most appropriate StoreKit version
   * for the app's runtime environment.
   *
   * - Warning: Make sure you have an In-App Purchase Key configured in your app.
   * Please see https://rev.cat/in-app-purchase-key-configuration for more info.
   *
   * - Note: StoreKit 2 is only available on iOS 16+. StoreKit 1 will be used for previous iOS versions
   * regardless of this setting.
   */
  storeKitVersion?: STOREKIT_VERSION;
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

  /**
   * Enabling diagnostics will send some performance and debugging information from the SDK to RevenueCat's servers.
   * Examples of this information include response times, cache hits or error codes.
   * No personal identifiable information will be collected.
   * The default value is false.
   */
  diagnosticsEnabled?: boolean;

  /**
   * Enable this setting to allow the collection of identifiers when setting the identifier for an
   * attribution network. For example, when calling `Purchases.setAdjustID` or `Purchases.setAppsflyerID`,
   * the SDK would collect some device identifiers, if available, and send them
   * to RevenueCat. This is required by some attribution networks to attribute installs and re-installs.
   *
   * Enabling this setting does NOT mean we will always collect the identifiers. We will only do so when
   * setting an attribution network ID AND the user has not limited ad tracking on their device.
   *
   * Default is enabled.
   */
  automaticDeviceIdentifierCollectionEnabled?: boolean;

  /**
   * Override the preferred UI locale for RevenueCat UI components at runtime. This affects both API requests and UI rendering.
   * This will automatically clear the offerings cache and trigger a background refetch to get paywall templates with the correct localizations.
   *
   * @param localeString - The locale string (e.g., "es-ES", "en-US") or null to use system default
   */
  preferredUILocaleOverride?: string;
}
