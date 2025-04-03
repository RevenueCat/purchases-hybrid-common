import {Purchases} from "@revenuecat/purchases-js";
import {mapCustomerInfo} from "./mappers/customer_info_mapper";

export class PurchasesCommon {

  private static instance: Purchases | null = null;

  static configure(
    configuration: {
      apiKey: string,
      appUserId: string | undefined,
    }
  ): PurchasesCommon {
    const purchasesInstance = Purchases.configure(
      configuration.apiKey,
      configuration.appUserId || Purchases.generateRevenueCatAnonymousAppUserId(),
    )
    return new PurchasesCommon(purchasesInstance);
  }

  private constructor(purchasesInstance: Purchases) {
    PurchasesCommon.instance = purchasesInstance;
  }

  public async getCustomerInfo(): Promise<Record<string, unknown>> {
    if (!PurchasesCommon.instance) {
      throw new Error("Purchases not configured");
    }
    const customerInfo = await PurchasesCommon.instance.getCustomerInfo();
    return mapCustomerInfo(customerInfo);
  }
}
