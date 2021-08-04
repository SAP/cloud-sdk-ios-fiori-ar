import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(TestARAnnotationViewModel.allTests),
            testCase(TestARManager.allTests),
            testCase(TestCardItemModels.allTests),
            testCase(TestLoadingStrategies.allTests),
            testCase(TestMarkerAnchor.allTests),
            testCase(TestRCScanner.allTests),
            testCase(TestScreenAnnotation.allTests)
        ]
    }
#endif
