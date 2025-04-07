import { PurchasesError, ErrorCode } from "@revenuecat/purchases-js";
import { mapPurchasesError } from "../../src/mappers/purchases_error_mapper.ts";

describe('mapPurchasesError', () => {
  it('maps PurchasesError correctly', () => {
    const error: PurchasesError = {
      name: "PurchasesError",
      message: "Something went wrong",
      underlyingErrorMessage: "Network error",
      errorCode: ErrorCode.NetworkError,
      extra: {
        statusCode: 500,
        backendErrorCode: 7000
      }
    };

    const result = mapPurchasesError(error);

    expect(result).toEqual({
      code: error.errorCode,
      message: error.message,
      underlyingErrorMessage: error.underlyingErrorMessage,
      info: {
        statusCode: error.extra?.statusCode,
        backendErrorCode: error.extra?.backendErrorCode
      }
    });
  });
});
