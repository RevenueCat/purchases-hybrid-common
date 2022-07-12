//
//  MockSandboxEnvironmentDetector.swift
//  PurchasesHybridCommonTests
//
//  Created by Joshua Liebowitz on 7/12/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

@testable import RevenueCat

final class MockSandboxEnvironmentDetector: SandboxEnvironmentDetector {

    init(isSandbox: Bool = true) {
        self.isSandbox = isSandbox
    }

    let isSandbox: Bool

}
