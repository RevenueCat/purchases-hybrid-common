import PurchasesHybridCommon
import PurchasesHybridCommonUI
import RevenueCat
import RevenueCatUI
import XCTest

final class InstallationTests: XCTestCase {

    @MainActor
    func testGitSourcedInstallation() {
        // Configuration and reading the app user ID do not require backend credentials.
        _ = Purchases.configure(
            apiKey: "appl_cocoapods_smoke_test",
            appUserID: "cocoapods-smoke-test",
            purchasesAreCompletedBy: "REVENUECAT",
            userDefaultsSuiteName: UUID().uuidString,
            platformFlavor: "cocoapods-smoke-test",
            platformFlavorVersion: CommonFunctionality.hybridCommonVersion,
            dangerousSettings: nil,
            verificationMode: nil,
            useExternalPurchaseCustomLinks: false,
            enableExternalPurchasesInSimulator: false,
            iamEnabled: false,
            keychainAccessGroup: nil
        )

        XCTAssertTrue(Purchases.isConfigured)
        XCTAssertEqual(CommonFunctionality.appUserID, "cocoapods-smoke-test")
        XCTAssertFalse(CommonFunctionality.isAnonymous)
        XCTAssertNotNil(Bundle.main.url(forResource: "PurchasesHybridCommon", withExtension: "bundle"))
        XCTAssertNotNil(Bundle.main.url(forResource: "RevenueCat_RevenueCatUI", withExtension: "bundle"))
    }

}
