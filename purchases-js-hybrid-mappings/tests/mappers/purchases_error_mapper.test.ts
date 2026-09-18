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
      code: String(error.errorCode),
      message: error.message,
      underlyingErrorMessage: error.underlyingErrorMessage,
      userCancelled: false,
      info: {
        statusCode: error.extra?.statusCode,
        backendErrorCode: error.extra?.backendErrorCode
      }
    });
  });

  it.each([
    [ErrorCode.CustomerInfoError, "29"],
    [ErrorCode.SignatureVerificationError, "37"],
    [ErrorCode.InvalidEmailError, "43"],
    [ErrorCode.NetworkError, "10"],
  ])('maps purchases-js code %s to the code shared by the other SDKs', (errorCode, expected) => {
    expect(mapPurchasesError(new PurchasesError(errorCode)).code).toBe(expected);
  });

  it('maps cancelled errors to hybrid-compatible shape', () => {
    const error = new PurchasesError(ErrorCode.UserCancelledError);

    const result = mapPurchasesError(error);

    expect(result).toEqual({
      code: "1",
      message: "Purchase was cancelled.",
      underlyingErrorMessage: "",
      userCancelled: true,
      info: {
        statusCode: undefined,
        backendErrorCode: undefined
      }
    });
  });
});
