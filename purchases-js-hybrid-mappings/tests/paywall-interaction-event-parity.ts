import type { PaywallInteractionEvent as PurchasesJsEvent } from '@revenuecat/purchases-js';
import type { PaywallInteractionEvent as HybridEvent } from '../../typescript/src/paywallInteractionEvent';

// The typescript package cannot depend on purchases-js, so it carries a copy of the purchases-js type.
// Mutual assignability ignores extra optional keys, so this uses conditional-type identity instead:
// https://github.com/microsoft/TypeScript/issues/27024#issuecomment-421529650
type Equals<A, B> =
  (<T>() => T extends A ? 1 : 2) extends <T>() => T extends B ? 1 : 2 ? true : false;
type Assert<T extends true> = T;

export type PaywallInteractionEventParity = Assert<Equals<PurchasesJsEvent, HybridEvent>>;
