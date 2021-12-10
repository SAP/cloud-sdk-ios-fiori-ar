//
//  TestScreenAnnotation.swift
//  FioriAR
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriAR
import RealityKit
import SwiftUI
import XCTest

final class TestScreenAnnotation: XCTestCase {
    func makeScreenAnnotationSUT() -> ScreenAnnotation<TestCardItem> {
        let cardItem = TestCardItem(id: "1", title_: "Test Card 1")
        let screenAnnotation = ScreenAnnotation(card: cardItem)
        return screenAnnotation
    }
    
    func makeScreenAnnotationTwoSUT() -> ScreenAnnotation<TestCardItem> {
        let cardItemTwo = TestCardItem(id: "2", title_: "Test Card 2", subtitle_: nil, detailImage_: nil, actionText_: nil, icon_: "arkit")
        let screenAnnotation = ScreenAnnotation(card: cardItemTwo)
        return screenAnnotation
    }

    func testScreenAnnotationInit() {
        let screenAnnotation = self.makeScreenAnnotationSUT()
        XCTAssertEqual(screenAnnotation.id, screenAnnotation.card.id)
        XCTAssertNil(screenAnnotation.card.icon_)
        XCTAssertFalse(screenAnnotation.isCardVisible)
        XCTAssertEqual(screenAnnotation.markerState, .notVisible)
        
        let screenAnnotationTwo = self.makeScreenAnnotationTwoSUT()
        XCTAssertNotNil(screenAnnotationTwo.card.icon_)
    }
    
    func testSetters() throws {
        var screenAnnotation = self.makeScreenAnnotationSUT()
        
        screenAnnotation.setMarkerState(to: .world)
        XCTAssertEqual(screenAnnotation.markerState, .world)
        
        let entity = Entity()
        entity.name = "TestEntity"
        screenAnnotation.setEntity(to: entity)
        XCTAssertNotNil(screenAnnotation.entity)
        let unwrappedEntity = try XCTUnwrap(screenAnnotation.entity)
        XCTAssertEqual(unwrappedEntity.name, "TestEntity")
        
        let screenPosition = CGPoint(x: 2, y: 5)
        screenAnnotation.setScreenPosition(to: screenPosition)
        XCTAssertEqual(screenAnnotation.screenPosition, screenPosition)
    }
    
    func testEquality() {
        let screenAnnotation = self.makeScreenAnnotationSUT()
        let screenAnnotationCopy = self.makeScreenAnnotationSUT()
        XCTAssertEqual(screenAnnotation, screenAnnotationCopy)
        
        let screenAnnotationTwo = self.makeScreenAnnotationTwoSUT()
        XCTAssertNotEqual(screenAnnotation, screenAnnotationTwo)
    }
    
    static var allTests = [
        ("testScreenAnnotationInitializer", testScreenAnnotationInit),
        ("testSetters", testSetters),
        ("testEquality", testEquality)
    ]
}
