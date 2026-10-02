//
//  CommonFunctionality+OfferingTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@_spi(Internal) @testable import PurchasesHybridCommon
@_spi(Internal) @testable import RevenueCat

class CommonFunctionalityOfferingTests: QuickSpec {

    private static let currentIdentifier = "current_offering"
    private static let otherIdentifier = "other_offering"

    private static func offering(withIdentifier identifier: String) -> RevenueCat.Offering {
        return .init(
            identifier: identifier,
            serverDescription: "",
            metadata: [:],
            availablePackages: [
                .init(identifier: "monthly",
                      packageType: .monthly,
                      storeProduct: TestStoreProduct(
                          localizedTitle: "Test Product",
                          price: 9.99,
                          localizedPriceString: "$9.99",
                          productIdentifier: "test_product_id",
                          productType: .autoRenewableSubscription,
                          localizedDescription: "Test product description"
                      ).toStoreProduct(),
                      offeringIdentifier: identifier,
                      webCheckoutUrl: nil)
            ],
            webCheckoutUrl: nil
        )
    }

    /// `Offerings.current` is computed as `all[currentOfferingID]?.copyWith(targeting:)`, so supplying
    /// a targeting value makes it genuinely differ from `all[currentIdentifier]`, the same way a real
    /// targeted response does. Nothing here fakes the asymmetry.
    private static func offerings() throws -> Offerings {
        let response = try JSONDecoder.default.decode(
            OfferingsResponse.self,
            from: Data(#"{"current_offering_id": null, "offerings": []}"#.utf8)
        )

        return .init(
            offerings: [
                Self.currentIdentifier: Self.offering(withIdentifier: Self.currentIdentifier),
                Self.otherIdentifier: Self.offering(withIdentifier: Self.otherIdentifier)
            ],
            currentOfferingID: Self.currentIdentifier,
            placements: nil,
            targeting: .init(revision: 2, ruleId: "test_rule"),
            contents: .init(response: response, httpResponseOriginalSource: .mainServer),
            loadedFromDiskCache: false
        )
    }

    private static func targetingContext(of dictionary: [String: Any]?) -> [String: Any]? {
        let packages = dictionary?["availablePackages"] as? [[String: Any]]
        let context = packages?.first?["presentedOfferingContext"] as? [String: Any]
        return context?["targetingContext"] as? [String: Any]
    }

    override func spec() {
        describe("getOffering") {
            var mockPurchases: MockPurchases!

            beforeEach {
                mockPurchases = MockPurchases()
                CommonFunctionality.sharedInstance = mockPurchases
            }

            it("returns the current offering with its targeting context") {
                let offerings = try Self.offerings()

                var received: [String: Any]?
                CommonFunctionality.getOffering(forIdentifier: Self.currentIdentifier) { dictionary, _ in
                    received = dictionary
                }
                mockPurchases.invokedOfferingsParameters?.completion(offerings, nil)

                // Must equal `current`, not `all[identifier]`. Those differ only by the targeting
                // context, which is what a purchase needs to attribute to the experiment.
                expect(NSDictionary(dictionary: try XCTUnwrap(received)))
                    == NSDictionary(dictionary: try XCTUnwrap(offerings.current?.dictionary))
                expect(Self.targetingContext(of: received)?["revision"] as? Int) == 2
                expect(Self.targetingContext(of: received)?["ruleId"] as? String) == "test_rule"
                expect(Self.targetingContext(of: offerings.all[Self.currentIdentifier]?.dictionary)).to(beNil())
            }

            it("returns the catalog entry for an offering that is not current") {
                let offerings = try Self.offerings()

                var received: [String: Any]?
                CommonFunctionality.getOffering(forIdentifier: Self.otherIdentifier) { dictionary, _ in
                    received = dictionary
                }
                mockPurchases.invokedOfferingsParameters?.completion(offerings, nil)

                expect(NSDictionary(dictionary: try XCTUnwrap(received)))
                    == NSDictionary(dictionary: try XCTUnwrap(offerings.all[Self.otherIdentifier]?.dictionary))
                expect(Self.targetingContext(of: received)).to(beNil())
            }

            it("returns nil for an unknown identifier") {
                let offerings = try Self.offerings()

                var completionCalled = false
                var received: [String: Any]?
                var receivedError: ErrorContainer?
                CommonFunctionality.getOffering(forIdentifier: "doesnt exist") { dictionary, error in
                    completionCalled = true
                    received = dictionary
                    receivedError = error
                }
                mockPurchases.invokedOfferingsParameters?.completion(offerings, nil)

                expect(completionCalled) == true
                expect(received).to(beNil())
                expect(receivedError).to(beNil())
            }
        }
    }
}
