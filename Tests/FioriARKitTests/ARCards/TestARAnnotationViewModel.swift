//
//  TestARAnnotationViewModel.swift
//  FioriARKit
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriARKit
import SwiftUI
import XCTest

final class TestARAnnotationViewModel: XCTestCase {
    func makeViewModelSUT() -> ARAnnotationViewModel<TestCardItem> {
        let vm = ARAnnotationViewModel<TestCardItem>()
        return vm
    }
    
    func testInitialization() {
        let vm = self.makeViewModelSUT()
        
        XCTAssertNil(vm.anchorPosition)
        XCTAssertNil(vm.currentAnnotation)
        XCTAssertTrue(vm.annotations.isEmpty)
        XCTAssertFalse(vm.discoveryFlowHasFinished)
    }
    
    func testLoad() throws {
        let vm = self.makeViewModelSUT()
        let testStrategy = TestLoadingStrategy(cardContents: TestsItems.carEngineCardItems)
        vm.load(loadingStrategy: testStrategy)
        
        XCTAssertFalse(vm.annotations.isEmpty)
    }
    
    func testCleanUpSession() throws {
        let vm = self.makeViewModelSUT()
        let testStrategy = TestLoadingStrategy(cardContents: TestsItems.carEngineCardItems)
        vm.load(loadingStrategy: testStrategy)
        
        XCTAssertNotNil(vm.arManager.arView)
        XCTAssertFalse(vm.annotations.isEmpty)
        XCTAssertNotNil(vm.currentAnnotation)
        
        vm.cleanUpSession()
        
        XCTAssertNil(vm.arManager.arView)
        XCTAssertTrue(vm.annotations.isEmpty)
        XCTAssertNil(vm.currentAnnotation)
    }
    
    static var allTests = [
        ("testInitialization", testInitialization),
        ("testLoad", testLoad),
        ("testCleanUpSession", testCleanUpSession)
    ]
}
