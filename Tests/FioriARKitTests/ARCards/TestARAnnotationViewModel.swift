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
        ARAnnotationViewModel<TestCardItem>(arManager: ARManager(canBeFatal: false))
    }
    
    func testInit() {
        let vm = self.makeViewModelSUT()
        
        XCTAssertNil(vm.anchorPosition)
        XCTAssertNil(vm.currentAnnotation)
        XCTAssertTrue(vm.annotations.isEmpty)
        XCTAssertFalse(vm.discoveryFlowHasFinished)
    }
    
    func testCleanUpSession() throws {
        let vm = self.makeViewModelSUT()
        vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))
        
        XCTAssertNotNil(vm.arManager.arView)
        XCTAssertFalse(vm.annotations.isEmpty)
        XCTAssertNotNil(vm.currentAnnotation)
        
        vm.cleanUpSession()
        
        XCTAssertNil(vm.arManager.arView)
        XCTAssertTrue(vm.annotations.isEmpty)
        XCTAssertNil(vm.currentAnnotation)
    }
    
    func testLoad() throws {
        let vm = self.makeViewModelSUT()
        vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))
        
        XCTAssertFalse(vm.annotations.isEmpty)
        XCTAssertEqual(vm.annotations.count, 6)
        
        let first = try XCTUnwrap(vm.annotations.first)
        
        XCTAssertEqual(first.card.id, "WasherFluid")
        XCTAssertEqual(first.card.title_, "Recommended Washer Fluid")
        XCTAssertEqual(first.card.subtitle_, "Rain X")
        XCTAssertNil(first.card.detailImage_)
        XCTAssertNil(first.card.actionText_)
        XCTAssertNil(first.card.icon_)
    }
    
    func testSetMarkerVisibility() throws {
        let vm = self.makeViewModelSUT()
        vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))
        
        let first = try XCTUnwrap(vm.annotations.first)
        XCTAssertFalse(first.isMarkerVisible)
        vm.setMarkerVisibility(for: first.id, to: true)
        let firstCopy = try XCTUnwrap(vm.annotations.first)
        XCTAssertTrue(firstCopy.isMarkerVisible)
    }
    
    static var allTests = [
        ("testInitialization", testInit),
        ("testLoad", testLoad),
        ("testCleanUpSession", testCleanUpSession)
    ]
}
