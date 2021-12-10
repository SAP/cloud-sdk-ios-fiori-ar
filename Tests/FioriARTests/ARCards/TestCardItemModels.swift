//
//  TestCardItemModels.swift
//  FioriAR
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriAR
import SwiftUI
import XCTest

final class TestCardItemModels: XCTestCase {
    func testCardItemModelConformance() {
        let testModel = TestCardItem(id: "1",
                                     title_: "TestTitle1",
                                     subtitle_: nil,
                                     detailImage_: nil,
                                     actionText_: nil,
                                     actionContentURL_: nil,
                                     icon_: nil)
        
        let testModelWithoutNil = TestCardItem(id: "2",
                                               title_: "TestTitle2",
                                               subtitle_: "Subtitle",
                                               detailImage_: UIImage(systemName: "arkit")?.pngData(),
                                               actionText_: "Tap",
                                               actionContentURL_: URL(string: "www.google.com"),
                                               icon_: "arkit")
        
        XCTAssertEqual(testModel.id, "1")
        XCTAssertEqual(testModel.title_, "TestTitle1")
        XCTAssertNil(testModel.subtitle_)
        XCTAssertNil(testModel.detailImage_)
        XCTAssertNil(testModel.actionText_)
        XCTAssertNil(testModel.actionContentURL_)
        XCTAssertNil(testModel.icon_)
        
        XCTAssertEqual(testModelWithoutNil.id, "2")
        XCTAssertEqual(testModelWithoutNil.title_, "TestTitle2")
        XCTAssertEqual(testModelWithoutNil.subtitle_, "Subtitle")
        XCTAssertNotNil(testModelWithoutNil.detailImage_, "TestTitle2")
        XCTAssertEqual(testModelWithoutNil.actionText_, "Tap")
        XCTAssertNotNil(testModelWithoutNil.actionContentURL_)
        XCTAssertNotNil(testModelWithoutNil.icon_)
    }

    func testJSONExtraction() throws {
        let jsonUrl = try XCTUnwrap(Bundle.module.url(forResource: "TestItems", withExtension: "json"))
        let jsonData = try Data(contentsOf: jsonUrl)
        let decodedCardItems = try JSONDecoder().decode([CodableCardItem].self, from: jsonData)
        
        let firstCardItem = try XCTUnwrap(decodedCardItems.first)
        
        XCTAssertEqual(decodedCardItems.count, 6)
        XCTAssertTrue((firstCardItem as Any) is CodableCardItem)
    }
    
    func testJSONExtractionData() throws {
        let jsonUrl = try XCTUnwrap(Bundle.module.url(forResource: "TestItems", withExtension: "json"))
        let jsonData = try Data(contentsOf: jsonUrl)
        let decodedCardItems = try JSONDecoder().decode([CodableCardItem].self, from: jsonData)
        
        let firstCardItem = try XCTUnwrap(decodedCardItems.first)
        
        XCTAssertEqual(firstCardItem.id, "WasherFluid")
        XCTAssertEqual(firstCardItem.title_, "Recommended Washer Fluid")
        XCTAssertEqual(firstCardItem.subtitle_, "Rain X")
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
