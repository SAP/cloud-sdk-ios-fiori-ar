//
//  TestLoadingStrategy.swift
//
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriAR
import RealityKit
import SwiftUI
import XCTest

public struct MockLoadingStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy where CardItem.ID: LosslessStringConvertible {
    public var cardContents: [CardItem]

    public init(cardContents: [CardItem]) {
        self.cardContents = cardContents
    }
    
    public func load(with manager: ARManager) throws -> (annotations: [ScreenAnnotation<CardItem>], guideImage: UIImage?) {
        var annotations = [ScreenAnnotation<CardItem>]()
        let uiImageUrl = try XCTUnwrap(Bundle.module.url(forResource: "qrImage", withExtension: "png"))
        let absPath = try XCTUnwrap(URL(string: "file://" + uiImageUrl.path))
        let guideImage = try XCTUnwrap(UIImage(contentsOfFile: absPath.path))
        let usdzURL = try XCTUnwrap(Bundle.module.url(forResource: "Test", withExtension: "usdz"))
        let anchorEntity = try RCScanner.Scene.loadAnchor(contentsOf: usdzURL)
        
        manager.sceneRoot = Entity()
        manager.addReferenceImage(for: guideImage, with: 0.1, resetImages: true)
        
        for cardItem in self.cardContents {
            guard let internalEntity = anchorEntity.findEntity(named: String(cardItem.id)) else {
                throw LoadingStrategyError.entityNotFoundError(cardItem.id)
            }
            var annotation = ScreenAnnotation(card: cardItem)
            annotation.setEntity(to: internalEntity)
            manager.sceneRoot?.addChild(internalEntity)
            annotations.append(annotation)
        }
        
        return (annotations, guideImage)
    }
}
