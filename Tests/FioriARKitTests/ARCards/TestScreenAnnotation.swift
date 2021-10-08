//
//  TestScreenAnnotation.swift
//  FioriARKit
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriARKit
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
        let cardItemTwo = TestCardItem(id: "2", title_: "Test Card 2", descriptionText_: nil, detailImage_: nil, actionText_: nil, icon_: "arkit")
        let screenAnnotation = ScreenAnnotation(card: cardItemTwo)
        return screenAnnotation
    }

    func testScreenAnnotationInit() {
        let screenAnnotation = self.makeScreenAnnotationSUT()
        XCTAssertEqual(screenAnnotation.id, screenAnnotation.card.id)
        XCTAssertNil(screenAnnotation.icon)
        XCTAssertTrue(screenAnnotation.isCardVisible)
        XCTAssertFalse(screenAnnotation.isMarkerVisible)
        
        let screenAnnotationTwo = self.makeScreenAnnotationTwoSUT()
        XCTAssertNotNil(screenAnnotationTwo.icon)
    }
    
    func testSetters() {
        var screenAnnotation = self.makeScreenAnnotationSUT()
        XCTAssertTrue(screenAnnotation.isCardVisible)
        XCTAssertFalse(screenAnnotation.isMarkerVisible)
        
        screenAnnotation.setCardVisibility(to: false)
        XCTAssertFalse(screenAnnotation.isCardVisible)
        
        screenAnnotation.setCardVisibility(to: true)
        XCTAssertTrue(screenAnnotation.isCardVisible)
        
        screenAnnotation.setMarkerVisibility(to: true)
        XCTAssertTrue(screenAnnotation.isMarkerVisible)
        
        screenAnnotation.setMarkerVisibility(to: false)
        XCTAssertFalse(screenAnnotation.isMarkerVisible)
    }
    
    func testMarkerAnchor() {
        let screenAnnotation = self.makeScreenAnnotationSUT()
        let entity = Entity()
        entity.name = "TestEntity"
        
        screenAnnotation.setInternalEntity(with: entity)
        XCTAssertEqual(screenAnnotation.marker.internalEnitity.name, "TestEntity")
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
        ("testMarkerAnchor", testMarkerAnchor),
        ("testEquality", testEquality)
    ]
}
