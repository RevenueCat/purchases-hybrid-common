import { PurchaseResult } from '@revenuecat/purchases-js';
import { mapCustomerInfo } from './customer_info_mapper';

export function mapPurchaseResult(purchaseResult: PurchaseResult): Record<string, unknown> {
  return {
    customerInfo: mapCustomerInfo(purchaseResult.customerInfo),
    redemptionInfo: purchaseResult.redemptionInfo,
    operationSessionId: purchaseResult.operationSessionId,
    transaction: {
      transactionIdentifier: purchaseResult.storeTransaction.storeTransactionId,
      productIdentifier: purchaseResult.storeTransaction.productIdentifier,
      purchaseDate: purchaseResult.storeTransaction.purchaseDate.toISOString(),
      purchaseDateMillis: purchaseResult.storeTransaction.purchaseDate.getTime(),
    },
    productIdentifier: purchaseResult.storeTransaction.productIdentifier,
  };
}
