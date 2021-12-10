//
//  TestARManager.swift
//  FioriAR
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriAR
import RealityKit
import SwiftUI
import XCTest

final class TestARManager: XCTestCase {
    func makeARManagerSUT() -> ARManager {
        ARManager(canBeFatal: false)
    }
    
    func testInit() {
        let manager = self.makeARManagerSUT()
        
        XCTAssertNil(manager.worldMap)
        XCTAssertTrue(manager.referenceImages.isEmpty)
        XCTAssertTrue(manager.detectionObjects.isEmpty)
        XCTAssertNotNil(manager.arView)
        XCTAssertNotNil(manager.subscription)
    }
    
    func testTearDown() {
        let manager = self.makeARManagerSUT()
        
        XCTAssertNotNil(manager.arView)
        XCTAssertNotNil(manager.subscription)
        
        manager.tearDown()
        
        XCTAssertNil(manager.arView)
        XCTAssertNil(manager.subscription)
    }
    
    func testAddAnchor() throws {
        let manager = self.makeARManagerSUT()
        let arViewAnchors = try XCTUnwrap(manager.arView?.scene.anchors)
        
        XCTAssertTrue(arViewAnchors.isEmpty)
        manager.addAnchor(anchor: AnchorEntity())
        XCTAssertFalse(arViewAnchors.isEmpty)
    }
    
    func testAddReferenceImage() throws {
        let manager = self.makeARManagerSUT()
        let uiImageUrl = try XCTUnwrap(Bundle.module.url(forResource: "qrImage", withExtension: "png"))
        let absPath = try XCTUnwrap(URL(string: "file://" + uiImageUrl.path))
        let uiImage = try XCTUnwrap(UIImage(contentsOfFile: absPath.path))
        
        XCTAssertTrue(manager.referenceImages.isEmpty)
        manager.addReferenceImage(for: uiImage, "TestImage", with: 0.1)
        XCTAssertFalse(manager.referenceImages.isEmpty)
        
        let referenceImage = try XCTUnwrap(manager.referenceImages.first)
        XCTAssertEqual(referenceImage.name, "TestImage")
    }
    
    static var allTests = [
        ("testInit", testInit),
        ("testTearDown", testTearDown),
        ("testAddAnchor", testAddAnchor),
        ("testAddReferenceImage", testAddReferenceImage)
    ]
}
