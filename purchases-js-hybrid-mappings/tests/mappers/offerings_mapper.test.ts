import {
  Offering,
  Offerings,
  Package,
  PackageType,
  Period,
  PeriodUnit,
  PresentedOfferingContext,
  Price,
  PricingPhase,
  Product,
  ProductType,
  SubscriptionOption
} from "@revenuecat/purchases-js";
import {mapOfferings} from "../../src/mappers/offerings_mapper";

describe('mapOfferings', () => {
  it('maps Offerings with minimum required properties correctly', () => {
    const minimalOffering: Offering = {
      identifier: 'basic_offering',
      serverDescription: 'Basic offering description',
      metadata: { key: 'value' },
      availablePackages: [],
      lifetime: null,
      annual: null,
      sixMonth: null,
      threeMonth: null,
      twoMonth: null,
      monthly: null,
      weekly: null,
      packagesById: {},
      paywall_components: null,
    };

    const minimalOfferings: Offerings = {
      all: {
        'basic_offering': minimalOffering
      },
      current: minimalOffering,
    };

    const result = mapOfferings(minimalOfferings);

    const expectedOffering = {
      identifier: 'basic_offering',
      serverDescription: 'Basic offering description',
      metadata: { key: 'value' },
      availablePackages: [],
      lifetime: null,
      annual: null,
      sixMonth: null,
      threeMonth: null,
      twoMonth: null,
      monthly: null,
      weekly: null,
    };

    expect(result).toEqual({
      all: {
        'basic_offering': expectedOffering,
      },
      current: expectedOffering,
    });
  });

  it('maps Offerings with more complete data correctly', () => {
    const lifetimePackage = createPackage('lifetime_pkg', 'premium_offering', PackageType.Lifetime);
    const annualPackage = createPackage('annual_pkg', 'premium_offering', PackageType.Annual);
    const monthlyPackage = createPackage('monthly_pkg', 'premium_offering', PackageType.Monthly);
    const weeklyPackage = createPackage('weekly_pkg', 'premium_offering', PackageType.Weekly);
    const fullOffering: Offering = {
      identifier: 'premium_offering',
      serverDescription: 'Premium offering description',
      metadata: { tier: 'premium', featured: true },
      availablePackages: [
        annualPackage,
        monthlyPackage,
        weeklyPackage,
        lifetimePackage
      ],
      lifetime: lifetimePackage,
      annual: annualPackage,
      sixMonth: null,
      threeMonth: null,
      twoMonth: null,
      monthly: monthlyPackage,
      weekly: weeklyPackage,
      packagesById: {},
      paywall_components: null
    };

    const fullOfferings: Offerings = {
      all: {
        'premium_offering': fullOffering
      },
      current: fullOffering
    };

    const result = mapOfferings(fullOfferings);

    const expectedOffering = {
        identifier: 'premium_offering',
        serverDescription: 'Premium offering description',
        metadata: { tier: 'premium', featured: true },
        availablePackages: expect.arrayContaining([
            expect.objectContaining({ identifier: 'annual_pkg' }),
            expect.objectContaining({ identifier: 'monthly_pkg' }),
            expect.objectContaining({ identifier: 'weekly_pkg' }),
            expect.objectContaining({ identifier: 'lifetime_pkg' })
        ]),
        lifetime: expect.objectContaining({ identifier: 'lifetime_pkg' }),
        annual: expect.objectContaining({ identifier: 'annual_pkg' }),
        sixMonth: expect.objectContaining({ identifier: 'six_month_pkg' }),
        threeMonth: expect.objectContaining({ identifier: 'three_month_pkg' }),
        twoMonth: expect.objectContaining({ identifier: 'two_month_pkg' }),
        monthly: expect.objectContaining({ identifier: 'monthly_pkg' }),
        weekly: expect.objectContaining({ identifier: 'weekly_pkg' })
    }

    expect(result).toEqual({
      all: {
        'premium_offering': expectedOffering,
      },
      current: expectedOffering,
    });
  });

  function createPackage(identifier: string, offeringId: string, packageType: PackageType): Package {
    const presentedOfferingContext: PresentedOfferingContext = {
      offeringIdentifier: offeringId,
      placementIdentifier: 'main_page',
      targetingContext: {
        revision: 1,
        ruleId: 'rule_123'
      }
    };

    const price: Price = {
      amount: 499,
      amountMicros: 4990000,
      currency: 'USD',
      formattedPrice: '$4.99'
    };

    const trialPrice: Price = {
      amount: 0,
      amountMicros: 0,
      currency: 'USD',
      formattedPrice: 'Free'
    };

    const isSubscription = packageType !== PackageType.Lifetime;

    const monthlyPeriod: Period = { unit: PeriodUnit.Month, number: 1 };

    const period: Period = packageType === PackageType.Annual
      ? { unit: PeriodUnit.Year, number: 1 }
      : packageType === PackageType.Monthly
        ? monthlyPeriod
        : packageType === PackageType.Weekly
          ? { unit: PeriodUnit.Week, number: 1 }
          : monthlyPeriod;

    const periodDuration = packageType === PackageType.Annual ?
      'P1Y' : PackageType.Monthly ?
        'P1M' : PackageType.Weekly ?
          'P1W' : 'P1M';

    const basePricingPhase: PricingPhase = {
      price: price,
      period: period,
      periodDuration: periodDuration,
      cycleCount: 0,
      pricePerMonth: period.unit === PeriodUnit.Year ?
        { amount: 4158, amountMicros: 415833, currency: 'USD', formattedPrice: '$0.42' } : price,
      pricePerYear: period.unit === PeriodUnit.Month || period.unit === PeriodUnit.Week ?
        { amount: 5988, amountMicros: 59880000, currency: 'USD', formattedPrice: '$59.88' } : price,
      pricePerWeek: {
        amount: period.unit === PeriodUnit.Month ? 1.15 : 0.10,
        amountMicros: period.unit === PeriodUnit.Month ? 1151538 : 96346,
        currency: 'USD',
        formattedPrice: period.unit === PeriodUnit.Month ? '$1.15' : '$0.10'
      }
    };

    const trialPricingPhase: PricingPhase = {
      price: trialPrice,
      period: { unit: PeriodUnit.Day, number: 7 },
      periodDuration: 'P7D',
      cycleCount: 1,
      pricePerMonth: trialPrice,
      pricePerYear: trialPrice,
      pricePerWeek: trialPrice
    };

    const defaultOption: SubscriptionOption = {
      id: `${identifier}_default`,
      priceId: `price_${identifier}`,
      base: basePricingPhase,
      trial: packageType !== PackageType.Lifetime ? trialPricingPhase : null
    };

    const productType = packageType === PackageType.Lifetime ?
      ProductType.NonConsumable : ProductType.Subscription;

    const product: Product = {
      identifier: `product_${identifier}`,
      title: `${packageType} Product`,
      displayName: `${packageType} Product`,
      description: `A ${packageType} product with all features`,
      productType: productType,
      currentPrice: price,
      normalPeriodDuration: isSubscription ? periodDuration : null,
      subscriptionOptions: {},
      defaultSubscriptionOption: isSubscription ? defaultOption : null,
      defaultNonSubscriptionOption: null,
      defaultPurchaseOption: defaultOption,
      presentedOfferingIdentifier: offeringId,
      presentedOfferingContext: presentedOfferingContext
    };

    return {
      identifier: identifier,
      packageType: packageType,
      webBillingProduct: product,
      rcBillingProduct: product
    };
  }
});
