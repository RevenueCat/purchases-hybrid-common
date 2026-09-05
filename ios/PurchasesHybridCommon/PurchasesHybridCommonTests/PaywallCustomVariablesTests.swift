//
//  PaywallCustomVariablesTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Quick
import Nimble
import RevenueCatUI
import UIKit
@testable import PurchasesHybridCommonUI

@available(iOS 15.0, *)
class PaywallCustomVariablesTests: QuickSpec {

    override func spec() {

        func value(_ raw: Any) -> CustomVariableValue? {
            PaywallCustomVariables.value(from: raw)
        }

        describe("value(from:)") {

            // Hybrid SDKs (Flutter, React Native, Capacitor, Unity) hand values over as
            // `[String: Any]`. Every scalar has crossed the Objective-C bridge by then, so
            // numbers and booleans both arrive as `NSNumber`. These cases mirror that.
            context("when the value is a number that crossed the Objective-C bridge") {
                it("keeps 1 as a number, not a boolean") {
                    expect(value(NSNumber(value: 1))) == .number(1)
                }

                it("keeps 0 as a number, not a boolean") {
                    expect(value(NSNumber(value: 0))) == .number(0)
                }

                it("keeps integers other than 0 and 1 as numbers") {
                    expect(value(NSNumber(value: 2))) == .number(2)
                    expect(value(NSNumber(value: -1))) == .number(-1)
                }

                it("keeps doubles as numbers") {
                    expect(value(NSNumber(value: 1.0))) == .number(1)
                    expect(value(NSNumber(value: 2.5))) == .number(2.5)
                }
            }

            context("when the value is a boolean that crossed the Objective-C bridge") {
                it("maps true to a boolean") {
                    expect(value(NSNumber(value: true))) == .bool(true)
                }

                it("maps false to a boolean") {
                    expect(value(NSNumber(value: false))) == .bool(false)
                }
            }

            context("when the value is a native Swift scalar") {
                it("maps Bool to a boolean") {
                    expect(value(true)) == .bool(true)
                    expect(value(false)) == .bool(false)
                }

                it("maps Int and Double to numbers") {
                    expect(value(1)) == .number(1)
                    expect(value(0)) == .number(0)
                    expect(value(3.25)) == .number(3.25)
                }
            }

            context("when the value is a string") {
                it("keeps it as a string, even when it looks numeric") {
                    expect(value("1")) == .string("1")
                    expect(value("true")) == .string("true")
                    expect(value(NSString(string: "GPS Max"))) == .string("GPS Max")
                }
            }

            context("when the value is not a string, number or boolean") {
                it("returns nil so the variable is skipped") {
                    expect(value(Date())).to(beNil())
                    expect(value([1, 2])).to(beNil())
                    expect(value(["nested": 1])).to(beNil())
                }
            }
        }

        describe("createPaywallView(params:)") {
            it("applies the bridged custom variables to the controller with their bridged types") {
                let params = PaywallViewCreationParams()
                params.customVariables = [
                    "gps_max": NSNumber(value: 1),
                    "is_pro": NSNumber(value: true),
                    "tier": "premium",
                ]

                let controller = PaywallProxy().createPaywallView(params: params)

                expect(controller.customVariables) == [
                    "gps_max": .number(1),
                    "is_pro": .bool(true),
                    "tier": .string("premium"),
                ]
            }

            it("skips unsupported values and keeps the rest") {
                let params = PaywallViewCreationParams()
                params.customVariables = [
                    "when": Date(),
                    "count": NSNumber(value: 3),
                ]

                let controller = PaywallProxy().createPaywallView(params: params)

                expect(controller.customVariables) == ["count": .number(3)]
            }
        }
    }
}

#endif
