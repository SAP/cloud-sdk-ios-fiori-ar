//
//  TestLoadingStrategy.swift
//
//
//  Created by O'Brien, Patrick on 7/16/21.
//

@testable import FioriARKit
import RealityKit
import SwiftUI

public struct TestLoadingStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy where CardItem.ID: LosslessStringConvertible {
    public var cardContents: [CardItem]

    public init(cardContents: [CardItem]) {
        self.cardContents = cardContents
    }
    
    public func load(with manager: ARManagement) throws -> [ScreenAnnotation<CardItem>] {
        var annotations = [ScreenAnnotation<CardItem>]()
        let url = Bundle.module.url(forResource: "Test", withExtension: "usdz")!
        let anchorEntity = try RCScanner.Scene.loadAnchor(contentsOf: url)
        
        for cardItem in self.cardContents {
            guard let internalEntity = anchorEntity.findEntity(named: String(cardItem.id)) else {
                throw LoadingStrategyError.entityNotFoundError(cardItem.id)
            }
            let annotation = ScreenAnnotation(card: cardItem)
            annotation.setInternalEntity(with: internalEntity)
            annotations.append(annotation)
        }
        
        return annotations
    }
}
