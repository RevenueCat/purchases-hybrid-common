//
//  XCTestCase+Expectations.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 4/20/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import XCTest
@testable import PurchasesHybridCommon

extension XCTestCase {

    func expectFatalError(
        expectedMessage: String,
        testcase: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = self.expectation(description: "expectingFatalError")
        var fatalErrorReceived = false
        var assertionMessage: String?

        FatalErrorUtil.replaceFatalError { message, _, _ in
            fatalErrorReceived = true
            assertionMessage = message
            expectation.fulfill()
            self.unreachable()
        }

        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)

        waitForExpectations(timeout: 2) { _ in
            XCTAssert(fatalErrorReceived, "fatalError wasn't received", file: file, line: line)
            XCTAssertEqual(assertionMessage, expectedMessage, file: file, line: line)

            FatalErrorUtil.restoreFatalError()
        }
    }

    func expectNoFatalError(
        testcase: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = self.expectation(description: "expectingNoFatalError")
        var fatalErrorReceived = false

        FatalErrorUtil.replaceFatalError { _, _, _ in
            fatalErrorReceived = true
            self.unreachable()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            testcase()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2) { _ in
            XCTAssert(!fatalErrorReceived, "fatalError was received", file: file, line: line)
            FatalErrorUtil.restoreFatalError()
        }
    }

}

/// Similar to `XCTUnrap` but it allows an `async` closure.
func XCTAsyncUnwrap<T>(
    _ expression: @autoclosure () async throws -> T?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async throws -> T {
    let value = try await expression()

    return try XCTUnwrap(
        value,
        message(),
        file: file,
        line: line
    )
}

private extension XCTestCase {

    func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while (true)
    }

}
