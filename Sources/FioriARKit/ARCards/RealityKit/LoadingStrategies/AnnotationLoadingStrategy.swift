//
//  AnnotationLoadingStrategy.swift
//
//
//  Created by O'Brien, Patrick on 9/24/21.
//

import ARKit
import RealityKit

/// Protocol which defines the data a strategy needs to provide a `[ScreenAnnotation]`
public protocol AnnotationLoadingStrategy {
    associatedtype CardItem: CardItemModel
    var cardContents: [CardItem] { get }
    func load(with manager: ARManager) throws -> [ScreenAnnotation<CardItem>]
}

internal protocol SceneLoadable where CardItem.ID: LosslessStringConvertible {
    associatedtype CardItem: CardItemModel

    func syncCardContentsWithScene(manager: ARManager,
                                   anchorImage: UIImage?,
                                   physicalWidth: CGFloat?,
                                   scene: HasAnchoring,
                                   cardContents: [CardItem]) throws -> [ScreenAnnotation<CardItem>]
}

extension SceneLoadable {
    func syncCardContentsWithScene(manager: ARManager,
                                   anchorImage: UIImage?,
                                   physicalWidth: CGFloat?,
                                   scene: HasAnchoring,
                                   cardContents: [CardItem]) throws -> [ScreenAnnotation<CardItem>]
    {
        var annotations = [ScreenAnnotation<CardItem>]()
        
        try manager.setupScene(anchorImage: anchorImage, physicalWidth: physicalWidth, scene: scene)

        for cardItem in cardContents {
            guard let internalEntity = scene.findEntity(named: String(cardItem.id)) else {
                throw LoadingStrategyError.entityNotFoundError(cardItem.id)
            }
            var annotation = ScreenAnnotation(card: cardItem)
            annotation.setInternalEntity(with: internalEntity)
            annotation.setInternalEntityVisibility(to: false)
            annotations.append(annotation)
        }

        return annotations
    }
}
