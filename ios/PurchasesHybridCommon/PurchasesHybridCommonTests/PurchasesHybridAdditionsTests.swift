//
//  PurchasesHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 5/12/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
import RevenueCat
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
                }.notTo(raiseException())
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
                }.notTo(raiseException())
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
                }.notTo(raiseException())
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
                }.notTo(raiseException())
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
                }.notTo(raiseException())
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
                }.notTo(raiseException())
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
                        }.notTo(raiseException())
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
                        }.notTo(raiseException())
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
                        }.notTo(raiseException())
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
                        }.notTo(raiseException())

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
                        }.notTo(raiseException())

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
                        }.notTo(raiseException())

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
                        }.notTo(raiseException())
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
                        }.notTo(raiseException())
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
                        }.notTo(raiseException())
                    }
                }
    }
}
