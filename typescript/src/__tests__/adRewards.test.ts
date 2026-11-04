import { AdRewardConfiguration, ConfiguredAdRewards } from '../index';

describe('configured ad rewards contract', () => {
  it('distinguishes unavailable configuration from no configured reward', () => {
    const unavailable: ConfiguredAdRewards | null = null;
    const noReward: ConfiguredAdRewards = { reward: null, moreRewards: [] };

    expect(unavailable).toBeNull();
    expect(noReward).toEqual({ reward: null, moreRewards: [] });
  });

  it('preserves primary, additional order, duration seconds and unsupported rewards through JSON', () => {
    const currency: AdRewardConfiguration = { type: 'virtual_currency', code: 'GLD', amount: 100 };
    const entitlement: AdRewardConfiguration = { type: 'entitlement', identifier: 'premium', durationSeconds: 1.5 };
    const unsupported: AdRewardConfiguration = { type: 'unsupported_reward' };
    const configured: ConfiguredAdRewards = {
      reward: currency,
      moreRewards: [entitlement, unsupported, currency],
    };

    expect(JSON.parse(JSON.stringify(configured))).toEqual(configured);
    expect(configured.moreRewards.map(reward => reward.type))
      .toEqual(['entitlement', 'unsupported_reward', 'virtual_currency']);
  });

  it('rejects additional rewards without a primary reward', () => {
    const unsupported: AdRewardConfiguration = { type: 'unsupported_reward' };
    // @ts-expect-error Additional rewards require a primary reward.
    const invalid: ConfiguredAdRewards = { reward: null, moreRewards: [unsupported] };

    expect(invalid.reward).toBeNull();
  });
});
