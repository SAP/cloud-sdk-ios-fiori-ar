//
//  TestMarkerAnchor.swift
//  FioriARKit
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriARKit
import RealityKit
import SwiftUI
import XCTest

final class TestMarkerAnchor: XCTestCase {
    func makeMarkerAnchorSUT() -> EntityManager {
        EntityManager()
    }
    
    func getModelComponent(markerAnchor: EntityManager) -> ModelComponent? {
        markerAnchor.internalEnitity.components[ModelComponent.self] as? ModelComponent
    }
    
    func testInit() throws {
        let markerAnchor = self.makeMarkerAnchorSUT()
        XCTAssertNotNil(markerAnchor)
        XCTAssertNotNil(markerAnchor.internalEnitity)
        
        let componentwithSimpleMaterial = try XCTUnwrap(getModelComponent(markerAnchor: markerAnchor))
        let simpleMaterial = try XCTUnwrap(componentwithSimpleMaterial.materials.first)
        XCTAssertTrue(simpleMaterial is SimpleMaterial)
    }

    func testHideInternalEntity() throws {
        let markerAnchor = self.makeMarkerAnchorSUT()
        
        let componentwithSimpleMaterial = try XCTUnwrap(getModelComponent(markerAnchor: markerAnchor))
        let simpleMaterial = try XCTUnwrap(componentwithSimpleMaterial.materials.first)
        XCTAssertTrue(simpleMaterial is SimpleMaterial)
        
        markerAnchor.hideInternalEntity()
        
        let componentWithOcclusionMaterial = try XCTUnwrap(getModelComponent(markerAnchor: markerAnchor))
        let occlusionMaterial = try XCTUnwrap(componentWithOcclusionMaterial.materials.first)
        XCTAssertTrue(occlusionMaterial is OcclusionMaterial)
    }
    
    static var allTests = [
        ("testInit", testInit),
        ("testHideInternalEntity", testHideInternalEntity)
    ]
}
