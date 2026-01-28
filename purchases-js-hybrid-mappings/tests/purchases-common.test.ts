import { PurchasesCommon } from '../src/purchases-common';
import {
  CustomerInfo,
  EntitlementInfo,
  EntitlementInfos,
  ErrorCode,
  LogLevel,
  Offering,
  Package,
  PackageType,
  PeriodUnit,
  Product,
  ProductType,
  PurchaseResult,
  Purchases,
  PurchasesConfig,
  PurchasesError,
  ReservedCustomerAttribute,
  SubscriptionOption,
  VirtualCurrencies,
} from '@revenuecat/purchases-js';
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
    isAnonymous: jest.fn(),
    setAttributes: jest.fn(),
    getVirtualCurrencies: jest.fn(),
    invalidateVirtualCurrenciesCache: jest.fn(),
    getCachedVirtualCurrencies: jest.fn(),
    presentPaywall: jest.fn(),
  };

  const customerInfo: CustomerInfo = {
    entitlements: {
      all: {},
      active: {},
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
    subscriptionsByProductIdentifier: {},
  };

  const mockMonthlyProductSubscriptionOption: SubscriptionOption = {
    id: 'test_monthly_option',
    base: {
      periodDuration: 'P1M',
      period: { number: 1, unit: PeriodUnit.Month },
      price: { amountMicros: 9990000, amount: 999, currency: 'USD', formattedPrice: '$9.99' },
      cycleCount: 0,
      pricePerWeek: {
        amountMicros: 2490000,
        amount: 249,
        currency: 'USD',
        formattedPrice: '$2.49',
      },
      pricePerMonth: {
        amountMicros: 9990000,
        amount: 999,
        currency: 'USD',
        formattedPrice: '$9.99',
      },
      pricePerYear: {
        amountMicros: 11999000,
        amount: 11998,
        currency: 'USD',
        formattedPrice: '$119.98',
      },
    },
    trial: null,
    introPrice: null,
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
    availablePackages: [mockMonthlyPackage],
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
    operationSessionId: 'test_session_id',
    storeTransaction: {
      storeTransactionId: 'test_transaction_id',
      productIdentifier: 'test_product_id',
      purchaseDate: new Date(),
    },
  };

  const mockVirtualCurrencies: VirtualCurrencies = {
    all: {
      GOLD: {
        balance: 100,
        name: 'Gold',
        code: 'GOLD',
        serverDescription: "It's gold",
      },
      SILVER: {
        balance: 50,
        name: 'Silver',
        code: 'SILVER',
        serverDescription: null,
      },
    },
  };

  const mockLocalStorage = {
    getItem: jest.fn(),
    setItem: jest.fn(),
    removeItem: jest.fn(),
    clear: jest.fn(),
  };

  beforeEach(() => {
    if (Purchases.isConfigured()) {
      Purchases.getSharedInstance().close();
    }
    jest.clearAllMocks();
    jest.spyOn(Purchases, 'configure').mockReturnValue(mockPurchasesInstance);
    jest.spyOn(Purchases, 'setPlatformInfo').mockImplementation(() => {});
    jest.spyOn(Purchases, 'generateRevenueCatAnonymousAppUserId').mockReturnValue('anonymous_id');

    Object.defineProperty(global, 'localStorage', {
      value: mockLocalStorage,
      writable: true,
      configurable: true,
    });

    Object.defineProperty(navigator, 'language', {
      value: 'es-US',
      writable: true,
      configurable: true,
    });
  });

  afterEach(() => {
    Object.defineProperty(global, 'localStorage', {
      value: undefined,
      writable: true,
      configurable: true,
    });
  });

  describe('configure', () => {
    it('should use provided appUserId and store it in localStorage', () => {
      const appUserId = 'test_user_id';
      PurchasesCommon.configure({
        apiKey: 'test_api_key',
        appUserId,
        flavor: 'test_flavor',
        flavorVersion: '1.0.0',
      });

      const expectedConfig: PurchasesConfig = {
        apiKey: 'test_api_key',
        appUserId: appUserId,
        httpConfig: undefined,
      };

      expect(Purchases.configure).toHaveBeenCalledWith(expectedConfig);
      expect(mockLocalStorage.setItem).toHaveBeenCalledWith('revenuecat_user_id', appUserId);
    });

    it('should use stored userId from localStorage when appUserId is undefined', () => {
      const storedUserId = 'stored_user_id';
      mockLocalStorage.getItem.mockReturnValue(storedUserId);

      PurchasesCommon.configure({
        apiKey: 'test_api_key',
        appUserId: undefined,
        flavor: 'test_flavor',
        flavorVersion: '1.0.0',
      });

      const expectedConfig: PurchasesConfig = {
        apiKey: 'test_api_key',
        appUserId: storedUserId,
        httpConfig: undefined,
      };

      expect(Purchases.configure).toHaveBeenCalledWith(expectedConfig);
      expect(mockLocalStorage.setItem).not.toHaveBeenCalled();
    });

    it('should generate and store anonymous userId when no userId is provided or stored', () => {
      mockLocalStorage.getItem.mockReturnValue(null);

      PurchasesCommon.configure({
        apiKey: 'test_api_key',
        appUserId: undefined,
        flavor: 'test_flavor',
        flavorVersion: '1.0.0',
      });

      const expectedConfig: PurchasesConfig = {
        apiKey: 'test_api_key',
        appUserId: 'anonymous_id',
        httpConfig: undefined,
      };

      expect(Purchases.configure).toHaveBeenCalledWith(expectedConfig);
      expect(mockLocalStorage.setItem).toHaveBeenCalledWith('revenuecat_user_id', 'anonymous_id');
    });

    it('should handle environment without localStorage gracefully', () => {
      // Remove localStorage to simulate environment without storage
      Object.defineProperty(global, 'localStorage', {
        value: undefined,
        writable: true,
        configurable: true,
      });

      PurchasesCommon.configure({
        apiKey: 'test_api_key',
        appUserId: undefined,
        flavor: 'test_flavor',
        flavorVersion: '1.0.0',
      });

      const expectedConfig: PurchasesConfig = {
        apiKey: 'test_api_key',
        appUserId: 'anonymous_id',
        httpConfig: undefined,
      };

      expect(Purchases.configure).toHaveBeenCalledWith(expectedConfig);
    });
  });

  describe('setAttributes', () => {
    beforeEach(() => {
      purchasesCommon = PurchasesCommon.configure({
        apiKey: 'test_api_key',
        appUserId: 'test_user_id',
        flavor: 'test_flavor',
        flavorVersion: '1.0.0',
      });
    });

    it('should set attributes correctly', async () => {
      const attributes = { key1: 'value1', key2: 'value2' };
      await purchasesCommon.setAttributes(attributes);

      expect(mockPurchasesInstance.setAttributes).toHaveBeenCalledWith(attributes);
    });

    it('should set email correctly', async () => {
      await purchasesCommon.setEmail('test-email');

      expect(mockPurchasesInstance.setAttributes).toHaveBeenCalledWith({
        [ReservedCustomerAttribute.Email]: 'test-email',
      });
    });

    it('should set phone number correctly', async () => {
      await purchasesCommon.setPhoneNumber('test-phone-number');

      expect(mockPurchasesInstance.setAttributes).toHaveBeenCalledWith({
        [ReservedCustomerAttribute.PhoneNumber]: 'test-phone-number',
      });
    });

    it('should set display name correctly', async () => {
      await purchasesCommon.setDisplayName('Test User');

      expect(mockPurchasesInstance.setAttributes).toHaveBeenCalledWith({
        [ReservedCustomerAttribute.DisplayName]: 'Test User',
      });
    });
  });

  describe('purchasePackage', () => {
    beforeEach(() => {
      purchasesCommon = PurchasesCommon.configure({
        apiKey: 'test_api_key',
        appUserId: 'test_user_id',
        flavor: 'test_flavor',
        flavorVersion: '1.0.0',
      });
    });

    it('should throw error when offering identifier is invalid', async () => {
      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: {},
        optionIdentifier: 'test_option',
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
        current: null,
      });

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'non_existent_offering' },
        optionIdentifier: 'test_option',
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.PurchaseInvalidError,
        message:
          'Could not find offering with identifier: non_existent_offering. Found offering ids: ',
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
        current: mockOffering,
      });

      const purchaseParams = {
        packageIdentifier: 'non_existent_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        optionIdentifier: 'test_option',
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.PurchaseInvalidError,
        message:
          'Could not find package with id: non_existent_package in offering with id: test_offering',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      });
    });

    it('should throw error when purchase option is not found', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        optionIdentifier: 'non_existent_option',
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.PurchaseInvalidError,
        message:
          'Could not find option with id: non_existent_option in package with id: test_package',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      });
    });

    it('should successfully complete purchase with option', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.purchase.mockResolvedValue(mockPurchaseResult);

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        optionIdentifier: 'test_monthly_option',
        customerEmail: 'test@example.com',
        selectedLocale: 'es-US',
        defaultLocale: 'en',
      };

      const result = await purchasesCommon.purchasePackage(purchaseParams);
      expect(result).toBeDefined();
      expect(mockPurchasesInstance.purchase).toHaveBeenCalledWith({
        rcPackage: mockOffering.availablePackages[0],
        purchaseOption:
          mockOffering.availablePackages[0].webBillingProduct.subscriptionOptions[
            'test_monthly_option'
          ],
        customerEmail: 'test@example.com',
        selectedLocale: 'es-US',
        defaultLocale: 'en',
      });
    });

    it('should successfully complete purchase without option', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.purchase.mockResolvedValue(mockPurchaseResult);

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        customerEmail: 'test@example.com',
      };

      const result = await purchasesCommon.purchasePackage(purchaseParams);
      expect(result).toBeDefined();
      expect(mockPurchasesInstance.purchase).toHaveBeenCalledWith({
        rcPackage: mockOffering.availablePackages[0],
        purchaseOption: null,
        customerEmail: 'test@example.com',
        selectedLocale: 'es-US',
        defaultLocale: undefined,
      });
    });

    it('should use cached offering if it exists', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.purchase.mockResolvedValue(mockPurchaseResult);

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
        customerEmail: 'test@example.com',
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
        customerEmail: 'test@example.com',
        selectedLocale: 'es-US',
        defaultLocale: undefined,
      });
    });

    it('should handle purchase errors', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      const mockError = new PurchasesError(ErrorCode.UserCancelledError, 'Purchase cancelled');
      mockPurchasesInstance.purchase.mockRejectedValue(mockError);

      const purchaseParams = {
        packageIdentifier: 'test_package',
        presentedOfferingContext: { offeringIdentifier: 'test_offering' },
      };

      await expect(purchasesCommon.purchasePackage(purchaseParams)).rejects.toMatchObject({
        code: ErrorCode.UserCancelledError,
        message: 'Purchase cancelled',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      });
    });
  });

  describe('getVirtualCurrencies', () => {
    it('should successfully get virtual currencies', async () => {
      mockPurchasesInstance.getVirtualCurrencies.mockResolvedValue(mockVirtualCurrencies);

      const result = await purchasesCommon.getVirtualCurrencies();

      expect(result).toEqual({
        all: {
          GOLD: {
            balance: 100,
            name: 'Gold',
            code: 'GOLD',
            serverDescription: "It's gold",
          },
          SILVER: {
            balance: 50,
            name: 'Silver',
            code: 'SILVER',
            serverDescription: null,
          },
        },
      });
      expect(mockPurchasesInstance.getVirtualCurrencies).toHaveBeenCalledTimes(1);
    });

    it('should handle errors from getVirtualCurrencies', async () => {
      const mockError = new PurchasesError(ErrorCode.NetworkError, 'Network error');
      mockPurchasesInstance.getVirtualCurrencies.mockRejectedValue(mockError);

      await expect(purchasesCommon.getVirtualCurrencies()).rejects.toMatchObject({
        code: ErrorCode.NetworkError,
        message: 'Network error',
        info: {
          backendErrorCode: undefined,
          statusCode: undefined,
        },
        underlyingErrorMessage: undefined,
      });
    });
  });

  describe('invalidateVirtualCurrenciesCache', () => {
    it('should call invalidateVirtualCurrenciesCache on purchases instance', () => {
      purchasesCommon.invalidateVirtualCurrenciesCache();

      expect(mockPurchasesInstance.invalidateVirtualCurrenciesCache).toHaveBeenCalledTimes(1);
    });
  });

  describe('getCachedVirtualCurrencies', () => {
    it('should return cached virtual currencies when available', () => {
      mockPurchasesInstance.getCachedVirtualCurrencies.mockReturnValue(mockVirtualCurrencies);

      const result = purchasesCommon.getCachedVirtualCurrencies();

      expect(result).toEqual({
        all: {
          GOLD: {
            balance: 100,
            name: 'Gold',
            code: 'GOLD',
            serverDescription: "It's gold",
          },
          SILVER: {
            balance: 50,
            name: 'Silver',
            code: 'SILVER',
            serverDescription: null,
          },
        },
      });
      expect(mockPurchasesInstance.getCachedVirtualCurrencies).toHaveBeenCalledTimes(1);
    });

    it('should return null when no cached virtual currencies are available', () => {
      mockPurchasesInstance.getCachedVirtualCurrencies.mockReturnValue(null);

      const result = purchasesCommon.getCachedVirtualCurrencies();

      expect(result).toBeNull();
      expect(mockPurchasesInstance.getCachedVirtualCurrencies).toHaveBeenCalledTimes(1);
    });
  });

  describe('setLogHandler', () => {
    let mockLogHandler: jest.Mock;
    let mockPurchasesSetLogHandler: jest.Mock;

    beforeEach(() => {
      mockLogHandler = jest.fn();
      mockPurchasesSetLogHandler = jest.fn();
      jest.spyOn(Purchases, 'setLogHandler').mockImplementation(mockPurchasesSetLogHandler);
    });

    it('should delegate to Purchases.setLogHandler with correct mapping for all log levels', () => {
      PurchasesCommon.setLogHandler(mockLogHandler);

      expect(mockPurchasesSetLogHandler).toHaveBeenCalledTimes(1);

      // Get the wrapper function that was passed to Purchases.setLogHandler
      const wrapperFunction = mockPurchasesSetLogHandler.mock.calls[0][0];
      expect(typeof wrapperFunction).toBe('function');

      // Test all log levels
      const testCases = [
        { logLevel: LogLevel.Verbose, expectedString: 'VERBOSE' },
        { logLevel: LogLevel.Debug, expectedString: 'DEBUG' },
        { logLevel: LogLevel.Info, expectedString: 'INFO' },
        { logLevel: LogLevel.Warn, expectedString: 'WARN' },
        { logLevel: LogLevel.Error, expectedString: 'ERROR' },
        { logLevel: LogLevel.Silent, expectedString: 'SILENT' },
      ];

      testCases.forEach(({ logLevel, expectedString }) => {
        const testMessage = `Test message for ${expectedString}`;
        wrapperFunction(logLevel, testMessage);

        expect(mockLogHandler).toHaveBeenCalledWith(expectedString, testMessage);
      });

      expect(mockLogHandler).toHaveBeenCalledTimes(testCases.length);
    });

    it('should ignore unknown log levels', () => {
      PurchasesCommon.setLogHandler(mockLogHandler);

      const wrapperFunction = mockPurchasesSetLogHandler.mock.calls[0][0];

      // Test with an unknown log level (using a number that's not in the enum)
      wrapperFunction(999 as LogLevel, 'Test message');

      // The custom log handler should not be called for unknown log levels
      expect(mockLogHandler).not.toHaveBeenCalled();
    });

    it('should handle multiple log messages correctly', () => {
      PurchasesCommon.setLogHandler(mockLogHandler);

      const wrapperFunction = mockPurchasesSetLogHandler.mock.calls[0][0];

      // Send multiple log messages
      wrapperFunction(LogLevel.Info, 'First message');
      wrapperFunction(LogLevel.Error, 'Second message');
      wrapperFunction(LogLevel.Debug, 'Third message');

      expect(mockLogHandler).toHaveBeenCalledTimes(3);
      expect(mockLogHandler).toHaveBeenNthCalledWith(1, 'INFO', 'First message');
      expect(mockLogHandler).toHaveBeenNthCalledWith(2, 'ERROR', 'Second message');
      expect(mockLogHandler).toHaveBeenNthCalledWith(3, 'DEBUG', 'Third message');
    });

    it('should work with different custom log handler implementations', () => {
      const customLogHandler1 = jest.fn();
      const customLogHandler2 = jest.fn();

      // Test first handler
      PurchasesCommon.setLogHandler(customLogHandler1);
      const wrapperFunction1 = mockPurchasesSetLogHandler.mock.calls[0][0];
      wrapperFunction1(LogLevel.Info, 'Test message 1');
      expect(customLogHandler1).toHaveBeenCalledWith('INFO', 'Test message 1');

      // Reset mocks
      mockPurchasesSetLogHandler.mockClear();
      customLogHandler1.mockClear();

      // Test second handler
      PurchasesCommon.setLogHandler(customLogHandler2);
      const wrapperFunction2 = mockPurchasesSetLogHandler.mock.calls[0][0];
      wrapperFunction2(LogLevel.Error, 'Test message 2');
      expect(customLogHandler2).toHaveBeenCalledWith('ERROR', 'Test message 2');
    });
  });

  describe('presentPaywall', () => {
    beforeEach(() => {
      purchasesCommon = PurchasesCommon.configure({
        apiKey: 'test_api_key',
        appUserId: 'test_user_id',
        flavor: 'test_flavor',
        flavorVersion: '1.0.0',
      });
    });

    it('should return PURCHASED when paywall completes successfully', async () => {
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      const result = await purchasesCommon.presentPaywall({});

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: undefined,
        customerEmail: undefined,
      });
    });

    it('should return USER_CANCELLED when user cancels', async () => {
      const mockError = new PurchasesError(ErrorCode.UserCancelledError, 'User cancelled');
      mockPurchasesInstance.presentPaywall.mockRejectedValue(mockError);

      const result = await purchasesCommon.presentPaywall({});

      expect(result).toBe('USER_CANCELLED');
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: undefined,
        customerEmail: undefined,
      });
    });

    it('should return ERROR when PurchasesError with non-cancel error occurs', async () => {
      const mockError = new PurchasesError(ErrorCode.NetworkError, 'Network error');
      mockPurchasesInstance.presentPaywall.mockRejectedValue(mockError);

      const result = await purchasesCommon.presentPaywall({});

      expect(result).toBe('ERROR');
    });

    it('should return ERROR when generic error occurs', async () => {
      const mockError = new Error('Something went wrong');
      mockPurchasesInstance.presentPaywall.mockRejectedValue(mockError);

      const result = await purchasesCommon.presentPaywall({});

      expect(result).toBe('ERROR');
    });

    it('should pass offering from cache when offeringIdentifier provided', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      await purchasesCommon.getOfferings();
      const result = await purchasesCommon.presentPaywall({
        offeringIdentifier: 'test_offering',
      });

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: mockOffering,
        customerEmail: undefined,
      });
    });

    it('should pass customerEmail when provided', async () => {
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      const result = await purchasesCommon.presentPaywall({
        customerEmail: 'test@example.com',
      });

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: undefined,
        customerEmail: 'test@example.com',
      });
    });

    it('should apply presentedOfferingContext to offering when both provided', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      await purchasesCommon.getOfferings();
      const result = await purchasesCommon.presentPaywall({
        offeringIdentifier: 'test_offering',
        presentedOfferingContext: {
          offeringIdentifier: 'test_offering',
          placementIdentifier: 'test_placement',
          targetingContext: {
            revision: 5,
            ruleId: 'test_rule',
          },
        },
      });

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalled();

      const calledOffering = mockPurchasesInstance.presentPaywall.mock.calls[0][0].offering;
      expect(calledOffering).toBeDefined();
      expect(calledOffering!.identifier).toBe('test_offering');

      // Check that presentedOfferingContext was applied to all packages
      expect(
        calledOffering!.availablePackages[0].webBillingProduct.presentedOfferingContext,
      ).toEqual({
        offeringIdentifier: 'test_offering',
        placementIdentifier: 'test_placement',
        targetingContext: {
          revision: 5,
          ruleId: 'test_rule',
        },
      });

      // Check that helper accessors were updated
      expect(calledOffering!.monthly!.webBillingProduct.presentedOfferingContext).toEqual({
        offeringIdentifier: 'test_offering',
        placementIdentifier: 'test_placement',
        targetingContext: {
          revision: 5,
          ruleId: 'test_rule',
        },
      });

      // Check that packagesById was updated
      expect(
        calledOffering!.packagesById['test_package'].webBillingProduct.presentedOfferingContext,
      ).toEqual({
        offeringIdentifier: 'test_offering',
        placementIdentifier: 'test_placement',
        targetingContext: {
          revision: 5,
          ruleId: 'test_rule',
        },
      });
    });

    it('should handle presentedOfferingContext without placementIdentifier', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      await purchasesCommon.getOfferings();
      const result = await purchasesCommon.presentPaywall({
        offeringIdentifier: 'test_offering',
        presentedOfferingContext: {
          offeringIdentifier: 'test_offering',
        },
      });

      expect(result).toBe('PURCHASED');
      const calledOffering = mockPurchasesInstance.presentPaywall.mock.calls[0][0].offering;
      expect(
        calledOffering!.availablePackages[0].webBillingProduct.presentedOfferingContext,
      ).toEqual({
        offeringIdentifier: 'test_offering',
        placementIdentifier: null,
        targetingContext: null,
      });
    });

    it('should handle presentedOfferingContext with incomplete targetingContext', async () => {
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      await purchasesCommon.getOfferings();
      const result = await purchasesCommon.presentPaywall({
        offeringIdentifier: 'test_offering',
        presentedOfferingContext: {
          offeringIdentifier: 'test_offering',
          targetingContext: {
            revision: 5,
            // missing ruleId
          },
        },
      });

      expect(result).toBe('PURCHASED');
      const calledOffering = mockPurchasesInstance.presentPaywall.mock.calls[0][0].offering;
      expect(
        calledOffering!.availablePackages[0].webBillingProduct.presentedOfferingContext,
      ).toEqual({
        offeringIdentifier: 'test_offering',
        placementIdentifier: null,
        targetingContext: null,
      });
    });

    it('should fetch offering from SDK when not in cache and apply presentedOfferingContext', async () => {
      // Offering not in cache initially
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      const result = await purchasesCommon.presentPaywall({
        offeringIdentifier: 'test_offering',
        presentedOfferingContext: {
          offeringIdentifier: 'test_offering',
          placementIdentifier: 'test_placement',
          targetingContext: {
            revision: 5,
            ruleId: 'test_rule',
          },
        },
      });

      expect(result).toBe('PURCHASED');
      // Verify that getOfferings was called to fetch from SDK
      expect(mockPurchasesInstance.getOfferings).toHaveBeenCalledTimes(1);

      const calledOffering = mockPurchasesInstance.presentPaywall.mock.calls[0][0].offering;
      expect(calledOffering).toBeDefined();
      expect(calledOffering!.identifier).toBe('test_offering');

      // Verify presentedOfferingContext was applied to the fetched offering
      expect(
        calledOffering!.availablePackages[0].webBillingProduct.presentedOfferingContext,
      ).toEqual({
        offeringIdentifier: 'test_offering',
        placementIdentifier: 'test_placement',
        targetingContext: {
          revision: 5,
          ruleId: 'test_rule',
        },
      });
    });

    it('should handle when offering is not found in cache or SDK', async () => {
      // Offering not in cache or SDK
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: {},
        current: null,
      });
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      const result = await purchasesCommon.presentPaywall({
        offeringIdentifier: 'non_existent_offering',
        presentedOfferingContext: {
          offeringIdentifier: 'non_existent_offering',
          placementIdentifier: 'test_placement',
        },
      });

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.getOfferings).toHaveBeenCalledTimes(1);
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: undefined,
        customerEmail: undefined,
      });
    });

    it('should return NOT_PRESENTED when requiredEntitlementIdentifier is active', async () => {
      const mockEntitlementInfo: EntitlementInfo = {
        identifier: 'premium',
        isActive: true,
        willRenew: true,
        periodType: 'normal',
        latestPurchaseDate: new Date(),
        originalPurchaseDate: new Date(),
        expirationDate: new Date(Date.now() + 86400000),
        store: 'app_store',
        productIdentifier: 'premium_product',
        productPlanIdentifier: null,
        isSandbox: false,
        unsubscribeDetectedAt: null,
        billingIssueDetectedAt: null,
        ownershipType: 'PURCHASED',
      };
      const mockCustomerInfoWithEntitlement: CustomerInfo = {
        ...customerInfo,
        entitlements: {
          all: {
            premium: mockEntitlementInfo
          },
          active: {
            premium: mockEntitlementInfo,
          },
        },
      };

      mockPurchasesInstance.getCustomerInfo.mockResolvedValue(mockCustomerInfoWithEntitlement);

      const result = await purchasesCommon.presentPaywall({
        requiredEntitlementIdentifier: 'premium',
      });

      expect(result).toBe('NOT_PRESENTED');
      expect(mockPurchasesInstance.getCustomerInfo).toHaveBeenCalledTimes(1);
      expect(mockPurchasesInstance.presentPaywall).not.toHaveBeenCalled();
    });

    it('should present paywall when requiredEntitlementIdentifier is not active', async () => {
      const mockCustomerInfoWithoutEntitlement: CustomerInfo = {
        ...customerInfo,
        entitlements: {
          all: {},
          active: {},
        } as EntitlementInfos,
      };

      mockPurchasesInstance.getCustomerInfo.mockResolvedValue(mockCustomerInfoWithoutEntitlement);
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      const result = await purchasesCommon.presentPaywall({
        requiredEntitlementIdentifier: 'premium',
      });

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.getCustomerInfo).toHaveBeenCalledTimes(1);
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: undefined,
        customerEmail: undefined,
      });
    });

    it('should present paywall when requiredEntitlementIdentifier exists but is inactive', async () => {
      const mockCustomerInfoWithInactiveEntitlement: CustomerInfo = {
        ...customerInfo,
        entitlements: {
          all: {
            premium: {
              identifier: 'premium',
              isActive: false,
              willRenew: false,
              periodType: 'normal',
              latestPurchaseDate: new Date(),
              originalPurchaseDate: new Date(),
              expirationDate: new Date(Date.now() - 86400000),
              store: 'app_store',
              productIdentifier: 'premium_product',
              isSandbox: false,
              unsubscribeDetectedAt: null,
              billingIssueDetectedAt: null,
              ownershipType: 'PURCHASED',
            },
          },
          active: {},
        } as EntitlementInfos,
      };

      mockPurchasesInstance.getCustomerInfo.mockResolvedValue(
        mockCustomerInfoWithInactiveEntitlement,
      );
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      const result = await purchasesCommon.presentPaywall({
        requiredEntitlementIdentifier: 'premium',
      });

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.getCustomerInfo).toHaveBeenCalledTimes(1);
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: undefined,
        customerEmail: undefined,
      });
    });

    it('should combine requiredEntitlementIdentifier check with offeringIdentifier and presentedOfferingContext', async () => {
      const mockCustomerInfoWithoutEntitlement: CustomerInfo = {
        ...customerInfo,
        entitlements: {
          all: {},
          active: {},
        } as EntitlementInfos,
      };

      mockPurchasesInstance.getCustomerInfo.mockResolvedValue(mockCustomerInfoWithoutEntitlement);
      mockPurchasesInstance.getOfferings.mockResolvedValue({
        all: { test_offering: mockOffering },
        current: mockOffering,
      });
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      await purchasesCommon.getOfferings();
      const result = await purchasesCommon.presentPaywall({
        requiredEntitlementIdentifier: 'premium',
        offeringIdentifier: 'test_offering',
        presentedOfferingContext: {
          offeringIdentifier: 'test_offering',
          placementIdentifier: 'test_placement',
        },
        customerEmail: 'test@example.com',
      });

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.getCustomerInfo).toHaveBeenCalledTimes(1);

      const calledOffering = mockPurchasesInstance.presentPaywall.mock.calls[0][0].offering;
      expect(calledOffering).toBeDefined();
      expect(calledOffering!.identifier).toBe('test_offering');
      expect(
        calledOffering!.availablePackages[0].webBillingProduct.presentedOfferingContext
          .placementIdentifier,
      ).toBe('test_placement');

      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: expect.any(Object),
        customerEmail: 'test@example.com',
      });
    });

    it('should not call getCustomerInfo when requiredEntitlementIdentifier is not provided', async () => {
      mockPurchasesInstance.presentPaywall.mockResolvedValue(mockPurchaseResult);

      const result = await purchasesCommon.presentPaywall({
        customerEmail: 'test@example.com',
      });

      expect(result).toBe('PURCHASED');
      expect(mockPurchasesInstance.getCustomerInfo).not.toHaveBeenCalled();
      expect(mockPurchasesInstance.presentPaywall).toHaveBeenCalledWith({
        offering: undefined,
        customerEmail: 'test@example.com',
      });
    });
  });
});
