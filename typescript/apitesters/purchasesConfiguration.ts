import { PurchasesConfiguration } from "../dist";
import { ENTITLEMENT_VERIFICATION_MODE, STOREKIT_VERSION } from "../src";

function checkPurchasesConfiguration(configuration: PurchasesConfiguration) {
    const apiKey: string = configuration.apiKey;
    const appUserID: string | null | undefined = configuration.appUserID;
    const observerMode: boolean | undefined = configuration.observerMode;
    const userDefaultsSuiteName: string | undefined = configuration.userDefaultsSuiteName;
    const storeKitVersion: STOREKIT_VERSION | undefined = configuration.storeKitVersion;
    const useAmazon: boolean | undefined = configuration.useAmazon;
    const shouldShowInAppMessagesAutomatically: boolean | undefined = configuration.shouldShowInAppMessagesAutomatically;
    const entitlementVerificationMode: ENTITLEMENT_VERIFICATION_MODE | undefined = configuration.entitlementVerificationMode;
    const configuration2: PurchasesConfiguration = {
        apiKey: apiKey,
        appUserID: appUserID,
        observerMode: observerMode,
        userDefaultsSuiteName: userDefaultsSuiteName,
        storeKitVersion: storeKitVersion,
        useAmazon: useAmazon,
        shouldShowInAppMessagesAutomatically: shouldShowInAppMessagesAutomatically,
        entitlementVerificationMode: entitlementVerificationMode
    }
    const configuration3: PurchasesConfiguration = {
        apiKey: apiKey
    }
}