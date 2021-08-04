//
//  TestLoadingStrategies.swift
//
//
//  Created by O'Brien, Patrick on 8/2/21.
//

@testable import FioriARKit
import RealityKit
import SwiftUI
import XCTest

final class TestLoadingStrategies: XCTestCase {
    func makeARManagerSUT() -> ARManager {
        // Note:
        // The strategies may need to process data into the manager which is why its passed in
        // If the stratey conforms to SceneLoadable then the ARManager.setupScene method will have no effect when ran on simulator, but the ScreenAnnotations will still be returned
        ARManager()
    }
    
    // RCProjectStrategy searches in main bundle for the reality file that the .rcproject provides, thoughts on testing?
//    func testRCProjectStrategyCardItemLoad() throws {
//        let manager = makeARManagerSUT()
//        let realityStrategy = RCProjectStrategy(cardContents: TestsItems.carEngineCardItems, rcFile: "???", rcScene: "???")
//        let annotations = try realityStrategy.load(with: manager)
//
//        let first = try XCTUnwrap(annotations.first)
//
//        XCTAssertEqual(annotations.count, 6)
//    }
    
    func testRealityFileStrategyCardItemLoad() throws {
        let manager = self.makeARManagerSUT()
        let testRealityUrl = try XCTUnwrap(Bundle.module.url(forResource: "Test", withExtension: "reality"))
        let realityStrategy = RealityFileStrategy(cardContents: TestsItems.carEngineCardItems, realityFilePath: testRealityUrl, rcScene: "TestScene")
        let annotations = try realityStrategy.load(with: manager)
        
        let first = try XCTUnwrap(annotations.first)
        
        XCTAssertEqual(annotations.count, 6)
        XCTAssertEqual(first.card.id, "WasherFluid")
        XCTAssertEqual(first.card.title_, "Recommended Washer Fluid")
        XCTAssertEqual(first.card.descriptionText_, "Rain X")
        XCTAssertNil(first.card.detailImage_)
        XCTAssertNil(first.card.actionText_)
        XCTAssertNil(first.card.icon_)
        XCTAssertNotNil(first.marker)
        XCTAssertNotNil(first.marker.internalEnitity)
    }
    
    func testRealityFileStrategyJSONLoad() throws {
        let manager = self.makeARManagerSUT()
        let testRealityUrl = try XCTUnwrap(Bundle.module.url(forResource: "Test", withExtension: "reality"))
        let jsonUrl = try XCTUnwrap(Bundle.module.url(forResource: "TestItems", withExtension: "json"))
        let jsonData = try Data(contentsOf: jsonUrl)

        let realityStrategy = try RealityFileStrategy(jsonData: jsonData, realityFilePath: testRealityUrl, rcScene: "TestScene")
        let annotations = try realityStrategy.load(with: manager)
        
        let first = try XCTUnwrap(annotations.first)
        
        XCTAssertEqual(annotations.count, 6)
        XCTAssertEqual(first.card.id, "WasherFluid")
        XCTAssertEqual(first.card.title_, "Recommended Washer Fluid")
        XCTAssertEqual(first.card.descriptionText_, "Rain X")
        XCTAssertNil(first.card.detailImage_)
        XCTAssertNil(first.card.actionText_)
        XCTAssertNil(first.card.icon_)
        XCTAssertNotNil(first.marker)
        XCTAssertNotNil(first.marker.internalEnitity)
    }
    
    static var allTests = [
        ("testRealityFileStrategyCardItemInit", testRealityFileStrategyCardItemLoad),
        ("testRealityFileStrategyJSONInit", testRealityFileStrategyJSONLoad)
    ]
}
