import {
  CustomerInfo,
  EntitlementInfo,
  EntitlementInfos,
  NonSubscriptionTransaction,
  SubscriptionInfo
} from "@revenuecat/purchases-js";
import { mapCustomerInfo } from "../../src/mappers/customer_info_mapper";

describe('mapCustomerInfo', () => {
  const mockDate = new Date('2024-01-01T12:00:00Z');

  it('maps empty CustomerInfo correctly', () => {
    const emptyCustomerInfo: CustomerInfo = {
      entitlements: {
        all: {},
        active: {}
      },
      activeSubscriptions: new Set(),
      allPurchaseDatesByProduct: {},
      allExpirationDatesByProduct: {},
      firstSeenDate: mockDate,
      originalAppUserId: 'user_123',
      requestDate: mockDate,
      managementURL: null,
      originalPurchaseDate: null,
      nonSubscriptionTransactions: [],
      subscriptionsByProductIdentifier: {}
    };

    const result = mapCustomerInfo(emptyCustomerInfo);

    expect(result).toEqual({
      entitlements: {
        all: {},
        active: {},
        verification: 'NOT_REQUESTED'
      },
      activeSubscriptions: [],
      allPurchasedProductIdentifiers: [],
      latestExpirationDate: null,
      latestExpirationDateMillis: null,
      firstSeen: mockDate.toISOString(),
      firstSeenMillis: mockDate.getTime(),
      originalAppUserId: 'user_123',
      requestDate: mockDate.toISOString(),
      requestDateMillis: mockDate.getTime(),
      allExpirationDates: {},
      allExpirationDatesMillis: {},
      allPurchaseDates: {},
      allPurchaseDatesMillis: {},
      originalApplicationVersion: null,
      managementURL: null,
      originalPurchaseDate: null,
      originalPurchaseDateMillis: null,
      nonSubscriptionTransactions: [],
      subscriptionsByProductIdentifier: {}
    });
  });

  it('maps CustomerInfo with subs and non subs purchases correctly', () => {
    const purchaseDate = new Date('2024-01-15T12:00:00Z');
    const expirationDate = new Date('2024-02-15T12:00:00Z');

    const entitlementInfo: EntitlementInfo = {
      identifier: 'premium',
      isActive: true,
      willRenew: true,
      periodType: 'normal',
      latestPurchaseDate: purchaseDate,
      originalPurchaseDate: purchaseDate,
      expirationDate: expirationDate,
      store: 'app_store',
      productIdentifier: 'com.test.premium',
      productPlanIdentifier: 'plan_123',
      isSandbox: false,
      unsubscribeDetectedAt: null,
      billingIssueDetectedAt: null,
      ownershipType: 'PURCHASED'
    };

    const entitlements: EntitlementInfos = {
      all: { premium: entitlementInfo },
      active: { premium: entitlementInfo }
    };

    const subscriptionInfo: SubscriptionInfo = {
      productIdentifier: 'com.test.premium',
      purchaseDate: purchaseDate,
      originalPurchaseDate: purchaseDate,
      expiresDate: expirationDate,
      store: 'app_store',
      isSandbox: false,
      unsubscribeDetectedAt: null,
      billingIssuesDetectedAt: null,
      gracePeriodExpiresDate: null,
      ownershipType: 'PURCHASED',
      periodType: 'normal',
      refundedAt: null,
      storeTransactionId: 'transaction_123',
      isActive: true,
      willRenew: true
    };

    const nonSubscriptionTransaction: NonSubscriptionTransaction = {
      transactionIdentifier: 'transaction_456',
      productIdentifier: 'com.test.consumable',
      purchaseDate: purchaseDate,
      store: 'app_store',
      storeTransactionId: 'transaction_456'
    };

    const customerInfo: CustomerInfo = {
      entitlements,
      activeSubscriptions: new Set(['com.test.premium']),
      allPurchaseDatesByProduct: {
        'com.test.premium': purchaseDate,
        'com.test.consumable': purchaseDate
      },
      allExpirationDatesByProduct: {
        'com.test.premium': expirationDate
      },
      firstSeenDate: mockDate,
      originalAppUserId: 'user_123',
      requestDate: mockDate,
      managementURL: 'https://management.url',
      originalPurchaseDate: purchaseDate,
      nonSubscriptionTransactions: [nonSubscriptionTransaction],
      subscriptionsByProductIdentifier: {
        'com.test.premium': subscriptionInfo
      }
    };

    const result = mapCustomerInfo(customerInfo);

    expect(result).toEqual({
      entitlements: {
        all: {
          premium: {
            identifier: 'premium',
            isActive: true,
            willRenew: true,
            periodType: 'NORMAL',
            latestPurchaseDate: purchaseDate.toISOString(),
            latestPurchaseDateMillis: purchaseDate.getTime(),
            originalPurchaseDate: purchaseDate.toISOString(),
            originalPurchaseDateMillis: purchaseDate.getTime(),
            expirationDate: expirationDate.toISOString(),
            expirationDateMillis: expirationDate.getTime(),
            store: 'APP_STORE',
            productIdentifier: 'com.test.premium',
            productPlanIdentifier: 'plan_123',
            isSandbox: false,
            unsubscribeDetectedAt: null,
            unsubscribeDetectedAtMillis: null,
            billingIssueDetectedAt: null,
            billingIssueDetectedAtMillis: null,
            ownershipType: 'PURCHASED',
            verification: 'NOT_REQUESTED'
          }
        },
        active: {
          premium: {
            identifier: 'premium',
            isActive: true,
            willRenew: true,
            periodType: 'NORMAL',
            latestPurchaseDate: purchaseDate.toISOString(),
            latestPurchaseDateMillis: purchaseDate.getTime(),
            originalPurchaseDate: purchaseDate.toISOString(),
            originalPurchaseDateMillis: purchaseDate.getTime(),
            expirationDate: expirationDate.toISOString(),
            expirationDateMillis: expirationDate.getTime(),
            store: 'APP_STORE',
            productIdentifier: 'com.test.premium',
            productPlanIdentifier: 'plan_123',
            isSandbox: false,
            unsubscribeDetectedAt: null,
            unsubscribeDetectedAtMillis: null,
            billingIssueDetectedAt: null,
            billingIssueDetectedAtMillis: null,
            ownershipType: 'PURCHASED',
            verification: 'NOT_REQUESTED'
          }
        },
        verification: 'NOT_REQUESTED'
      },
      activeSubscriptions: ['com.test.premium'],
      allPurchasedProductIdentifiers: ['com.test.premium', 'com.test.consumable'],
      latestExpirationDate: expirationDate.toISOString(),
      latestExpirationDateMillis: expirationDate.getTime(),
      firstSeen: mockDate.toISOString(),
      firstSeenMillis: mockDate.getTime(),
      originalAppUserId: 'user_123',
      requestDate: mockDate.toISOString(),
      requestDateMillis: mockDate.getTime(),
      allExpirationDates: {
        'com.test.premium': expirationDate.toISOString()
      },
      allExpirationDatesMillis: {
        'com.test.premium': expirationDate.getTime()
      },
      allPurchaseDates: {
        'com.test.premium': purchaseDate.toISOString(),
        'com.test.consumable': purchaseDate.toISOString()
      },
      allPurchaseDatesMillis: {
        'com.test.premium': purchaseDate.getTime(),
        'com.test.consumable': purchaseDate.getTime()
      },
      originalApplicationVersion: null,
      managementURL: 'https://management.url',
      originalPurchaseDate: purchaseDate.toISOString(),
      originalPurchaseDateMillis: purchaseDate.getTime(),
      nonSubscriptionTransactions: [{
        transactionIdentifier: 'transaction_456',
        revenueCatId: 'transaction_456',
        productIdentifier: 'com.test.consumable',
        productId: 'com.test.consumable',
        purchaseDate: purchaseDate.toISOString(),
        purchaseDateMillis: purchaseDate.getTime(),
        store: 'APP_STORE'
      }],
      subscriptionsByProductIdentifier: {
        'com.test.premium': {
          productIdentifier: 'com.test.premium',
          purchaseDate: purchaseDate.toISOString(),
          originalPurchaseDate: purchaseDate.toISOString(),
          expiresDate: expirationDate.toISOString(),
          store: 'APP_STORE',
          isSandbox: false,
          unsubscribeDetectedAt: null,
          billingIssuesDetectedAt: null,
          gracePeriodExpiresDate: null,
          ownershipType: 'PURCHASED',
          periodType: 'NORMAL',
          refundedAt: null,
          storeTransactionId: 'transaction_123',
          isActive: true,
          willRenew: true
        }
      }
    });
  });
});
