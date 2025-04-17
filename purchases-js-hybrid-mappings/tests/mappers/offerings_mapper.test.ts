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
  SubscriptionOption,
  NonSubscriptionOption
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

    const expectedAnnualOption = {
      billingPeriod: {
        iso8601: 'P1Y',
        unit: 'YEAR',
        value: 1
      },
      freePhase: {
        billingCycleCount: 1,
        billingPeriod: {
          iso8601: 'P7D',
          unit: 'DAY',
          value: 7
        },
        offerPaymentMode: 'FREE_TRIAL',
        price: {
          amountMicros: 0,
          currencyCode: 'USD',
          formatted: 'Free'
        },
        recurrenceMode: 3
      },
      fullPricePhase: {
        billingCycleCount: 0,
        billingPeriod: {
          iso8601: 'P1Y',
          unit: 'YEAR',
          value: 1
        },
        offerPaymentMode: null,
        price: {
          amountMicros: 4990000,
          currencyCode: 'USD',
          formatted: '$4.99'
        },
        recurrenceMode: 1
      },
      id: 'annual_pkg_default',
      installmentsInfo: null,
      introPhase: null,
      isBasePlan: false,
      isPrepaid: false,
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      presentedOfferingIdentifier: 'premium_offering',
      pricingPhases: [
        {
          billingCycleCount: 1,
          billingPeriod: {
            iso8601: 'P7D',
            unit: 'DAY',
            value: 7
          },
          offerPaymentMode: 'FREE_TRIAL',
          price: {
            amountMicros: 0,
            currencyCode: 'USD',
            formatted: 'Free'
          },
          recurrenceMode: 3
        },
        {
          billingCycleCount: 0,
          billingPeriod: {
            iso8601: 'P1Y',
            unit: 'YEAR',
            value: 1
          },
          offerPaymentMode: null,
          price: {
            amountMicros: 4990000,
            currencyCode: 'USD',
            formatted: '$4.99'
          },
          recurrenceMode: 1
        }
      ],
      productId: 'product_annual_pkg',
      storeProductId: 'product_annual_pkg',
      tags: []
    };

    const expectedPackageProduct = {
      currencyCode: 'USD',
      defaultOption: expectedAnnualOption,
      subscriptionOptions: [expectedAnnualOption],
      description: 'A $rc_annual product with all features',
      discounts: null,
      identifier: 'product_annual_pkg',
      introPrice: {
        cycles: 1,
        period: 'P7D',
        periodNumberOfUnits: 7,
        periodUnit: 'DAY',
        price: 0,
        priceString: 'Free'
      },
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      presentedOfferingIdentifier: 'premium_offering',
      price: 4.99,
      pricePerMonth: 415833,
      pricePerMonthString: '$0.42',
      pricePerWeek: 96346,
      pricePerWeekString: '$0.10',
      pricePerYear: 4990000,
      pricePerYearString: '$4.99',
      priceString: '$4.99',
      productCategory: 'SUBSCRIPTION',
      productType: 'AUTO_RENEWABLE_SUBSCRIPTION',
      subscriptionPeriod: 'P1Y',
      title: '$rc_annual Product'
    };

    const expectedMonthlyOption = {
      billingPeriod: {
        iso8601: 'P1M',
        unit: 'MONTH',
        value: 1
      },
      freePhase: {
        billingCycleCount: 1,
        billingPeriod: {
          iso8601: 'P7D',
          unit: 'DAY',
          value: 7
        },
        offerPaymentMode: 'FREE_TRIAL',
        price: {
          amountMicros: 0,
          currencyCode: 'USD',
          formatted: 'Free'
        },
        recurrenceMode: 3
      },
      fullPricePhase: {
        billingCycleCount: 0,
        billingPeriod: {
          iso8601: 'P1M',
          unit: 'MONTH',
          value: 1
        },
        offerPaymentMode: null,
        price: {
          amountMicros: 4990000,
          currencyCode: 'USD',
          formatted: '$4.99'
        },
        recurrenceMode: 1
      },
      id: 'monthly_pkg_default',
      installmentsInfo: null,
      introPhase: null,
      isBasePlan: false,
      isPrepaid: false,
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      presentedOfferingIdentifier: 'premium_offering',
      pricingPhases: [
        {
          billingCycleCount: 1,
          billingPeriod: {
            iso8601: 'P7D',
            unit: 'DAY',
            value: 7
          },
          offerPaymentMode: 'FREE_TRIAL',
          price: {
            amountMicros: 0,
            currencyCode: 'USD',
            formatted: 'Free'
          },
          recurrenceMode: 3
        },
        {
          billingCycleCount: 0,
          billingPeriod: {
            iso8601: 'P1M',
            unit: 'MONTH',
            value: 1
          },
          offerPaymentMode: null,
          price: {
            amountMicros: 4990000,
            currencyCode: 'USD',
            formatted: '$4.99'
          },
          recurrenceMode: 1
        }
      ],
      productId: 'product_monthly_pkg',
      storeProductId: 'product_monthly_pkg',
      tags: []
    };

    const expectedMonthlyProduct = {
      ...expectedPackageProduct,
      identifier: 'product_monthly_pkg',
      description: 'A $rc_monthly product with all features',
      defaultOption: expectedMonthlyOption,
      subscriptionOptions: [expectedMonthlyOption],
      pricePerMonth: 4990000,
      pricePerMonthString: '$4.99',
      pricePerWeek: 1151538,
      pricePerWeekString: '$1.15',
      pricePerYear: 59880000,
      pricePerYearString: '$59.88',
      subscriptionPeriod: 'P1M',
      title: '$rc_monthly Product'
    };

    const expectedWeeklyOption = {
      billingPeriod: {
        iso8601: 'P1W',
        unit: 'DAY',
        value: 7
      },
      freePhase: {
        billingCycleCount: 1,
        billingPeriod: {
          iso8601: 'P7D',
          unit: 'DAY',
          value: 7
        },
        offerPaymentMode: 'FREE_TRIAL',
        price: {
          amountMicros: 0,
          currencyCode: 'USD',
          formatted: 'Free'
        },
        recurrenceMode: 3
      },
      fullPricePhase: {
        billingCycleCount: 0,
        billingPeriod: {
          iso8601: 'P1W',
          unit: 'DAY',
          value: 7
        },
        offerPaymentMode: null,
        price: {
          amountMicros: 4990000,
          currencyCode: 'USD',
          formatted: '$4.99'
        },
        recurrenceMode: 1
      },
      id: 'weekly_pkg_default',
      installmentsInfo: null,
      introPhase: null,
      isBasePlan: false,
      isPrepaid: false,
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      presentedOfferingIdentifier: 'premium_offering',
      pricingPhases: [
        {
          billingCycleCount: 1,
          billingPeriod: {
            iso8601: 'P7D',
            unit: 'DAY',
            value: 7
          },
          offerPaymentMode: 'FREE_TRIAL',
          price: {
            amountMicros: 0,
            currencyCode: 'USD',
            formatted: 'Free'
          },
          recurrenceMode: 3
        },
        {
          billingCycleCount: 0,
          billingPeriod: {
            iso8601: 'P1W',
            unit: 'DAY',
            value: 7
          },
          offerPaymentMode: null,
          price: {
            amountMicros: 4990000,
            currencyCode: 'USD',
            formatted: '$4.99'
          },
          recurrenceMode: 1
        }
      ],
      productId: 'product_weekly_pkg',
      storeProductId: 'product_weekly_pkg',
      tags: []
    };

    const expectedWeeklyProduct = {
      ...expectedPackageProduct,
      identifier: 'product_weekly_pkg',
      description: 'A $rc_weekly product with all features',
      defaultOption: expectedWeeklyOption,
      subscriptionOptions: [expectedWeeklyOption],
      pricePerMonth: 4990000,
      pricePerMonthString: '$4.99',
      pricePerWeek: 96346,
      pricePerWeekString: '$0.10',
      pricePerYear: 59880000,
      pricePerYearString: '$59.88',
      subscriptionPeriod: 'P1W',
      title: '$rc_weekly Product'
    };

    const expectedLifetimeProduct = {
      currencyCode: 'USD',
      defaultOption: null,
      description: 'A $rc_lifetime product with all features',
      discounts: null,
      identifier: 'product_lifetime_pkg',
      introPrice: null,
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      presentedOfferingIdentifier: 'premium_offering',
      price: 4.99,
      pricePerMonth: null,
      pricePerMonthString: null,
      pricePerWeek: null,
      pricePerWeekString: null,
      pricePerYear: null,
      pricePerYearString: null,
      priceString: '$4.99',
      productCategory: 'NON_SUBSCRIPTION',
      productType: 'NON_CONSUMABLE',
      subscriptionOptions: null,
      subscriptionPeriod: null,
      title: '$rc_lifetime Product'
    };

    const expectedAnnualPackage = {
      identifier: 'annual_pkg',
      offeringIdentifier: 'premium_offering',
      packageType: 'ANNUAL',
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      product: expectedPackageProduct
    };

    const expectedMonthlyPackage = {
      identifier: 'monthly_pkg',
      offeringIdentifier: 'premium_offering',
      packageType: 'MONTHLY',
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      product: expectedMonthlyProduct
    };

    const expectedWeeklyPackage = {
      identifier: 'weekly_pkg',
      offeringIdentifier: 'premium_offering',
      packageType: 'WEEKLY',
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      product: expectedWeeklyProduct
    };

    const expectedLifetimePackage = {
      identifier: 'lifetime_pkg',
      offeringIdentifier: 'premium_offering',
      packageType: 'LIFETIME',
      presentedOfferingContext: {
        offeringIdentifier: 'premium_offering',
        placementIdentifier: 'main_page',
        targetingContext: {
          revision: 1,
          ruleId: 'rule_123'
        }
      },
      product: expectedLifetimeProduct
    };

    const expectedOffering = {
      identifier: 'premium_offering',
      serverDescription: 'Premium offering description',
      metadata: { tier: 'premium', featured: true },
      availablePackages: [
        expectedAnnualPackage,
        expectedMonthlyPackage,
        expectedWeeklyPackage,
        expectedLifetimePackage
      ],
      lifetime: expectedLifetimePackage,
      annual: expectedAnnualPackage,
      sixMonth: null,
      threeMonth: null,
      twoMonth: null,
      monthly: expectedMonthlyPackage,
      weekly: expectedWeeklyPackage
    };

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
      'P1Y' : packageType === PackageType.Monthly ?
        'P1M' : packageType === PackageType.Weekly ?
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

    const optionId = `${identifier}_default`;

    const defaultOption = isSubscription ? {
      id: optionId,
      priceId: `price_${identifier}`,
      base: basePricingPhase,
      trial: trialPricingPhase
    } as SubscriptionOption : {
      id: optionId,
      priceId: `price_${identifier}`,
      price: price,
      basePrice: price
    } as NonSubscriptionOption;

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
      subscriptionOptions: isSubscription ? { [optionId]: defaultOption as SubscriptionOption } : {},
      defaultSubscriptionOption: isSubscription ? defaultOption as SubscriptionOption : null,
      defaultNonSubscriptionOption: !isSubscription ? defaultOption as NonSubscriptionOption : null,
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
