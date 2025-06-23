import {
  Offering,
  Offerings,
  Package,
  PackageType,
  Period,
  PeriodUnit,
  PresentedOfferingContext,
  PricingPhase,
  Product,
  ProductType,
  SubscriptionOption,
} from '@revenuecat/purchases-js';

export function mapOfferings(offerings: Offerings): Record<string, unknown> {
  return {
    all: Object.fromEntries(
      Object.entries(offerings.all).map(([key, value]) => [key, mapOffering(value)]),
    ),
    current: offerings.current ? mapOffering(offerings.current) : null,
  };
}

export function mapOffering(offering: Offering): Record<string, unknown> {
  return {
    identifier: offering.identifier,
    serverDescription: offering.serverDescription,
    metadata: offering.metadata ?? {},
    availablePackages: offering.availablePackages.map(pkg => mapPackage(pkg)),
    lifetime: offering.lifetime ? mapPackage(offering.lifetime) : null,
    annual: offering.annual ? mapPackage(offering.annual) : null,
    sixMonth: offering.sixMonth ? mapPackage(offering.sixMonth) : null,
    threeMonth: offering.threeMonth ? mapPackage(offering.threeMonth) : null,
    twoMonth: offering.twoMonth ? mapPackage(offering.twoMonth) : null,
    monthly: offering.monthly ? mapPackage(offering.monthly) : null,
    weekly: offering.weekly ? mapPackage(offering.weekly) : null,
  };
}

function mapPackage(pkg: Package): Record<string, unknown> {
  return {
    identifier: pkg.identifier,
    packageType: mapPackageType(pkg.packageType),
    product: mapProduct(pkg.webBillingProduct),
    offeringIdentifier: pkg.webBillingProduct.presentedOfferingContext.offeringIdentifier,
    presentedOfferingContext: mapPresentedOfferingContext(
      pkg.webBillingProduct.presentedOfferingContext,
    ),
  };
}

function mapProduct(product: Product): Record<string, unknown> {
  const defaultOptionBasePricingPhase = product.defaultSubscriptionOption?.base;
  return {
    identifier: product.identifier,
    description: product.description ?? '',
    title: product.title,
    price: product.currentPrice.amountMicros / 1_000_000,
    priceString: product.currentPrice.formattedPrice,
    currencyCode: product.currentPrice.currency,
    introPrice: mapIntroPrice(product), // Not supported in web yet
    discounts: null,
    pricePerWeek: defaultOptionBasePricingPhase?.pricePerWeek?.amountMicros ?? null,
    pricePerMonth: defaultOptionBasePricingPhase?.pricePerMonth?.amountMicros ?? null,
    pricePerYear: defaultOptionBasePricingPhase?.pricePerYear?.amountMicros ?? null,
    pricePerWeekString: defaultOptionBasePricingPhase?.pricePerWeek?.formattedPrice ?? null,
    pricePerMonthString: defaultOptionBasePricingPhase?.pricePerMonth?.formattedPrice ?? null,
    pricePerYearString: defaultOptionBasePricingPhase?.pricePerYear?.formattedPrice ?? null,
    productCategory: mapProductCategory(product.productType),
    productType: mapProductType(product.productType),
    subscriptionPeriod: product.normalPeriodDuration ?? null,
    defaultOption: product.defaultSubscriptionOption
      ? mapSubscriptionOption(product.defaultSubscriptionOption, product)
      : null,
    subscriptionOptions:
      product.productType === ProductType.Subscription
        ? Object.values(product.subscriptionOptions).map(subscriptionOption =>
            mapSubscriptionOption(subscriptionOption, product),
          )
        : null,
    presentedOfferingIdentifier: product.presentedOfferingContext.offeringIdentifier,
    presentedOfferingContext: mapPresentedOfferingContext(product.presentedOfferingContext),
  };
}

function mapIntroPrice(product: Product): Record<string, unknown> | null {
  const trialPhase = product.defaultSubscriptionOption?.trial;
  if (!trialPhase) {
    return null;
  }

  return {
    price: 0,
    priceString: trialPhase.price?.formattedPrice ?? '0.00', // TODO: Improve how we get a formatted price for trials
    period: trialPhase.periodDuration,
    cycles: trialPhase.cycleCount,
    ...mapPeriodForStoreProduct(trialPhase.period),
  };
}

