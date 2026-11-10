/**
 * A configured virtual currency reward, before an ad is watched or verified.
 * @public
 */
export interface VirtualCurrencyRewardConfiguration {
  /** Identifies a virtual currency reward. */
  readonly type: 'virtual_currency';
  /** The virtual currency code defined in the RevenueCat dashboard. */
  readonly code: string;
  /** The positive integer amount configured to be granted. */
  readonly amount: number;
}

/**
 * A configured entitlement reward. This describes a duration, not a grant expiration.
 * @public
 */
export interface EntitlementRewardConfiguration {
  /** Identifies an entitlement reward. */
  readonly type: 'entitlement';
  /** The entitlement identifier defined in the RevenueCat dashboard. */
  readonly identifier: string;
  /** The configured entitlement duration in seconds. */
  readonly durationSeconds: number;
}

/**
 * A reward shape the native SDK does not currently model.
 * @public
 */
export interface UnsupportedAdRewardConfiguration {
  /** Identifies a reward the native SDK cannot represent. */
  readonly type: 'unsupported_reward';
}

/**
 * A configured reward, separate from the authoritative reward granted after verification.
 * Unknown native reward types are preserved as unsupported_reward.
 * @public
 */
export type AdRewardConfiguration = VirtualCurrencyRewardConfiguration
  | EntitlementRewardConfiguration
  | UnsupportedAdRewardConfiguration;

/**
 * Successfully resolved rewards for an exact, case-sensitive ad unit ID.
 * A null accessor result means configuration is unavailable or malformed, or the ad unit ID is empty.
 * A null primary reward with an empty moreRewards array means no reward is configured.
 * Additional rewards retain their configured order.
 * @public
 */
export type ConfiguredAdRewards = {
  /** The primary configured reward. */
  readonly reward: AdRewardConfiguration;
  /** Additional rewards configured alongside the primary reward, in their configured order. */
  readonly moreRewards: readonly AdRewardConfiguration[];
} | {
  /** No primary reward is configured for the ad unit. */
  readonly reward: null;
  /** Empty when no reward is configured. */
  readonly moreRewards: readonly [];
};
