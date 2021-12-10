//
//  TestARAnnotationViewModel.swift
//  FioriAR
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriAR
import RealityKit
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

    func testResetAllAnchors() throws {
        let vm = self.makeViewModelSUT()
        try vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))

        XCTAssertNotNil(vm.arManager.arView)
        XCTAssertFalse(vm.annotations.isEmpty)
        XCTAssertNotNil(vm.currentAnnotation)

        vm.resetAllAnchors()

        XCTAssertNotNil(vm.arManager.arView)
        XCTAssertNil(vm.arManager.sceneRoot)
        XCTAssertTrue(vm.annotations.isEmpty)
    }

    func testStopSession() throws {
        let vm = self.makeViewModelSUT()
        try vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))

        XCTAssertNotNil(vm.arManager.arView)
        XCTAssertFalse(vm.annotations.isEmpty)
        XCTAssertNotNil(vm.currentAnnotation)

        vm.stopSession()

        XCTAssertNil(vm.arManager.arView)
        XCTAssertTrue(vm.annotations.isEmpty)
        XCTAssertNil(vm.currentAnnotation)
    }

    func testLoad() throws {
        let vm = self.makeViewModelSUT()
        try vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))

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

    func testSetMarkerState() throws {
        let vm = self.makeViewModelSUT()
        try vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))

        let first = try XCTUnwrap(vm.annotations.first)
        XCTAssertEqual(first.markerState, .selected)
        vm.setMarkerState(for: first.card, to: .normal)
        let firstCopy = try XCTUnwrap(vm.annotations.first)
        XCTAssertEqual(firstCopy.markerState, .normal)
        vm.setMarkerState(for: firstCopy.card, to: .ghost)
        let secondCopy = try XCTUnwrap(vm.annotations.first)
        XCTAssertEqual(secondCopy.markerState, .ghost)
    }

    func testNewEntity() throws {
        let vm = self.makeViewModelSUT()
        try vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))
        vm.annotations[0].setEntity(to: nil)
        let first = try XCTUnwrap(vm.annotations.first)
        XCTAssertNil(first.entity)
        vm.addNewEntity(to: first.card)
        let firstCopy = try XCTUnwrap(vm.annotations.first)
        XCTAssertNotNil(firstCopy.entity)
    }

    func testDropEntity() throws {
        let vm = self.makeViewModelSUT()
        try vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))
        vm.annotations[0].setEntity(to: nil)
        let testCard = try XCTUnwrap(vm.annotations.first?.card)

        vm.addNewEntity(to: testCard)
        let parent = vm.annotations.first?.entity?.parent
        let cameraAnchor = try XCTUnwrap(vm.arManager.findEntity(named: AnchorEntity.cameraAnchor))
        XCTAssertEqual(parent, cameraAnchor)

        vm.dropEntity(for: testCard)
        let newParent = vm.annotations.first?.entity?.parent
        let sceneRoot = try XCTUnwrap(vm.arManager.sceneRoot)
        XCTAssertEqual(newParent, sceneRoot)

        vm.deleteCameraAnchor()
        XCTAssertNil(vm.arManager.findEntity(named: AnchorEntity.cameraAnchor))
    }

    func testDeleteEntity() throws {
        let vm = self.makeViewModelSUT()
        try vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))

        let first = try XCTUnwrap(vm.annotations.first)
        XCTAssertNotNil(first.entity
        )
        vm.deleteEntity(for: first.card)
        let firstCopy = try XCTUnwrap(vm.annotations.first)
        XCTAssertNil(firstCopy.entity)
    }

    func testRemoveEntityFromScene() throws {
        let vm = self.makeViewModelSUT()
        try vm.load(loadingStrategy: MockLoadingStrategy(cardContents: TestsItems.carEngineCardItems))

        let anchor = AnchorEntity()
        let sceneRoot = try XCTUnwrap(vm.arManager.sceneRoot)
        anchor.addChild(sceneRoot)
        vm.arManager.arView?.scene.addAnchor(anchor)
        XCTAssertNotNil(vm.annotations.first?.entity?.scene)

        vm.removeEntitiesFromScene()
        XCTAssertNil(vm.annotations.first?.entity?.scene)
    }

    static var allTests = [
        ("testInit", testInit),
        ("testResetAllAnchors", testResetAllAnchors),
        ("testStopSession", testStopSession),
        ("testSetMarkerState", testSetMarkerState),
        ("testNewEntity", testNewEntity),
        ("testDropEntity", testDropEntity),
        ("testDeleteEntity", testDeleteEntity),
        ("testRemoveEntityFromScene", testRemoveEntityFromScene)
    ]
}
