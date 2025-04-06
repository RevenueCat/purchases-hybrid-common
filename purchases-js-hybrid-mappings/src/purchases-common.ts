import {Purchases} from "@revenuecat/purchases-js";
import {mapCustomerInfo} from "./mappers/customer_info_mapper";
import {mapOfferings} from "./mappers/offerings_mapper";
import {Logger} from "./utils/logger";

export class PurchasesCommon {

  private static instance: PurchasesCommon | null = null;
  private purchases: Purchases;

  static configure(
    configuration: {
      apiKey: string,
      appUserId: string | undefined,
    }
  ): PurchasesCommon {
    if (PurchasesCommon.instance) {
      Logger.warn("PurchasesCommon.configure() called more than once. Previous configuration will be overwritten.");
    }
    const purchasesInstance = Purchases.configure(
      configuration.apiKey,
      configuration.appUserId || Purchases.generateRevenueCatAnonymousAppUserId(),
    )
    PurchasesCommon.instance = new PurchasesCommon(purchasesInstance);
    return PurchasesCommon.instance;
  }

  static getInstance(): PurchasesCommon {
    if (!PurchasesCommon.instance) {
      throw new Error("Purchases not configured. Call configure() first.");
    }
    return PurchasesCommon.instance;
  }

  private constructor(purchasesInstance: Purchases) {
    this.purchases = purchasesInstance;
  }

  public async getCustomerInfo(): Promise<Record<string, unknown>> {
    const customerInfo = await this.purchases.getCustomerInfo();
    return mapCustomerInfo(customerInfo);
  }

  public async getOfferings(): Promise<Record<string, unknown>> {
    const offerings = await this.purchases.getOfferings();
    return mapOfferings(offerings);
  }
}
