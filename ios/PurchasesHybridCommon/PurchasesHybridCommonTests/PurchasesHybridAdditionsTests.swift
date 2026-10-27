//
//  PurchasesHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 5/12/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import RevenueCat
@testable import PurchasesHybridCommon

class PurchasesHybridAdditionsTests: QuickSpec {
    override func spec() {
        context("configure with user defaults suite name") {
            it("initializes without raising exceptions if no suite name is passed") {
                expect {
                    Purchases.configure(apiKey: "api key",
                                        appUserID: nil,
                                        purchasesAreCompletedBy: "REVENUECAT",
                                        userDefaultsSuiteName: nil,
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        storeKitVersion: "DEFAULT",
                                        dangerousSettings: nil)
                }.toNot(beNil())
            }
            it("initializes without raising exceptions if a suite name is passed") {
                expect {
                    Purchases.configure(apiKey: "api key",
                                        appUserID: nil,
                                        purchasesAreCompletedBy: "REVENUECAT",
                                        userDefaultsSuiteName: "test",
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        storeKitVersion: "DEFAULT",
                                        dangerousSettings: nil)
                }.toNot(beNil())
            }
        }
        context("configure with verification mode") {
            it("disabled") {
                expect {
                    Purchases.configure(apiKey: "api key",
                                        appUserID: nil,
                                        purchasesAreCompletedBy: "REVENUECAT",
                                        userDefaultsSuiteName: "test",
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        storeKitVersion: "DEFAULT",
                                        dangerousSettings: nil,
                                        verificationMode: "DISABLED")
                }.toNot(beNil())
            }

            it("informational") {
                expect {
                    Purchases.configure(apiKey: "api key",
                                        appUserID: nil,
                                        purchasesAreCompletedBy: "REVENUECAT",
                                        userDefaultsSuiteName: "test",
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        storeKitVersion: "DEFAULT",
                                        dangerousSettings: nil,
                                        verificationMode: "INFORMATIONAL")
                }.toNot(beNil())
            }
            it("enforced") {
                expect {
                    Purchases.configure(apiKey: "api key",
                                        appUserID: nil,
                                        purchasesAreCompletedBy: "REVENUECAT",
                                        userDefaultsSuiteName: "test",
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        storeKitVersion: "DEFAULT",
                                        dangerousSettings: nil,
                                        verificationMode: "ENFORCED")
                }.toNot(beNil())
            }
        }
        context("configure with dangerous settings") {
            it("initializes without raising exceptions if dangerous settings is passed") {
                expect {
                    Purchases.configure(apiKey: "api key",
                                        appUserID: nil,
                                        purchasesAreCompletedBy: "REVENUECAT",
                                        userDefaultsSuiteName: "test",
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        storeKitVersion: "DEFAULT",
                                        dangerousSettings: DangerousSettings(autoSyncPurchases: false))
                }.toNot(beNil())
            }
        }

        context("configure with StoreKit version") {
                    it("DEFAULT") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "DEFAULT",
                                                dangerousSettings: nil)
                        }.toNot(beNil())
                    }

                    it("STOREKIT_2") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "STOREKIT_2",
                                                dangerousSettings: nil)
                        }.toNot(beNil())
                    }
                    it("STOREKIT_1") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "STOREKIT_1",
                                                dangerousSettings: nil)
                        }.toNot(beNil())
                    }
                }

        context("configure with PurchasesAreCompletedBy") {
                    it("REVENUECAT") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "DEFAULT",
                                                dangerousSettings: nil)
                        }.toNot(beNil())

                        expect(Purchases.shared.purchasesAreCompletedBy).to(equal(PurchasesAreCompletedBy.revenueCat))
                    }

                    it("MY_APP") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "MY_APP",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "STOREKIT_2",
                                                dangerousSettings: nil)
                        }.toNot(beNil())

                        expect(Purchases.shared.purchasesAreCompletedBy).to(equal(PurchasesAreCompletedBy.myApp))
                    }
                    it("missing") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "STOREKIT_1",
                                                dangerousSettings: nil)
                        }.toNot(beNil())

                        expect(Purchases.shared.purchasesAreCompletedBy).to(equal(PurchasesAreCompletedBy.revenueCat))
                    }
                }

        context("configure with automaticDeviceIdentifierCollectionEnabled") {
                    it("true") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "DEFAULT",
                                                dangerousSettings: nil,
                                                verificationMode: "INFORMATIONAL",
                                                automaticDeviceIdentifierCollectionEnabled: true)
                        }.toNot(beNil())
                    }

                    it("false") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "DEFAULT",
                                                dangerousSettings: nil,
                                                verificationMode: "INFORMATIONAL",
                                                automaticDeviceIdentifierCollectionEnabled: false)
                        }.toNot(beNil())
                    }
                    it("not passed") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "DEFAULT",
                                                dangerousSettings: nil,
                                                verificationMode: "INFORMATIONAL")
                        }.toNot(beNil())
                    }

                    func unsyncedAttributeKeysAfterSettingAdjustID(
                        automaticDeviceIdentifierCollectionEnabled: Bool
                    ) -> Set<String> {
                        let purchases = Purchases.configure(apiKey: "api key",
                                                            appUserID: nil,
                                                            purchasesAreCompletedBy: "REVENUECAT",
                                                            userDefaultsSuiteName: UUID().uuidString,
                                                            platformFlavor: "hybrid-platform",
                                                            platformFlavorVersion: "1.2.3",
                                                            dangerousSettings: nil,
                                                            verificationMode: nil,
                                                            automaticDeviceIdentifierCollectionEnabled:
                                                                automaticDeviceIdentifierCollectionEnabled,
                                                            useExternalPurchaseCustomLinks: false,
                                                            enableExternalPurchasesInSimulator: true)
                        purchases.attribution.setAdjustID("adjust-id")
                        return Set(purchases.attribution.unsyncedAttributesByKey(appUserID: purchases.appUserID).keys)
                    }

                    it("collects device identifiers when true") {
                        let keys = unsyncedAttributeKeysAfterSettingAdjustID(
                            automaticDeviceIdentifierCollectionEnabled: true
                        )
                        expect(keys).to(contain("$adjustId", "$ip"))
                    }

                    it("does not collect device identifiers when false") {
                        let keys = unsyncedAttributeKeysAfterSettingAdjustID(
                            automaticDeviceIdentifierCollectionEnabled: false
                        )
                        expect(keys).to(contain("$adjustId"))
                        expect(keys.intersection(["$ip", "$idfv", "$idfa", "$deviceVersion"])).to(beEmpty())
                    }
                }

        context("configure with useExternalPurchaseCustomLinks") {
                    it("true") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "DEFAULT",
                                                dangerousSettings: nil,
                                                verificationMode: nil,
                                                preferredLocale: nil,
                                                useExternalPurchaseCustomLinks: true,
                                                enableExternalPurchasesInSimulator: false)
                        }.toNot(beNil())
                    }

                    it("false") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "DEFAULT",
                                                dangerousSettings: nil,
                                                verificationMode: nil,
                                                preferredLocale: nil,
                                                useExternalPurchaseCustomLinks: false,
                                                enableExternalPurchasesInSimulator: true)
                        }.toNot(beNil())
                    }
                    it("not passed") {
                        expect {
                            Purchases.configure(apiKey: "api key",
                                                appUserID: nil,
                                                purchasesAreCompletedBy: "REVENUECAT",
                                                userDefaultsSuiteName: "test",
                                                platformFlavor: "hybrid-platform",
                                                platformFlavorVersion: "1.2.3",
                                                storeKitVersion: "DEFAULT",
                                                dangerousSettings: nil,
                                                verificationMode: nil)
                        }.toNot(beNil())
                    }
                }
    }
}
