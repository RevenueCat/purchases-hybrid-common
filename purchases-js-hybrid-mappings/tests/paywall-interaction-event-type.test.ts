import { PAYWALL_COMPONENT_TYPES as PURCHASES_JS_COMPONENT_TYPES } from '@revenuecat/purchases-js';
import { PAYWALL_COMPONENT_TYPES as HYBRID_COMPONENT_TYPES } from '../../typescript/src/paywallInteractionEvent';

describe('PAYWALL_COMPONENT_TYPES in the typescript package', () => {
  it('lists the same component types as purchases-js', () => {
    expect(HYBRID_COMPONENT_TYPES).toEqual(PURCHASES_JS_COMPONENT_TYPES);
  });
});
