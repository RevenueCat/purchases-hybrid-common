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
      userCancelled: false,
      info: {
        statusCode: error.extra?.statusCode,
        backendErrorCode: error.extra?.backendErrorCode
      }
    });
  });

  it('maps cancelled errors to hybrid-compatible shape', () => {
    const error = new PurchasesError(ErrorCode.UserCancelledError);

    const result = mapPurchasesError(error);

    expect(result).toEqual({
      code: "1",
      message: "Purchase was cancelled.",
      underlyingErrorMessage: undefined,
      userCancelled: true,
      info: {
        statusCode: undefined,
        backendErrorCode: undefined
      }
    });
  });
});
