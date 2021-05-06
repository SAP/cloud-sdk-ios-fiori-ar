// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import FioriARKit

final class FioriARKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FioriARKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
