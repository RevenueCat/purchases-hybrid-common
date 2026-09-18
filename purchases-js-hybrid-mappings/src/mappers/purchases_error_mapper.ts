import { ErrorCode, PurchasesError } from '@revenuecat/purchases-js';
import { JS_TO_HYBRID_ERROR_CODE } from '../generated/js-error-codes';

export function mapPurchasesError(error: PurchasesError): Record<string, unknown> {
  const userCancelled = error.errorCode === ErrorCode.UserCancelledError;
  const message = error.message || (userCancelled ? 'Purchase was cancelled.' : 'Unknown error.');

  return {
    code: JS_TO_HYBRID_ERROR_CODE[error.errorCode],
    message,
    underlyingErrorMessage: error.underlyingErrorMessage ?? '',
    userCancelled,
    info: {
      statusCode: error.extra?.statusCode,
      backendErrorCode: error.extra?.backendErrorCode,
    },
  };
}
