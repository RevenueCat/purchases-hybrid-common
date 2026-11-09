/**
 * A subscriber attribute of the current user.
 *
 * @experimental This API is experimental and may be changed or removed in a future release.
 * @public
 */
export interface CustomerAttribute {
  /**
   * The attribute's key. Keys that begin with `$` are reserved by RevenueCat.
   */
  readonly key: string;

  /**
   * The attribute's value.
   */
  readonly value: string;

  /**
   * When the value was last modified, as an ISO 8601 date string.
   */
  readonly lastUpdatedDate: string;
}
