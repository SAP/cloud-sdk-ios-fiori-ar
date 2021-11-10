//
//  TestRCScanner.swift
//
//
//  Created by O'Brien, Patrick on 8/2/21.
//

@testable import FioriAR
import RealityKit
import SwiftUI
import XCTest

final class TestRCScanner: XCTestCase {
    func testLoadRealityScene() throws {
        let testRealityUrl = try XCTUnwrap(Bundle.module.url(forResource: "Test", withExtension: "reality"))
        let sceneAnchor = try RCScanner.loadSceneFromRealityFile(realityFileURL: testRealityUrl, sceneName: "TestScene")
        let rcScene = try XCTUnwrap(sceneAnchor.findEntity(named: "Scene"))
        _ = try XCTUnwrap(rcScene.findEntity(named: "Oilstick"))
    }
    
    //   accessing anchoring variable on AnchorEntity returned from loadAnchor(contentsOf:) causes fatal crash when using usdz file
    //   Issue Reported to apple
    
//    func testLoadUsdzScene() throws {
//        let testUsdzUrl = try XCTUnwrap(Bundle.module.url(forResource: "Test", withExtension: "usdz"))
//        let sceneAnchor = try RCScanner.loadSceneFromUsdzFile(usdzFileURL: testUsdzUrl)
//
//        let rcScene = try XCTUnwrap(sceneAnchor.findEntity(named: "Scene"))
//        let _ = try XCTUnwrap(rcScene.findEntity(named: "Oilstick"))
//    }
    
    static var allTests = [
        ("testLoadRealityScene", testLoadRealityScene)
        // ("testLoadUsdzScene", testLoadUsdzScene)
    ]
}
