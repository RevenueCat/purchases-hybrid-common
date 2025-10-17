import {
  CustomerInfo,
  EntitlementInfo,
  EntitlementInfos,
  NonSubscriptionTransaction,
  PeriodType,
  Store,
  SubscriptionInfo,
} from '@revenuecat/purchases-js';

export function mapCustomerInfo(customerInfo: CustomerInfo): Record<string, unknown> {
  const validDates = Object.values(customerInfo.allExpirationDatesByProduct).filter(
    (date): date is Date => date !== null,
  );
  const latestExpirationDate =
    validDates.length > 0 ? new Date(Math.max(...validDates.map(date => date.getTime()))) : null;

  return {
    entitlements: mapEntitlementInfos(customerInfo.entitlements),
    activeSubscriptions: Array.from(customerInfo.activeSubscriptions),
    allPurchasedProductIdentifiers: Object.keys(customerInfo.allPurchaseDatesByProduct),
    latestExpirationDate: latestExpirationDate ? latestExpirationDate.toISOString() : null,
    latestExpirationDateMillis: latestExpirationDate ? latestExpirationDate.getTime() : null,
    firstSeen: customerInfo.firstSeenDate.toISOString(),
    firstSeenMillis: customerInfo.firstSeenDate.getTime(),
    originalAppUserId: customerInfo.originalAppUserId,
    requestDate: customerInfo.requestDate.toISOString(),
    requestDateMillis: customerInfo.requestDate.getTime(),
    allExpirationDates: Object.fromEntries(
      Object.entries(customerInfo.allExpirationDatesByProduct).map(([key, value]) => [
        key,
        value ? value.toISOString() : null,
      ]),
    ),
    allExpirationDatesMillis: Object.fromEntries(
      Object.entries(customerInfo.allExpirationDatesByProduct).map(([key, value]) => [
        key,
        value ? value.getTime() : null,
      ]),
    ),
    allPurchaseDates: Object.fromEntries(
      Object.entries(customerInfo.allPurchaseDatesByProduct).map(([key, value]) => [
        key,
        value ? value.toISOString() : null,
      ]),
    ),
    allPurchaseDatesMillis: Object.fromEntries(
      Object.entries(customerInfo.allPurchaseDatesByProduct).map(([key, value]) => [
        key,
        value ? value.getTime() : null,
      ]),
    ),
    originalApplicationVersion: null,
    managementURL: customerInfo.managementURL,
    originalPurchaseDate: customerInfo.originalPurchaseDate
      ? customerInfo.originalPurchaseDate.toISOString()
      : null,
    originalPurchaseDateMillis: customerInfo.originalPurchaseDate
      ? customerInfo.originalPurchaseDate.getTime()
      : null,
    nonSubscriptionTransactions: mapNonSubscriptionTransactions(
      customerInfo.nonSubscriptionTransactions,
    ),
    subscriptionsByProductIdentifier: mapSubscriptionInfos(
      customerInfo.subscriptionsByProductIdentifier,
    ),
  };
}

function mapEntitlementInfos(entitlementInfos: EntitlementInfos): Record<string, unknown> {
  return {
    all: Object.fromEntries(
      Object.entries(entitlementInfos.all).map(([key, value]) => [key, mapEntitlementInfo(value)]),
    ),
    active: Object.fromEntries(
      Object.entries(entitlementInfos.active).map(([key, value]) => [
        key,
        mapEntitlementInfo(value),
      ]),
    ),
    verification: 'NOT_REQUESTED', // TODO: Trusted entitlements not available in JS SDK
  };
}

