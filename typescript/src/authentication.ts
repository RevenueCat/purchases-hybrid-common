import { PurchasesError } from "./errors";

/**
 * The identity providers accepted by IAM login.
 *
 * @experimental This API is experimental and may be changed or removed in a future release.
 * @public
 */
export enum IDENTITY_SOURCE {
  /**
   * Sign in with Apple.
   */
  SIGN_IN_WITH_APPLE = "apple",

  /**
   * A generic OpenID Connect provider.
   */
  OIDC = "oidc",

  /**
   * Google Sign-In.
   */
  GOOGLE = "google",

  /**
   * Firebase Authentication.
   */
  FIREBASE = "firebase",

  /**
   * Facebook Login. Android-only for now: iOS returns an `UNSUPPORTED_ERROR`.
   */
  FACEBOOK = "facebook",
}

/**
 * An identity from an external provider, to log in with through IAM. Requires configuring the SDK
 * with `iamEnabled`.
 *
 * @experimental This API is experimental and may be changed or removed in a future release.
 * @public
 */
export interface IdentityCredential {
  /**
   * The provider the user signed in with.
   */
  source: IDENTITY_SOURCE;

  /**
   * The raw ID token the provider returned.
   */
  token: string;

  /**
   * The user's email, for {@link IDENTITY_SOURCE.FACEBOOK} only, if the app was granted the `email`
   * permission.
   */
  email?: string;
}

/**
 * Hears about IAM authentication errors that no explicit call reports, such as a failed token
 * refresh. After one, treat every access token received so far as invalid.
 *
 * @experimental This API is experimental and may be changed or removed in a future release.
 * @public
 */
export type AuthenticationErrorListener = (error: PurchasesError) => void;

/**
 * Hears about changes to the current user's IAM access token: a new one after login or refresh, or
 * `null` once cleared.
 *
 * @experimental This API is experimental and may be changed or removed in a future release.
 * @public
 */
export type AccessTokenUpdatedListener = (accessToken: string | null) => void;
