import { VERIFICATION_RESULT } from "./enums";


/**
 * The supported stores for purchases.
 * @public
 */
export type Store = "PLAY_STORE" | "APP_STORE" | "STRIPE" | "MAC_APP_STORE" | "PROMOTIONAL" | "AMAZON" | "RC_BILLING" | "EXTERNAL" | "PADDLE" | "TEST_STORE" | "UNKNOWN_STORE";

/**
 * The supported ownership types for an entitlement.
 * @public
 */
export type OwnershipType = "PURCHASED" | "FAMILY_SHARED" | "UNKNOWN";

/**
 * The supported period types for an entitlement.
 * @public
 */
export type PeriodType = "NORMAL" | "INTRO" | "TRIAL" | "PREPAID";

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
    readonly store: Store;
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
    readonly ownershipType: OwnershipType;
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

    /**
     * Information about the customer's subscriptions for each product identifier.
     */
    readonly subscriptionsByProductIdentifier: { [key: string]: PurchasesSubscriptionInfo };
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

/**
 * Subscription purchases of the Customer.
 * @public
 */
export interface PurchasesSubscriptionInfo {
    /**
     * The product identifier.
     */
    readonly productIdentifier: string;
    /**
     * Date when the last subscription period started.
     */
    readonly purchaseDate: string;
    /**
     * Date when this subscription first started. This property does not update with renewals.
     * This property also does not update for product changes within a subscription group or
     * re-subscriptions by lapsed subscribers.
     */
    readonly originalPurchaseDate: string | null;
    /**
     * Date when the subscription expires/expired
     */
    readonly expiresDate: string | null;
    /**
     * Store where the subscription was purchased.
     */
    readonly store: Store;
    /**
     * Date when RevenueCat detected that auto-renewal was turned off for this subscription.
     * Note the subscription may still be active, check the `expiresDate` attribute.
     */
    readonly unsubscribeDetectedAt: string | null;
    /**
     * Whether or not the purchase was made in sandbox mode.
     */
    readonly isSandbox: boolean;
    /**
     * Date when RevenueCat detected any billing issues with this subscription.
     * If and when the billing issue gets resolved, this field is set to nil.
     */
    readonly billingIssuesDetectedAt: string | null;
    /**
     * Date when any grace period for this subscription expires/expired.
     * nil if the customer has never been in a grace period.
     */
    readonly gracePeriodExpiresDate: string | null;
    /**
     * How the Customer received access to this subscription:
     * - [OwnershipType.PURCHASED]: The customer bought the subscription.
     * - [OwnershipType.FAMILY_SHARED]: The Customer has access to the product via their family.
     */
    readonly ownershipType: OwnershipType;
    /**
     * Type of the current subscription period:
     * - [PeriodType.NORMAL]: The product is in a normal period (default)
     * - [PeriodType.TRIAL]: The product is in a free trial period
     * - [PeriodType.INTRO]: The product is in an introductory pricing period
     * - [PeriodType.PREPAID]: The product is in a prepaid pricing period
     */
    readonly periodType: PeriodType;
    /**
     * Date when RevenueCat detected a refund of this subscription.
     */
    readonly refundedAt: string | null;
    /**
     * The transaction id in the store of the subscription.
     */
    readonly storeTransactionId: string | null;
    /**
     * Whether the subscription is currently active.
     */
    readonly isActive: boolean;
    /**
     * Whether the subscription will renew at the next billing period.
     */
    readonly willRenew: boolean;
}
