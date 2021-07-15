//
//  TestCardItemModels.swift
//  FioriARKit
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriARKit
import SwiftUI
import XCTest

final class TestCardItemModels: XCTestCase {
    func testCardItemModelConformance() {
        let testModel = TestCardItem(id: "1",
                                     title_: "TestTitle1",
                                     descriptionText_: nil,
                                     detailImage_: nil,
                                     actionText_: nil,
                                     icon_: nil)
        
        let testModelWithoutNil = TestCardItem(id: "2",
                                               title_: "TestTitle2",
                                               descriptionText_: "DescriptionText",
                                               detailImage_: Image(systemName: "arkit"),
                                               actionText_: "Tap",
                                               icon_: Image(systemName: "arkit"))
        
        XCTAssertEqual(testModel.id, "1")
        XCTAssertEqual(testModel.title_, "TestTitle1")
        XCTAssertNil(testModel.descriptionText_)
        XCTAssertNil(testModel.detailImage_)
        XCTAssertNil(testModel.actionText_)
        XCTAssertNil(testModel.icon_)
        
        XCTAssertEqual(testModelWithoutNil.id, "2")
        XCTAssertEqual(testModelWithoutNil.title_, "TestTitle2")
        XCTAssertEqual(testModelWithoutNil.descriptionText_, "DescriptionText")
        XCTAssertNotNil(testModelWithoutNil.detailImage_, "TestTitle2")
        XCTAssertEqual(testModelWithoutNil.actionText_, "Tap")
        XCTAssertNotNil(testModelWithoutNil.icon_)
    }

    func testJSONExtraction() throws {
        let jsonUrl = try XCTUnwrap(Bundle.module.url(forResource: "Tests", withExtension: "json"))
        let jsonData = try Data(contentsOf: jsonUrl)
        let decodedCardItems = try JSONDecoder().decode([DecodableCardItem].self, from: jsonData)
        
        let firstCardItem = try XCTUnwrap(decodedCardItems.first)
        
        XCTAssertEqual(decodedCardItems.count, 6)
        XCTAssertTrue((firstCardItem as Any) is DecodableCardItem)
    }
    
    func testJSONExtractionData() throws {
        let jsonUrl = try XCTUnwrap(Bundle.module.url(forResource: "Tests", withExtension: "json"))
        let jsonData = try Data(contentsOf: jsonUrl)
        let decodedCardItems = try JSONDecoder().decode([DecodableCardItem].self, from: jsonData)
        
        let firstCardItem = try XCTUnwrap(decodedCardItems.first)
        
        XCTAssertEqual(firstCardItem.id, "WasherFluid")
        XCTAssertEqual(firstCardItem.title_, "Recommended Washer Fluid")
        XCTAssertEqual(firstCardItem.descriptionText_, "Rain X")
        XCTAssertNil(firstCardItem.detailImage_)
        XCTAssertNil(firstCardItem.actionText_)
        XCTAssertNil(firstCardItem.icon_)
    }

    static var allTests = [
        ("testCardItemModelConformance", testCardItemModelConformance),
        ("testJSONExtraction", testJSONExtraction),
        ("testJSONExtractionData", testJSONExtractionData)
    ]
}
