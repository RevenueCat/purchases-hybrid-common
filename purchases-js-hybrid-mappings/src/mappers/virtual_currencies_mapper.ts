import { VirtualCurrencies, VirtualCurrency } from '@revenuecat/purchases-js';

export function mapVirtualCurrencies(
  virtualCurrencies: VirtualCurrencies,
): Record<string, unknown> {
  return {
    all: Object.fromEntries(
      Object.entries(virtualCurrencies.all).map(([key, value]) => [key, mapVirtualCurrency(value)]),
    ),
  };
}

function mapVirtualCurrency(virtualCurrency: VirtualCurrency): Record<string, unknown> {
  return {
    balance: virtualCurrency.balance,
    name: virtualCurrency.name,
    code: virtualCurrency.code,
    serverDescription: virtualCurrency.serverDescription,
  };
}
