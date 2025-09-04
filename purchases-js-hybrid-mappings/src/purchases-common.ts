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
  PurchasesConfig,
  PurchasesError,
  ReservedCustomerAttribute,
} from '@revenuecat/purchases-js';
import { mapCustomerInfo } from './mappers/customer_info_mapper';
import { mapOffering, mapOfferings } from './mappers/offerings_mapper';
import { Logger } from './utils/logger';
import { mapPurchasesError } from './mappers/purchases_error_mapper';
import { mapPurchaseResult } from './mappers/purchase_result_mapper';
import { mapLogLevel } from './mappers/log_level_mapper';
import { mapVirtualCurrencies } from './mappers/virtual_currencies_mapper';

export class PurchasesCommon {
  private static instance: PurchasesCommon | null = null;
  private static proxyUrl: string | null = null;
  private static readonly APP_USER_ID_STORAGE_KEY = 'revenuecat_user_id';

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

    let appUserId: string;
    if (configuration.appUserId !== undefined) {
      appUserId = configuration.appUserId;
      if (typeof localStorage !== 'undefined') {
        localStorage.setItem(PurchasesCommon.APP_USER_ID_STORAGE_KEY, appUserId);
      }
    } else {
      if (typeof localStorage !== 'undefined') {
        const storedUserId = localStorage.getItem(PurchasesCommon.APP_USER_ID_STORAGE_KEY);
        if (storedUserId) {
          appUserId = storedUserId;
        } else {
          appUserId = Purchases.generateRevenueCatAnonymousAppUserId();
          localStorage.setItem(PurchasesCommon.APP_USER_ID_STORAGE_KEY, appUserId);
        }
      } else {
        appUserId = Purchases.generateRevenueCatAnonymousAppUserId();
      }
    }

    let httpConfig: HttpConfig | undefined = undefined;
    if (PurchasesCommon.proxyUrl) {
      httpConfig = { proxyURL: PurchasesCommon.proxyUrl };
    }

    const purchasesConfig: PurchasesConfig = {
      apiKey: configuration.apiKey,
      appUserId: appUserId,
      httpConfig: httpConfig,
    };
    const purchasesInstance = Purchases.configure(purchasesConfig);
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

  public async setAttributes(attributes: { [key: string]: string | null }): Promise<void> {
    try {
      await this.purchases.setAttributes(attributes);
    } catch (error) {
      this.handleError(error);
    }
  }

  public async setEmail(email: string | null): Promise<void> {
    await this.setReservedCustomerAttribute(ReservedCustomerAttribute.Email, email);
  }

  public async setPhoneNumber(phoneNumber: string | null): Promise<void> {
    await this.setReservedCustomerAttribute(ReservedCustomerAttribute.PhoneNumber, phoneNumber);
  }

  public async setDisplayName(displayName: string | null): Promise<void> {
    await this.setReservedCustomerAttribute(ReservedCustomerAttribute.DisplayName, displayName);
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
    try {
      const nativePurchaseParams: PurchaseParams =
        await this.createNativePurchaseParams(purchaseParams);
      const purchaseResult: PurchaseResult = await this.purchases.purchase(nativePurchaseParams);
      return mapPurchaseResult(purchaseResult);
    } catch (error) {
      this.handleError(error);
    }
  }

  /**
   * @internal
   */
  public async _purchaseSimulatedStorePackage(purchaseParams: {
    packageIdentifier: string;
    presentedOfferingContext: Record<string, unknown>;
  }): Promise<Record<string, unknown>> {
    try {
      const nativePurchaseParams: PurchaseParams =
        await this.createNativePurchaseParams(purchaseParams);
      const product = nativePurchaseParams.rcPackage.webBillingProduct;
      // @ts-ignore using an internal method
      const purchaseResult = await this.purchases._postSimulatedStoreReceipt(product);
      return mapPurchaseResult(purchaseResult);
    } catch (error) {
      this.handleError(error);
    }
  }

  public async getVirtualCurrencies(): Promise<Record<string, unknown>> {
    try {
      const virtualCurrencies = await this.purchases.getVirtualCurrencies();
      return mapVirtualCurrencies(virtualCurrencies);
    } catch (error) {
      this.handleError(error);
    }
  }

  public invalidateVirtualCurrenciesCache(): void {
    this.purchases.invalidateVirtualCurrenciesCache();
  }

  public getCachedVirtualCurrencies(): Record<string, unknown> | null {
    const virtualCurrencies = this.purchases.getCachedVirtualCurrencies();
    return virtualCurrencies ? mapVirtualCurrencies(virtualCurrencies) : null;
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

  private async setReservedCustomerAttribute(
    reservedCustomerAttribute: ReservedCustomerAttribute,
    value: string | null,
  ): Promise<void> {
    try {
      await this.purchases.setAttributes({ [reservedCustomerAttribute]: value });
    } catch (error) {
      this.handleError(error);
    }
  }

  private async createNativePurchaseParams(purchaseParams: {
    packageIdentifier: string;
    presentedOfferingContext: Record<string, unknown>;
    optionIdentifier?: string;
    customerEmail?: string;
    selectedLocale?: string;
    defaultLocale?: string;
    isSimulatedStoreProduct?: boolean;
  }): Promise<PurchaseParams> {
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
      return {
        rcPackage: rcPackage,
        purchaseOption: nativePurchaseOption,
        customerEmail: purchaseParams.customerEmail,
        selectedLocale: purchaseParams.selectedLocale || navigator?.language,
        defaultLocale: purchaseParams.defaultLocale,
      } as PurchaseParams;
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
