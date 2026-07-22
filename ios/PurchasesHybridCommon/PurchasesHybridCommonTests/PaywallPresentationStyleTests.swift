//
//  PaywallPresentationStyleTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Quick
import Nimble
import UIKit
@testable import PurchasesHybridCommonUI

@available(iOS 15.0, *)
class PaywallPresentationStyleTests: QuickSpec {

    override func spec() {

        func resolve(_ options: [String: Any]) -> UIModalPresentationStyle {
            PaywallProxy.PaywallPresentationParams.resolveModalPresentationStyle(from: options)
        }

        let presentationMode = PaywallProxy.PaywallOptionsKeys.presentationMode
        let useFullScreenPresentation = PaywallProxy.PaywallOptionsKeys.useFullScreenPresentation

        describe("resolveModalPresentationStyle") {

            context("when presentationMode is provided") {
                it("maps recognized tokens to the matching style") {
                    expect(resolve([presentationMode: "fullScreen"])) == .fullScreen
                    expect(resolve([presentationMode: "formSheet"])) == .formSheet
                    expect(resolve([presentationMode: "automatic"])) == .automatic
                    expect(resolve([presentationMode: "pageSheet"])) == .pageSheet
                }

                it("is case-insensitive") {
                    expect(resolve([presentationMode: "FULLSCREEN"])) == .fullScreen
                    expect(resolve([presentationMode: "FormSheet"])) == .formSheet
                }

                it("accepts \"sheet\" as an alias for pageSheet") {
                    expect(resolve([presentationMode: "sheet"])) == .pageSheet
                }

                it("takes precedence over the legacy useFullScreenPresentation flag") {
                    expect(resolve([presentationMode: "formSheet",
                                    useFullScreenPresentation: true])) == .formSheet
                }

                context("when the value is unrecognized") {
                    it("falls back to the legacy flag") {
                        expect(resolve([presentationMode: "banana",
                                        useFullScreenPresentation: true])) == .fullScreen
                    }

                    it("defaults to pageSheet when no legacy flag is set") {
                        expect(resolve([presentationMode: "banana"])) == .pageSheet
                    }
                }

                context("when the value is not a String") {
                    it("falls back to the legacy flag") {
                        expect(resolve([presentationMode: 42])) == .pageSheet
                    }
                }
            }

            context("when presentationMode is absent") {
                it("uses fullScreen when useFullScreenPresentation is true") {
                    expect(resolve([useFullScreenPresentation: true])) == .fullScreen
                }

                it("uses pageSheet when useFullScreenPresentation is false") {
                    expect(resolve([useFullScreenPresentation: false])) == .pageSheet
                }

                it("defaults to pageSheet when neither key is present (backwards compatibility)") {
                    expect(resolve([:])) == .pageSheet
                }
            }
        }
    }
}

#endif
