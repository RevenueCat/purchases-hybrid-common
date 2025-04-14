import {
  ErrorCode,
  Offering,
  PurchaseOption,
  PurchaseParams,
  PurchaseResult,
  Purchases,
  PurchasesError,
} from '@revenuecat/purchases-js';
import { mapCustomerInfo } from './mappers/customer_info_mapper';
import { mapOfferings } from './mappers/offerings_mapper';
import { Logger } from './utils/logger';
import { mapPurchasesError } from './mappers/purchases_error_mapper';
import { mapPurchaseResult } from './mappers/purchase_result_mapper';

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
      const offerings = await this.purchases.getOfferings();
      const offering: Offering = offerings.all[presentedOfferingIdentifier];
      if (!offering) {
        const purchasesError = new PurchasesError(
          ErrorCode.PurchaseInvalidError,
          'Could not find offering with identifier: ' +
            presentedOfferingIdentifier +
            '. Found offering ids: ' +
            Object.keys(offerings.all).join(', '),
        );
        this.handleError(purchasesError);
      }
      const rcPackage = offering.availablePackages.find(
        currentPackage => currentPackage.identifier === purchaseParams.packageIdentifier,
      );
      if (!rcPackage) {
        const purchasesError = new PurchasesError(
          ErrorCode.PurchaseInvalidError,
          'Could not find package with id: ' +
            purchaseParams.packageIdentifier +
            ' in offering with id: ' +
            presentedOfferingIdentifier,
        );
        this.handleError(purchasesError);
      }
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

  private handleError(error: unknown): never {
    if (error instanceof PurchasesError) {
      throw mapPurchasesError(error);
    }
    throw error;
  }
}
