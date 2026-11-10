/**
 * A configured virtual currency reward, before an ad is watched or verified.
 * @public
 */
export interface VirtualCurrencyRewardConfiguration {
  readonly type: 'virtual_currency';
  readonly code: string;
  readonly amount: number;
}

/**
 * A configured entitlement reward. This describes a duration, not a grant expiration.
 * @public
 */
export interface EntitlementRewardConfiguration {
  readonly type: 'entitlement';
  readonly identifier: string;
  /** The configured entitlement duration in seconds. */
  readonly durationSeconds: number;
}

/**
 * A reward shape the native SDK does not currently model.
 * @public
 */
export interface UnsupportedAdRewardConfiguration {
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
  readonly reward: AdRewardConfiguration;
  readonly moreRewards: readonly AdRewardConfiguration[];
} | {
  readonly reward: null;
  readonly moreRewards: readonly [];
};
