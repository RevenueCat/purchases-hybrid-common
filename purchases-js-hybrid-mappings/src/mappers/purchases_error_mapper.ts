import { ErrorCode, PurchasesError } from '@revenuecat/purchases-js';

export function mapPurchasesError(error: PurchasesError): Record<string, unknown> {
  const userCancelled = error.errorCode === ErrorCode.UserCancelledError;
  const message = error.message || (userCancelled ? 'Purchase was cancelled.' : 'Unknown error.');

  return {
    code: userCancelled ? String(error.errorCode) : error.errorCode,
    message,
    underlyingErrorMessage: error.underlyingErrorMessage,
    userCancelled,
    info: {
      statusCode: error.extra?.statusCode,
      backendErrorCode: error.extra?.backendErrorCode,
    },
  };
}
