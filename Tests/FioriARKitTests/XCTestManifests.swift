import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(FioriARKitTests.allTests)
        ]
    }
#endif
