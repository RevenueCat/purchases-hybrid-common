import {CustomerInfo, EntitlementInfo, EntitlementInfos, PeriodType} from "@revenuecat/purchases-js";

export function mapCustomerInfo(customerInfo: CustomerInfo): Record<string, unknown> {
  const validDates = Object.values(customerInfo.allExpirationDatesByProduct).filter((date) => date !== null);
  const latestExpirationDate = validDates.length > 0 ? new Date(Math.max(...validDates.map((date) => date.getTime()))) : null;

  return {
    "entitlements": mapEntitlementInfos(customerInfo.entitlements),
    "activeSubscriptions": Array.from(customerInfo.activeSubscriptions),
    "allPurchasedProductIdentifiers": Object.keys(customerInfo.allPurchaseDatesByProduct),
    "latestExpirationDate": latestExpirationDate ? latestExpirationDate.toISOString() : null,
    "latestExpirationDateMillis": latestExpirationDate ? latestExpirationDate.getTime() : null,
    "firstSeen": customerInfo.firstSeenDate.toISOString(),
    "firstSeenMillis": customerInfo.firstSeenDate.getTime(),
    "originalAppUserId": customerInfo.originalAppUserId,
    "requestDate": customerInfo.requestDate.toISOString(),
    "requestDateMillis": customerInfo.requestDate.getTime(),
    "allExpirationDates": Object.fromEntries(
      Object.entries(customerInfo.allExpirationDatesByProduct).map(([key, value]) => [key, value ? value.toISOString() : null])
    ),
    "allExpirationDatesMillis": Object.fromEntries(
      Object.entries(customerInfo.allExpirationDatesByProduct).map(([key, value]) => [key, value ? value.getTime() : null])
    ),
    "allPurchaseDates": Object.fromEntries(
      Object.entries(customerInfo.allPurchaseDatesByProduct).map(([key, value]) => [key, value ? value.toISOString() : null])
    ),
    "allPurchaseDatesMillis": Object.fromEntries(
      Object.entries(customerInfo.allPurchaseDatesByProduct).map(([key, value]) => [key, value ? value.getTime() : null])
    ),
    "originalApplicationVersion": null,
    "managementURL": customerInfo.managementURL,
    "originalPurchaseDate": customerInfo.originalPurchaseDate ? customerInfo.originalPurchaseDate.toISOString() : null,
    "originalPurchaseDateMillis": customerInfo.originalPurchaseDate ? customerInfo.originalPurchaseDate.getTime() : null,
    "nonSubscriptionTransactions": {}, // TODO
    "subscriptionsByProductIdentifier": {} // TODO
  };
}

function mapEntitlementInfos(entitlementInfos: EntitlementInfos): Record<string, unknown> {
  return {
    "all": Object.fromEntries(
      Object.entries(entitlementInfos.all).map(([key, value]) => [key, mapEntitlementInfo(value)])
    ),
    "active": Object.fromEntries(
      Object.entries(entitlementInfos.active).map(([key, value]) => [key, mapEntitlementInfo(value)])
    ),
    "verification": "NOT_REQUESTED" // TODO: Trusted entitlements not available in JS SDK
  };
}

function mapEntitlementInfo(entitlementInfo: EntitlementInfo): Record<string, unknown> {
  return {
    "identifier": entitlementInfo.identifier,
    "isActive": entitlementInfo.isActive,
    "willRenew": entitlementInfo.willRenew,
    "periodType": mapPeriodType(entitlementInfo.periodType),
    "latestPurchaseDate": entitlementInfo.latestPurchaseDate ? entitlementInfo.latestPurchaseDate.toISOString() : null,
    "latestPurchaseDateMillis": entitlementInfo.latestPurchaseDate ? entitlementInfo.latestPurchaseDate.getTime() : null,
    "originalPurchaseDate": entitlementInfo.originalPurchaseDate ? entitlementInfo.originalPurchaseDate.toISOString() : null,
    "originalPurchaseDateMillis": entitlementInfo.originalPurchaseDate ? entitlementInfo.originalPurchaseDate.getTime() : null,
    "expirationDate": entitlementInfo.expirationDate ? entitlementInfo.expirationDate.toISOString() : null,
    "expirationDateMillis": entitlementInfo.expirationDate ? entitlementInfo.expirationDate.getTime() : null,
    "store": entitlementInfo.store,
    "productIdentifier": entitlementInfo.productIdentifier,
    "productPlanIdentifier": null, // TODO: ProductPlanIdentifier not yet available in JS SDK
    "isSandbox": entitlementInfo.isSandbox,
    "unsubscribeDetectedAt": entitlementInfo.unsubscribeDetectedAt ? entitlementInfo.unsubscribeDetectedAt.toISOString() : null,
    "unsubscribeDetectedAtMillis": entitlementInfo.unsubscribeDetectedAt ? entitlementInfo.unsubscribeDetectedAt.getTime() : null,
    "billingIssueDetectedAt": entitlementInfo.billingIssueDetectedAt ? entitlementInfo.billingIssueDetectedAt.toISOString() : null,
    "billingIssueDetectedAtMillis": entitlementInfo.billingIssueDetectedAt ? entitlementInfo.billingIssueDetectedAt.getTime() : null,
    "ownershipType": "UNKNOWN", // TODO: OwnershipType not yet available in JS SDK,
    "verification": "NOT_REQUESTED", // TODO: Trusted entitlements not available in JS SDK
  };
}

function mapPeriodType(periodType: PeriodType): string {
  switch (periodType) {
    case "normal": return "NORMAL"
    case "prepaid": return "PREPAID"
    case "trial": return "TRIAL"
    case "intro": return "INTRO"
  }
}
