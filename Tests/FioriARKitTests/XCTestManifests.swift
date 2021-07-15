import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(TestCardItemModels.allTests),
            testCase(TestARAnnotationViewModel.allTests),
            testCase(TestARManager.allTests),
            testCase(TestScreenAnnotation.allTests)
        ]
    }
#endif