function mapEntitlementInfo(entitlementInfo: EntitlementInfo): Record<string, unknown> {
  return {
    identifier: entitlementInfo.identifier,
    isActive: entitlementInfo.isActive,
    willRenew: entitlementInfo.willRenew,
    periodType: mapPeriodType(entitlementInfo.periodType),
    latestPurchaseDate: entitlementInfo.latestPurchaseDate
      ? entitlementInfo.latestPurchaseDate.toISOString()
      : null,
    latestPurchaseDateMillis: entitlementInfo.latestPurchaseDate
      ? entitlementInfo.latestPurchaseDate.getTime()
      : null,
    originalPurchaseDate: entitlementInfo.originalPurchaseDate
      ? entitlementInfo.originalPurchaseDate.toISOString()
      : null,
    originalPurchaseDateMillis: entitlementInfo.originalPurchaseDate
      ? entitlementInfo.originalPurchaseDate.getTime()
      : null,
    expirationDate: entitlementInfo.expirationDate
      ? entitlementInfo.expirationDate.toISOString()
      : null,
    expirationDateMillis: entitlementInfo.expirationDate
      ? entitlementInfo.expirationDate.getTime()
      : null,
    store: mapStore(entitlementInfo.store),
    productIdentifier: entitlementInfo.productIdentifier,
    productPlanIdentifier: entitlementInfo.productPlanIdentifier,
    isSandbox: entitlementInfo.isSandbox,
    unsubscribeDetectedAt: entitlementInfo.unsubscribeDetectedAt
      ? entitlementInfo.unsubscribeDetectedAt.toISOString()
      : null,
    unsubscribeDetectedAtMillis: entitlementInfo.unsubscribeDetectedAt
      ? entitlementInfo.unsubscribeDetectedAt.getTime()
      : null,
    billingIssueDetectedAt: entitlementInfo.billingIssueDetectedAt
      ? entitlementInfo.billingIssueDetectedAt.toISOString()
      : null,
    billingIssueDetectedAtMillis: entitlementInfo.billingIssueDetectedAt
      ? entitlementInfo.billingIssueDetectedAt.getTime()
      : null,
    ownershipType: entitlementInfo.ownershipType,
    verification: 'NOT_REQUESTED', // TODO: Trusted entitlements not available in JS SDK
  };
}

function mapNonSubscriptionTransactions(
  nonSubscriptionTransactions: NonSubscriptionTransaction[],
): Record<string, unknown>[] {
  return nonSubscriptionTransactions.map(transaction => {
    return {
      transactionIdentifier: transaction.transactionIdentifier,
      revenueCatId: transaction.transactionIdentifier, // Deprecated: Use transactionIdentifier in this map instead
      productIdentifier: transaction.productIdentifier,
      productId: transaction.productIdentifier, // Deprecated: Use productIdentifier in this map instead
      purchaseDate: transaction.purchaseDate.toISOString(),
      purchaseDateMillis: transaction.purchaseDate.getTime(),
      store: mapStore(transaction.store),
    };
  });
}

function mapSubscriptionInfos(
  subscriptionsByProductIdentifier: Record<string, SubscriptionInfo>,
): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(subscriptionsByProductIdentifier).map(([productId, subscriptionInfo]) => [
      productId,
      {
        productIdentifier: subscriptionInfo.productIdentifier,
        purchaseDate: subscriptionInfo.purchaseDate.toISOString(),
        originalPurchaseDate: subscriptionInfo.originalPurchaseDate
          ? subscriptionInfo.originalPurchaseDate.toISOString()
          : null,
        expiresDate: subscriptionInfo.expiresDate
          ? subscriptionInfo.expiresDate.toISOString()
          : null,
        store: mapStore(subscriptionInfo.store),
        isSandbox: subscriptionInfo.isSandbox,
        unsubscribeDetectedAt: subscriptionInfo.unsubscribeDetectedAt
          ? subscriptionInfo.unsubscribeDetectedAt.toISOString()
          : null,
        billingIssuesDetectedAt: subscriptionInfo.billingIssuesDetectedAt
          ? subscriptionInfo.billingIssuesDetectedAt.toISOString()
          : null,
        gracePeriodExpiresDate: subscriptionInfo.gracePeriodExpiresDate
          ? subscriptionInfo.gracePeriodExpiresDate.toISOString()
          : null,
        ownershipType: subscriptionInfo.ownershipType,
        periodType: mapPeriodType(subscriptionInfo.periodType),
        refundedAt: subscriptionInfo.refundedAt ? subscriptionInfo.refundedAt.toISOString() : null,
        storeTransactionId: subscriptionInfo.storeTransactionId,
        isActive: subscriptionInfo.isActive,
        willRenew: subscriptionInfo.willRenew,
      },
    ]),
  );
}

function mapStore(store: Store): string {
  switch (store) {
    case 'app_store':
      return 'APP_STORE';
    case 'mac_app_store':
      return 'MAC_APP_STORE';
    case 'play_store':
      return 'PLAY_STORE';
    case 'stripe':
      return 'STRIPE';
    case 'promotional':
      return 'PROMOTIONAL';
    case 'amazon':
      return 'AMAZON';
    case 'rc_billing':
      return 'RC_BILLING';
    case 'paddle':
      return 'PADDLE';
    case 'test_store':
      return 'TEST_STORE';
    case 'unknown':
      return 'UNKNOWN';
  }
}

function mapPeriodType(periodType: PeriodType): string {
  switch (periodType) {
    case 'normal':
      return 'NORMAL';
    case 'prepaid':
      return 'PREPAID';
    case 'trial':
      return 'TRIAL';
    case 'intro':
      return 'INTRO';
  }
}