function mapSubscriptionOption(
  option: SubscriptionOption,
  product: Product,
): Record<string, unknown> {
  let period: Record<string, unknown> | null = null;
  if (option.base.period !== null && option.base.periodDuration !== null) {
    period = mapPeriod(option.base.period, option.base.periodDuration);
  }
  let trialPhase: Record<string, unknown> | null = null;
  if (option.trial) {
    trialPhase = mapPricingPhase(option.trial);
  }
  const basePhase = mapPricingPhase(option.base);
  const pricingPhases = [];
  if (trialPhase) {
    pricingPhases.push(trialPhase);
  }
  pricingPhases.push(basePhase);
  return {
    id: option.id,
    storeProductId: product.identifier,
    productId: product.identifier,
    pricingPhases: pricingPhases,
    tags: [],
    isBasePlan: option.trial === null,
    billingPeriod: period,
    isPrepaid: false,
    fullPricePhase: basePhase,
    freePhase: trialPhase,
    introPhase: null,
    presentedOfferingIdentifier: product.presentedOfferingContext.offeringIdentifier,
    presentedOfferingContext: mapPresentedOfferingContext(product.presentedOfferingContext),
    installmentsInfo: null,
  };
}

function mapPricingPhase(pricingPhase: PricingPhase): Record<string, unknown> {
  let billingPeriod: Record<string, unknown> | null = null;
  if (pricingPhase.period !== null && pricingPhase.periodDuration !== null) {
    billingPeriod = mapPeriod(pricingPhase.period, pricingPhase.periodDuration);
  }
  let recurrenceMode: number | null = null;
  if (pricingPhase.cycleCount == 0) {
    recurrenceMode = 1; // INFINITE_RECURRING
  } else if (pricingPhase.cycleCount > 1) {
    recurrenceMode = 2; // FINITE_RECURRING
  } else if (pricingPhase.cycleCount == 1) {
    recurrenceMode = 3; // NON_RECURRING
  }
  let offerPaymentMode: string | null = null;
  if (pricingPhase.price?.amountMicros == 0) {
    offerPaymentMode = 'FREE_TRIAL';
  }
  return {
    billingPeriod: billingPeriod,
    recurrenceMode: recurrenceMode,
    billingCycleCount: pricingPhase.cycleCount,
    price: {
      formatted: pricingPhase.price?.formattedPrice ?? '',
      amountMicros: pricingPhase.price?.amountMicros ?? 0,
      currencyCode: pricingPhase.price?.currency ?? '',
    },
    offerPaymentMode: offerPaymentMode,
  };
}

function mapPresentedOfferingContext(context: PresentedOfferingContext): Record<string, unknown> {
  return {
    offeringIdentifier: context.offeringIdentifier,
    placementIdentifier: context.placementIdentifier,
    targetingContext: context.targetingContext
      ? {
          revision: context.targetingContext.revision,
          ruleId: context.targetingContext.ruleId,
        }
      : null,
  };
}

function mapPeriod(period: Period, periodIso8601: string): Record<string, unknown> {
  switch (period.unit) {
    case PeriodUnit.Day:
      return {
        unit: 'DAY',
        value: period.number,
        iso8601: periodIso8601,
      };
    case PeriodUnit.Week:
      return {
        unit: 'DAY',
        value: period.number * 7,
        iso8601: periodIso8601,
      };
    case PeriodUnit.Month:
      return {
        unit: 'MONTH',
        value: period.number,
        iso8601: periodIso8601,
      };
    case PeriodUnit.Year:
      return {
        unit: 'YEAR',
        value: period.number,
        iso8601: periodIso8601,
      };
  }
}

function mapPeriodForStoreProduct(period: Period | null): Record<string, unknown> {
  if (!period) {
    return {};
  }
  switch (period.unit) {
    case PeriodUnit.Day:
      return { periodUnit: 'DAY', periodNumberOfUnits: period.number };
    case PeriodUnit.Month:
      return { periodUnit: 'MONTH', periodNumberOfUnits: period.number };
    case PeriodUnit.Week:
      return { periodUnit: 'DAY', periodNumberOfUnits: period.number * 7 };
    case PeriodUnit.Year:
      return { periodUnit: 'YEAR', periodNumberOfUnits: period.number };
  }
}

function mapProductCategory(productType: ProductType): string {
  switch (productType) {
    case ProductType.Subscription:
      return 'SUBSCRIPTION';
    case ProductType.Consumable:
    case ProductType.NonConsumable:
      return 'NON_SUBSCRIPTION';
  }
}

function mapProductType(productType: ProductType): string {
  switch (productType) {
    case ProductType.Subscription:
      return 'AUTO_RENEWABLE_SUBSCRIPTION';
    case ProductType.Consumable:
      return 'CONSUMABLE';
    case ProductType.NonConsumable:
      return 'NON_CONSUMABLE';
  }
}

function mapPackageType(packageType: PackageType): string {
  switch (packageType) {
    case PackageType.Custom:
      return 'CUSTOM';
    case PackageType.Lifetime:
      return 'LIFETIME';
    case PackageType.Annual:
      return 'ANNUAL';
    case PackageType.SixMonth:
      return 'SIX_MONTH';
    case PackageType.ThreeMonth:
      return 'THREE_MONTH';
    case PackageType.TwoMonth:
      return 'TWO_MONTH';
    case PackageType.Monthly:
      return 'MONTHLY';
    case PackageType.Weekly:
      return 'WEEKLY';
    default:
      return 'UNKNOWN';
  }
}
