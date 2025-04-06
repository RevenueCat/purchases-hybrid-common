import {
  Offering,
  Offerings,
  Package,
  Period,
  PeriodUnit,
  PresentedOfferingContext,
  PricingPhase,
  Price,
  Product,
  ProductType,
  SubscriptionOption,
  PackageType
} from "@revenuecat/purchases-js";
import { mapOfferings } from "../../src/mappers/offerings_mapper";

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
    };

    expect(result).toEqual({
      all: {
        'basic_offering': expectedOffering,
      },
      current: expectedOffering,
    });
  });

  it('maps Offerings with more complete data correctly', () => {
    const lifetimePackage = createFullPackage('lifetime_pkg', 'premium_offering', PackageType.Lifetime);
    const annualPackage = createFullPackage('annual_pkg', 'premium_offering', PackageType.Annual);
    const monthlyPackage = createFullPackage('monthly_pkg', 'premium_offering', PackageType.Monthly);
    const weeklyPackage = createFullPackage('weekly_pkg', 'premium_offering', PackageType.Weekly);
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

  function createMinimalPackage(identifier: string, offeringId: string): Package {
    const presentedOfferingContext: PresentedOfferingContext = {
      offeringIdentifier: offeringId,
      placementIdentifier: null,
      targetingContext: null
    };

    const price: Price = {
      amount: 99,
      amountMicros: 990000,
      currency: 'USD',
      formattedPrice: '$0.99'
    };

    const period: Period = {
      unit: PeriodUnit.Month,
      number: 1
    };

    const basePricingPhase: PricingPhase = {
      price: price,
      period: period,
      periodDuration: 'P1M',
      cycleCount: 0,
      pricePerMonth: price,
      pricePerYear: {
        amount: 1199,
        amountMicros: 11988000,
        currency: 'USD',
        formattedPrice: '$11.99'
      },
      pricePerWeek: {
        amount: 0.23,
        amountMicros: 230769,
        currency: 'USD',
        formattedPrice: '$0.23'
      }
    };

    const defaultOption: SubscriptionOption = {
      id: 'default_option',
      priceId: 'price_default',
      base: basePricingPhase,
      trial: null
    };

    const product: Product = {
      identifier: `product_${identifier}`,
      title: 'Basic Product',
      displayName: 'Basic Product',
      description: 'A basic product description',
      productType: ProductType.Subscription,
      currentPrice: price,
      normalPeriodDuration: 'P1M',
      subscriptionOptions: {},
      defaultSubscriptionOption: defaultOption,
      defaultNonSubscriptionOption: null,
      defaultPurchaseOption: defaultOption,
      presentedOfferingIdentifier: offeringId,
      presentedOfferingContext: presentedOfferingContext
    };

    const rcPackage: Package = {
      identifier: identifier,
      packageType: PackageType.Monthly,
      webBillingProduct: product,
      rcBillingProduct: product,
    }

    return rcPackage;
  }

  function createFullPackage(identifier: string, offeringId: string, packageType: PackageType): Package {
    const presentedOfferingContext: PresentedOfferingContext = {
      offeringIdentifier: offeringId,
      placementIdentifier: 'main_page',
      targetingContext: {
        revision: 1,
        ruleId: 'rule_123'
      }
    };

    const price: Price = {
      amount: 4.99,
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
    
    const period = packageType === PackageType.Annual ? 
      { unit: PeriodUnit.Year, number: 1 } : 
      packageType === PackageType.Monthly ? 
        { unit: PeriodUnit.Month, number: 1 } : 
        packageType === PackageType.Weekly ? 
          { unit: PeriodUnit.Week, number: 1 } : 
          { unit: PeriodUnit.Month, number: 1 };

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
        { amount: 0.42, amountMicros: 415833, currency: 'USD', formattedPrice: '$0.42' } : price,
      pricePerYear: period.unit === PeriodUnit.Month || period.unit === PeriodUnit.Week ? 
        { amount: 59.88, amountMicros: 59880000, currency: 'USD', formattedPrice: '$59.88' } : price,
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

    const rcPackage: Package = {
      identifier: identifier,
      packageType: packageType,
      webBillingProduct: product,
      rcBillingProduct: product
    };

    return rcPackage;
  }
}); 