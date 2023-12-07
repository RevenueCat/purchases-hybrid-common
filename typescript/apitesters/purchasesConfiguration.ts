import { PurchasesConfiguration } from "../dist";
import { ENTITLEMENT_VERIFICATION_MODE } from "../src";

function checkPurchasesConfiguration(configuration: PurchasesConfiguration) {
    const apiKey: string = configuration.apiKey;
    const appUserID: string | null | undefined = configuration.appUserID;
    const observerMode: boolean | undefined = configuration.observerMode;
    const userDefaultsSuiteName: string | undefined = configuration.userDefaultsSuiteName;
    const usesStoreKit2IfAvailable: boolean | undefined = configuration.usesStoreKit2IfAvailable;
    const useAmazon: boolean | undefined = configuration.useAmazon;
    const shouldShowInAppMessagesAutomatically: boolean | undefined = configuration.shouldShowInAppMessagesAutomatically;
    const entitlementVerificationMode: ENTITLEMENT_VERIFICATION_MODE | undefined = configuration.entitlementVerificationMode;
    const configuration2: PurchasesConfiguration = {
        apiKey: apiKey,
        appUserID: appUserID,
        observerMode: observerMode,
        userDefaultsSuiteName: userDefaultsSuiteName,
        usesStoreKit2IfAvailable: usesStoreKit2IfAvailable,
        useAmazon: useAmazon,
        shouldShowInAppMessagesAutomatically: shouldShowInAppMessagesAutomatically,
        entitlementVerificationMode: entitlementVerificationMode
    } 
    const configuration3: PurchasesConfiguration = {
        apiKey: apiKey
    } 
}