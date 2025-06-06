import { PurchasesError } from '@revenuecat/purchases-js';

export function mapPurchasesError(error: PurchasesError): Record<string, unknown> {
  return {
    code: error.errorCode,
    message: error.message,
    underlyingErrorMessage: error.underlyingErrorMessage,
    info: {
      statusCode: error.extra?.statusCode,
      backendErrorCode: error.extra?.backendErrorCode,
    },
  };
}
