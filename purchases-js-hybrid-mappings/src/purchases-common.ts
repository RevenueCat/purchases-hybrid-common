import { Purchases, PurchasesError } from '@revenuecat/purchases-js';
import { mapCustomerInfo } from './mappers/customer_info_mapper';
import { mapOfferings } from './mappers/offerings_mapper';
import { Logger } from './utils/logger';
import { mapPurchasesError } from './mappers/purchases_error_mapper';

export class PurchasesCommon {
  private static instance: PurchasesCommon | null = null;
  private purchases: Purchases;

  static configure(configuration: {
    apiKey: string;
    appUserId: string | undefined;
    flavor: string;
    flavorVersion: string;
  }): PurchasesCommon {
    if (PurchasesCommon.instance) {
      Logger.warn(
        'PurchasesCommon.configure() called more than once. Previous configuration will be overwritten.',
      );
    }
    Purchases.setPlatformInfo({
      flavor: configuration.flavor,
      version: configuration.flavorVersion,
    });
    const purchasesInstance = Purchases.configure(
      configuration.apiKey,
      configuration.appUserId || Purchases.generateRevenueCatAnonymousAppUserId(),
    );
    PurchasesCommon.instance = new PurchasesCommon(purchasesInstance);
    return PurchasesCommon.instance;
  }

  static getInstance(): PurchasesCommon {
    if (!PurchasesCommon.instance) {
      throw new Error('Purchases not configured. Call configure() first.');
    }
    return PurchasesCommon.instance;
  }

  private constructor(purchasesInstance: Purchases) {
    this.purchases = purchasesInstance;
  }

  public async getCustomerInfo(): Promise<Record<string, unknown>> {
    try {
      const customerInfo = await this.purchases.getCustomerInfo();
      return mapCustomerInfo(customerInfo);
    } catch (error) {
      this.handleError(error);
    }
  }

  public async getOfferings(): Promise<Record<string, unknown>> {
    try {
      const offerings = await this.purchases.getOfferings();
      return mapOfferings(offerings);
    } catch (error) {
      this.handleError(error);
    }
  }

  public async logIn(appUserId: string): Promise<Record<string, unknown>> {
    try {
      const customerInfo = await this.purchases.changeUser(appUserId);
      return mapCustomerInfo(customerInfo);
    } catch (error) {
      this.handleError(error);
    }
  }

  public async logOut(): Promise<Record<string, unknown>> {
    try {
      const customerInfo = await this.purchases.changeUser(
        Purchases.generateRevenueCatAnonymousAppUserId(),
      );
      return mapCustomerInfo(customerInfo);
    } catch (error) {
      this.handleError(error);
    }
  }

  private handleError(error: unknown): never {
    if (error instanceof PurchasesError) {
      throw mapPurchasesError(error);
    }
    throw error;
  }
}
