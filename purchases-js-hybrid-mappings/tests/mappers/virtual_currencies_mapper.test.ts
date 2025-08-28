import {
  VirtualCurrencies,
} from "@revenuecat/purchases-js";
import { mapVirtualCurrencies } from "../../src/mappers/virtual_currencies_mapper";

describe('mapVirtualCurrencies', () => {
  it('maps empty VirtualCurrencies correctly', () => {
    const emptyVirtualCurrencies: VirtualCurrencies = {
      all: {},
    };

    const result = mapVirtualCurrencies(emptyVirtualCurrencies);

    expect(result).toEqual({
      all: {},
    });
  });

  it('maps VirtualCurrencies with one virtual currency correctly', () => {
    const balance = 100;
    const name = 'Gold';
    const code = 'GOLD';
    const serverDescription = 'It\'s gold';

    const virtualCurrencies: VirtualCurrencies = {
      all: {
        [code]: {
          balance: balance,
          name: name,
          code: code,
          serverDescription: serverDescription,
        },
      },
    };

    const result = mapVirtualCurrencies(virtualCurrencies);

    expect(result).toEqual({
      all: {
        [code]: {
          balance: balance,
          name: name,
          code: code,
          serverDescription: serverDescription,
        },
      },
    });
  });

  it('maps VirtualCurrencies with one virtual currency with null serverDescription correctly', () => {
    const balance = 100;
    const name = 'Gold';
    const code = 'GOLD';
    const serverDescription = null

    const virtualCurrencies: VirtualCurrencies = {
      all: {
        [code]: {
          balance: balance,
          name: name,
          code: code,
          serverDescription: serverDescription,
        },
      },
    };

    const result = mapVirtualCurrencies(virtualCurrencies);

    expect(result).toEqual({
      all: {
        [code]: {
          balance: balance,
          name: name,
          code: code,
          serverDescription: serverDescription,
        },
      },
    });
  });

  it('maps VirtualCurrencies with one virtual currency with a negative balance correctly', () => {
    const balance = -100;
    const name = 'Gold';
    const code = 'GOLD';
    const serverDescription = 'It\'s gold';
    
    const virtualCurrencies: VirtualCurrencies = {
      all: {
        [code]: {
          balance: balance,
          name: name,
          code: code,
          serverDescription: serverDescription,
        },
      },
    };

    const result = mapVirtualCurrencies(virtualCurrencies);

    expect(result).toEqual({
      all: {
        [code]: {
          balance: balance,
          name: name,
          code: code,
          serverDescription: serverDescription,
        },
      },
    });
  });

  it('maps VirtualCurrencies with multiple virtual currencies correctly', () => {
    const balance1 = 100;
    const name1 = 'Gold';
    const code1 = 'GOLD';
    const serverDescription1 = null

    const balance2 = 200;
    const name2 = 'Silver';
    const code2 = 'SILVER';
    const serverDescription2 = 'It\'s silver';
    
    const virtualCurrencies: VirtualCurrencies = {
      all: {
        [code1]: {
          balance: balance1,
          name: name1,
          code: code1,
          serverDescription: serverDescription1,
        },
        [code2]: {
          balance: balance2,
          name: name2,
          code: code2,
          serverDescription: serverDescription2,
        },
      },
    };

    const result = mapVirtualCurrencies(virtualCurrencies);

    expect(result).toEqual({
      all: {
        [code1]: {
          balance: balance1,
          name: name1,
          code: code1,
          serverDescription: serverDescription1,
        },
        [code2]: {
          balance: balance2,
          name: name2,
          code: code2,
          serverDescription: serverDescription2,
        },
      },
    });
  });
});
