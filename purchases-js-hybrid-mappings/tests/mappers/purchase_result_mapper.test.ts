import {CustomerInfo, PurchaseResult, StoreTransaction} from '@revenuecat/purchases-js';
import { mapPurchaseResult } from '../../src/mappers/purchase_result_mapper';

describe('mapPurchaseResult', () => {
  it('maps PurchaseResult correctly', () => {
    const mockDate = new Date('2024-01-01T12:00:00Z');

    const customerInfo: CustomerInfo = {
      entitlements: {
        all: {},
        active: {},
      },
      activeSubscriptions: new Set(),
      allPurchaseDatesByProduct: {},
      allExpirationDatesByProduct: {},
      firstSeenDate: mockDate,
      originalAppUserId: 'user_123',
      requestDate: mockDate,
      managementURL: 'https://management.url',
      originalPurchaseDate: null,
      nonSubscriptionTransactions: [],
      subscriptionsByProductIdentifier: {},
    };

    const transaction: StoreTransaction = {
      storeTransactionId: 'test-transaction-id',
      productIdentifier: 'test-product-id',
      purchaseDate: mockDate,
    };

    const purchaseResult: PurchaseResult = {
      customerInfo,
      redemptionInfo: { redeemUrl: "https://redeem.url" },
      operationSessionId: 'session_123',
      storeTransaction: transaction,
    };

    const result = mapPurchaseResult(purchaseResult);

    expect(result).toEqual({
      customerInfo: {
        entitlements: {
          all: {},
          active: {},
          verification: 'NOT_REQUESTED',
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
        managementURL: 'https://management.url',
        originalPurchaseDate: null,
        originalPurchaseDateMillis: null,
        nonSubscriptionTransactions: [],
        subscriptionsByProductIdentifier: {},
      },
      redemptionInfo: { redeemUrl: "https://redeem.url" },
      operationSessionId: 'session_123',
      transaction: {
        transactionIdentifier: 'test-transaction-id',
        productIdentifier: 'test-product-id',
        purchaseDate: mockDate.toISOString(),
        purchaseDateMillis: mockDate.getTime(),
      },
      productIdentifier: 'test-product-id',
    });
  });
});
