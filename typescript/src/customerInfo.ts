import { VERIFICATION_RESULT } from "./enums";

/**
 * The EntitlementInfo object gives you access to all of the information about the status of a user entitlement.
 * @public
 */
export interface PurchasesEntitlementInfo {
    /**
     * The entitlement identifier configured in the RevenueCat dashboard
     */
    readonly identifier: string;
    /**
     * True if the user has access to this entitlement
     */
    readonly isActive: boolean;
    /**
     * True if the underlying subscription is set to renew at the end of the billing period (expirationDate).
     */
    readonly willRenew: boolean;
    /**
     * The last period type this entitlement was in. Either: NORMAL, INTRO, TRIAL, PREPAID.
     */
    readonly periodType: string;
    /**
     * The latest purchase or renewal date for the entitlement in ISO8601 format.
     */
    readonly latestPurchaseDate: string;
    /**
     * The latest purchase or renewal date for the entitlement in milliseconds.
     */
    readonly latestPurchaseDateMillis: number;
    /**
     * The first date this entitlement was purchased in ISO8601 format.
     */
    readonly originalPurchaseDate: string;
    /**
     * The first date this entitlement was purchased in milliseconds.
     */
    readonly originalPurchaseDateMillis: number;
    /**
     * The expiration date for the entitlement in ISO8601, can be `null` for lifetime access.
     * If the `periodType` is `trial`, this is the trial expiration date.
     */
    readonly expirationDate: string | null;
    /**
     * The expiration date for the entitlement in milliseconds, can be `null` for lifetime access.
     * If the `periodType` is `trial`, this is the trial expiration date.
     */
    readonly expirationDateMillis: number | null;
    /**
     * The store where this entitlement was unlocked from.
     */
    readonly store: "PLAY_STORE" | "APP_STORE" | "STRIPE" | "MAC_APP_STORE" | "PROMOTIONAL" | "AMAZON" | "RC_BILLING" | "EXTERNAL" | "UNKNOWN_STORE";
    /**
     * The product identifier that unlocked this entitlement
     */
    readonly productIdentifier: string;
    /**
     * The product plan identifier that unlocked this entitlement. Android subscriptions only, null on consumables and iOS.
     */
    readonly productPlanIdentifier: string | null;
    /**
     * False if this entitlement is unlocked via a production purchase
     */
    readonly isSandbox: boolean;
    /**
     * The date an unsubscribe was detected in ISO8601 format. Can be `null`.
     *
     * Entitlement may still be active even if user has unsubscribed. Check the `isActive` property.
     */
    readonly unsubscribeDetectedAt: string | null;
    /**
     * The date an unsubscribe was detected in milliseconds. Can be `null`.
     *
     * Entitlement may still be active even if user has unsubscribed. Check the `isActive` property.
     */
    readonly unsubscribeDetectedAtMillis: number | null;
    /**
     * The date a billing issue was detected in ISO8601 format. Can be `null` if there is no billing issue or an
     * issue has been resolved
     *
     * Entitlement may still be active even if there is a billing issue. Check the `isActive` property.
     */
    readonly billingIssueDetectedAt: string | null;
    /**
     * The date a billing issue was detected in milliseconds. Can be `null` if there is no billing issue or an
     * issue has been resolved
     *
     * Entitlement may still be active even if there is a billing issue. Check the `isActive` property.
     */
    readonly billingIssueDetectedAtMillis: number | null;
    /**
     * Supported ownership types for an entitlement.
     * PURCHASED if the purchase was made directly by this user.
     * FAMILY_SHARED if the purchase has been shared to this user by a family member.
     * UNKNOWN if the purchase has no or an unknown ownership type.
     */
    readonly ownershipType: "FAMILY_SHARED" | "PURCHASED" | "UNKNOWN";
    /**
     * If entitlement verification was enabled, the result of that verification. If not, VerificationResult.NOT_REQUESTED
     */
    readonly verification: VERIFICATION_RESULT;
}

/**
 * Contains all the entitlements associated to the user.
 * @public
 */
export interface PurchasesEntitlementInfos {
    /**
     * Map of all EntitlementInfo (`PurchasesEntitlementInfo`) objects (active and inactive) keyed by entitlement identifier.
     */
    readonly all: { [key: string]: PurchasesEntitlementInfo };
    /**
     * Map of active EntitlementInfo (`PurchasesEntitlementInfo`) objects keyed by entitlement identifier.
     */
    readonly active: { [key: string]: PurchasesEntitlementInfo };
    /**
     * If entitlement verification was enabled, the result of that verification. If not, VerificationResult.NOT_REQUESTED
     */
    readonly verification: VERIFICATION_RESULT;
}

/**
 * Type containing all information regarding the customer
 * @public
 */
export interface CustomerInfo {
    /**
     * Entitlements attached to this customer info
     */
    readonly entitlements: PurchasesEntitlementInfos;
    /**
     * Set of active subscription skus
     */
    readonly activeSubscriptions: string[];
    /**
     * Set of purchased skus, active and inactive
     */
    readonly allPurchasedProductIdentifiers: string[];
    /**
     * The latest expiration date of all purchased skus
     */
    readonly latestExpirationDate: string | null;
    /**
     * The date this user was first seen in RevenueCat.
     */
    readonly firstSeen: string;
    /**
     * The original App User Id recorded for this user.
     */
    readonly originalAppUserId: string;
    /**
     * Date when this info was requested
     */
    readonly requestDate: string;
    /**
     * Map of skus to expiration dates
     */
    readonly allExpirationDates: { [key: string]: string | null };
    /**
     * Map of skus to purchase dates
     */
    readonly allPurchaseDates: { [key: string]: string | null };
    /**
     * Returns the version number for the version of the application when the
     * user bought the app. Use this for grandfathering users when migrating
     * to subscriptions.
     *
     * This corresponds to the value of CFBundleVersion (in iOS) in the
     * Info.plist file when the purchase was originally made. This is always null
     * in Android
     */
    readonly originalApplicationVersion: string | null;
    /**
     * Returns the purchase date for the version of the application when the user bought the app.
     * Use this for grandfathering users when migrating to subscriptions.
     */
    readonly originalPurchaseDate: string | null;
    /**
     * URL to manage the active subscription of the user. If this user has an active iOS
     * subscription, this will point to the App Store, if the user has an active Play Store subscription
     * it will point there. If there are no active subscriptions it will be null.
     * If there are multiple for different platforms, it will point to the device store.
     */
    readonly managementURL: string | null;
    /**
     * List of all non subscription transactions. Use this to fetch the history of
     * non-subscription purchases
     */
    readonly nonSubscriptionTransactions: PurchasesStoreTransaction[];
}

/**
 * Represents a non-subscription transaction in the Store.
 * @public
 */
export interface PurchasesStoreTransaction {
    /**
     * Id of the transaction.
     */
    transactionIdentifier: string;
    /**
     * Product Id associated with the transaction.
     */
    productIdentifier: string;
    /**
     * Purchase date of the transaction in ISO 8601 format.
     */
    purchaseDate: string;
}
