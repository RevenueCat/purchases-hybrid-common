import {
  ErrorCode,
  HttpConfig,
  Offering,
  Offerings,
  Package,
  PurchaseOption,
  PurchaseParams,
  PurchaseResult,
  Purchases,
  PurchasesError,
} from '@revenuecat/purchases-js';
import { mapCustomerInfo } from './mappers/customer_info_mapper';
import { mapOffering, mapOfferings } from './mappers/offerings_mapper';
import { Logger } from './utils/logger';
import { mapPurchasesError } from './mappers/purchases_error_mapper';
import { mapPurchaseResult } from './mappers/purchase_result_mapper';
import { mapLogLevel } from './mappers/log_level_mapper';

export class PurchasesCommon {
  private static instance: PurchasesCommon | null = null;
  private static proxyUrl: string | null = null;

  private purchases: Purchases;

  private offeringsCache: Offerings | null = null;

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
    let httpConfig: HttpConfig | undefined = undefined;
    if (PurchasesCommon.proxyUrl) {
      httpConfig = { proxyURL: PurchasesCommon.proxyUrl };
    }
    const purchasesInstance = Purchases.configure(
      configuration.apiKey,
      configuration.appUserId || Purchases.generateRevenueCatAnonymousAppUserId(),
      httpConfig,
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

  static setLogLevel(logLevel: string): void {
    const logLevelEnum = mapLogLevel(logLevel);
    if (logLevelEnum) {
      Purchases.setLogLevel(logLevelEnum);
    }
  }

  static isConfigured(): boolean {
    return Purchases.isConfigured();
  }

  static setProxyUrl(proxyUrl: string): void {
    if (PurchasesCommon.proxyUrl !== proxyUrl) {
      PurchasesCommon.proxyUrl = proxyUrl;
    }
  }

  private constructor(purchasesInstance: Purchases) {
    this.purchases = purchasesInstance;
  }

  public getAppUserId(): string {
    return this.purchases.getAppUserId();
  }

  public isSandbox(): boolean {
    return this.purchases.isSandbox();
  }

  public isAnonymous(): boolean {
    return this.purchases.isAnonymous();
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
      this.offeringsCache = offerings;
      return mapOfferings(offerings);
    } catch (error) {
      this.handleError(error);
    }
  }

  public async getCurrentOfferingForPlacement(
    placementIdentifier: string,
  ): Promise<Record<string, unknown> | null> {
    try {
      const offering = await this.purchases.getCurrentOfferingForPlacement(placementIdentifier);
      return offering ? mapOffering(offering) : null;
    } catch (error) {
      this.handleError(error);
    }
  }

  public async logIn(appUserId: string): Promise<Record<string, unknown>> {
    try {
      const customerInfo = await this.purchases.changeUser(appUserId);
      return {
        customerInfo: mapCustomerInfo(customerInfo),
        // TODO: In Web, we don't have a logIn method, which provides the information on whether the user was created
        // or not. For now, hardcoding this data to false
        created: false,
      };
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

  public async close(): Promise<void> {
    try {
      this.purchases.close();
    } catch (error) {
      this.handleError(error);
    }
  }

  public async purchasePackage(purchaseParams: {
    packageIdentifier: string;
    presentedOfferingContext: Record<string, unknown>;
    optionIdentifier?: string;
    customerEmail?: string;
    selectedLocale?: string;
    defaultLocale?: string;
  }): Promise<Record<string, unknown>> {
    const presentedOfferingIdentifier =
      purchaseParams.presentedOfferingContext['offeringIdentifier'];
    if (!presentedOfferingIdentifier || typeof presentedOfferingIdentifier !== 'string') {
      const purchasesError = new PurchasesError(
        ErrorCode.PurchaseInvalidError,
        'Need to provide a valid offering identifier',
      );
      this.handleError(purchasesError);
    }
    try {
      const rcPackage = await this.findPackageToPurchase(
        purchaseParams.packageIdentifier,
        presentedOfferingIdentifier,
      );
      let nativePurchaseOption: PurchaseOption | null = null;
      if (purchaseParams.optionIdentifier) {
        const product = rcPackage.webBillingProduct;
        const option = product.subscriptionOptions[purchaseParams.optionIdentifier];
        if (!option) {
          const purchasesError = new PurchasesError(
            ErrorCode.PurchaseInvalidError,
            'Could not find option with id: ' +
              purchaseParams.optionIdentifier +
              ' in package with id: ' +
              purchaseParams.packageIdentifier,
          );
          this.handleError(purchasesError);
        }
        nativePurchaseOption = option;
      }
      const nativePurchaseParams: PurchaseParams = {
        rcPackage: rcPackage,
        purchaseOption: nativePurchaseOption,
        customerEmail: purchaseParams.customerEmail,
        selectedLocale: purchaseParams.selectedLocale,
        defaultLocale: purchaseParams.defaultLocale,
      };
      const purchaseResult: PurchaseResult = await this.purchases.purchase(nativePurchaseParams);
      return mapPurchaseResult(purchaseResult);
    } catch (error) {
      this.handleError(error);
    }
  }

  private async findPackageToPurchase(
    packageIdentifier: string,
    offeringIdentifier: string,
  ): Promise<Package> {
    let rcPackage: Package | null = null;
    if (this.offeringsCache?.all[offeringIdentifier]) {
      const offering = this.offeringsCache.all[offeringIdentifier];
      rcPackage =
        offering.availablePackages.find(
          currentPackage => currentPackage.identifier === packageIdentifier,
        ) ?? null;
    }
    if (!rcPackage) {
      try {
        const offerings = await this.purchases.getOfferings();
        const offering: Offering = offerings.all[offeringIdentifier];
        if (!offering) {
          const purchasesError = new PurchasesError(
            ErrorCode.PurchaseInvalidError,
            'Could not find offering with identifier: ' +
              offeringIdentifier +
              '. Found offering ids: ' +
              Object.keys(offerings.all).join(', '),
          );
          this.handleError(purchasesError);
        }
        rcPackage =
          offering.availablePackages.find(
            currentPackage => currentPackage.identifier === packageIdentifier,
          ) ?? null;
      } catch (error) {
        this.handleError(error);
      }
      if (!rcPackage) {
        const purchasesError = new PurchasesError(
          ErrorCode.PurchaseInvalidError,
          'Could not find package with id: ' +
            packageIdentifier +
            ' in offering with id: ' +
            offeringIdentifier,
        );
        this.handleError(purchasesError);
      }
    }

    return rcPackage;
  }

  private handleError(error: unknown): never {
    if (error instanceof PurchasesError) {
      throw mapPurchasesError(error);
    }
    throw error;
  }
}
