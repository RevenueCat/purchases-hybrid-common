import { PurchasesCommon } from '../src/purchases-common';
import { Purchases, Offering, Package, PurchaseResult, PurchasesError, ErrorCode, EntitlementInfos, CustomerInfo, PackageType, Product, ProductType, SubscriptionOption, PeriodUnit } from '@revenuecat/purchases-js';
import { jest } from '@jest/globals';

describe('PurchasesCommon', () => {
  let purchasesCommon: PurchasesCommon;
  const mockPurchasesInstance: jest.Mocked<Purchases> = {
    getOfferings: jest.fn(),
    purchase: jest.fn(),
    purchasePackage: jest.fn(),
    getCustomerInfo: jest.fn(),
    changeUser: jest.fn(),
    getCurrentOfferingForPlacement: jest.fn(),
    isEntitledTo: jest.fn(),
    close: jest.fn(),
    preload: jest.fn(),
    getAppUserId: jest.fn(),
    isSandbox: jest.fn(),
  };

  const customerInfo: CustomerInfo = {
    entitlements: {
      all: {},
      active: {}
    } as EntitlementInfos,
    activeSubscriptions: new Set<string>(),
    allPurchaseDatesByProduct: {},
    allExpirationDatesByProduct: {},
    firstSeenDate: new Date(),
    originalAppUserId: 'test_user_id',
    requestDate: new Date(),
    originalPurchaseDate: new Date(),
    managementURL: null,
    nonSubscriptionTransactions: [],
    subscriptionsByProductIdentifier: {}
  };

  const mockMonthlyProductSubscriptionOption: SubscriptionOption = {
    id: 'test_monthly_option',
    base: {
        periodDuration: 'P1M',
        period: { number: 1, unit: PeriodUnit.Month },
        price: { amountMicros: 9990000, amount: 999, currency: 'USD', formattedPrice: '$9.99' },
        cycleCount: 0,
        pricePerWeek: { amountMicros: 2490000, amount: 249, currency: 'USD', formattedPrice: '$2.49' },
        pricePerMonth: { amountMicros: 9990000, amount: 999, currency: 'USD', formattedPrice: '$9.99' },
        pricePerYear: { amountMicros: 11999000, amount: 11998, currency: 'USD', formattedPrice: '$119.98' },
    },
    trial: null,
    priceId: 'test_monthly_option_price_id',
  };

  const mockMonthlyProduct: Product = {
    identifier: 'test_monthly_product',
    displayName: 'Test Monthly Product',
    title: 'Test Monthly Product',
    description: 'Test Monthly Product',
    productType: ProductType.Subscription,
    currentPrice: { amountMicros: 9990000, amount: 999, currency: 'USD', formattedPrice: '$9.99' },
    normalPeriodDuration: 'P1M',
    presentedOfferingIdentifier: 'test_offering',
    presentedOfferingContext: {
      offeringIdentifier: 'test_offering',
      targetingContext: null,
      placementIdentifier: null,
    },
    defaultNonSubscriptionOption: null,
    defaultPurchaseOption: mockMonthlyProductSubscriptionOption,
    defaultSubscriptionOption: mockMonthlyProductSubscriptionOption,
    subscriptionOptions: {
      [mockMonthlyProductSubscriptionOption.id]: mockMonthlyProductSubscriptionOption,
    },
  };

  const mockMonthlyPackage: Package = {
    identifier: 'test_package',
    packageType: PackageType.Monthly,
    rcBillingProduct: mockMonthlyProduct,
    webBillingProduct: mockMonthlyProduct,
  };

  const mockOffering: Offering = {
    identifier: 'test_offering',
    serverDescription: 'Test offering',
    availablePackages: [
      mockMonthlyPackage,
    ],
    packagesById: {
      [mockMonthlyPackage.identifier]: mockMonthlyPackage,
    },
    metadata: {},
    lifetime: null,
    annual: null,
    sixMonth: null,
    threeMonth: null,
    twoMonth: null,
    monthly: mockMonthlyPackage,
    weekly: null,
    paywall_components: null,
  };

  const mockPurchaseResult: PurchaseResult = {
    customerInfo: customerInfo,
    redemptionInfo: { redeemUrl: 'test_url' },
    operationSessionId: 'test_session_id'
  };

  beforeEach(() => {
    if (Purchases.isConfigured()) {
      Purchases.getSharedInstance().close();
    }
    jest.clearAllMocks();
    jest.spyOn(Purchases, 'configure').mockReturnValue(mockPurchasesInstance);
    jest.spyOn(Purchases, 'setPlatformInfo').mockImplementation(() => {});
    jest.spyOn(Purchases, 'generateRevenueCatAnonymousAppUserId').mockReturnValue('anonymous_id');
    purchasesCommon = PurchasesCommon.configure({
      apiKey: 'test_api_key',
      appUserId: 'test_user_id',
      flavor: 'test_flavor',
      flavorVersion: '1.0.0'
    });
  });

  describe('purchasePackage', () => {
    it('should throw error when offering identifier is invalid', async () => {
      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: {},
        optionIdentifier: 'test_option'
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.PurchaseInvalidError,
        message: 'Need to provide a valid offering identifier',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      });
    });

    it('should throw error when offering is not found', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: {},
        current: null
      });

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'non_existent_offering' },
        optionIdentifier: 'test_option'
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.PurchaseInvalidError,
        message: 'Could not find offering with identifier: non_existent_offering. Found offering ids: ',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      });
    });

    it('should throw error when package is not found', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering
      });

      const purchaseParams = {
        packageIdentifier: 'non_existent_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        optionIdentifier: 'test_option'
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.PurchaseInvalidError,
        message: 'Could not find package with id: non_existent_package in offering with id: test_offering',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      })
    });

    it('should throw error when purchase option is not found', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering
      });

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        optionIdentifier: 'non_existent_option'
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.PurchaseInvalidError,
        message: 'Could not find option with id: non_existent_option in package with id: test_package',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      })
    });

    it('should successfully complete purchase with option', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering
      });
      mockPurchasesInstance.purchase.mockResolvedValue(mockPurchaseResult);

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        optionIdentifier: 'test_monthly_option',
        customerEmail: 'test@example.com',
        selectedLocale: 'en-US',
        defaultLocale: 'en'
      };

      const result = await purchasesCommon.purchasePackage(purchaseParams);
      expect(result).toBeDefined();
      expect(mockPurchasesInstance.purchase).toHaveBeenCalledWith({
        rcPackage: mockOffering.availablePackages[0],
        purchaseOption: mockOffering.availablePackages[0].webBillingProduct.subscriptionOptions['test_monthly_option'],
        customerEmail: 'test@example.com',
        selectedLocale: 'en-US',
        defaultLocale: 'en'
      });
    });

    it('should successfully complete purchase without option', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering
      });
      mockPurchasesInstance.purchase.mockResolvedValue(mockPurchaseResult);

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        customerEmail: 'test@example.com'
      };

      const result = await purchasesCommon.purchasePackage(purchaseParams);
      expect(result).toBeDefined();
      expect(mockPurchasesInstance.purchase).toHaveBeenCalledWith({
        rcPackage: mockOffering.availablePackages[0],
        purchaseOption: null,
        customerEmail: 'test@example.com'
      });
    });

    it('should use cached offering if it exists', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering
      });
      mockPurchasesInstance.purchase.mockResolvedValue(mockPurchaseResult);

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        customerEmail: 'test@example.com'
      };

      expect(mockPurchasesInstance.getOfferings).toHaveBeenCalledTimes(0);

      await purchasesCommon.getOfferings();

      expect(mockPurchasesInstance.getOfferings).toHaveBeenCalledTimes(1);

      const result = await purchasesCommon.purchasePackage(purchaseParams);

      expect(mockPurchasesInstance.getOfferings).toHaveBeenCalledTimes(1);
      expect(result).toBeDefined();
      expect(mockPurchasesInstance.purchase).toHaveBeenCalledWith({
        rcPackage: mockOffering.availablePackages[0],
        purchaseOption: null,
        customerEmail: 'test@example.com'
      });
    });

    it('should handle purchase errors', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering
      });
      const mockError = new PurchasesError(ErrorCode.UserCancelledError, 'Purchase cancelled');
      mockPurchasesInstance.purchase.mockRejectedValue(mockError);

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' }
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.UserCancelledError,
        message: 'Purchase cancelled',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      })
    });
  });
});
