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
    ///  associated type of this protocol needs to conform to `CardItemModel`
    associatedtype CardItem: CardItemModel
    /// cards content to be populated
    var cardContents: [CardItem] { get }
    /// load screen annotations and guideImage synchronously
    func load(with manager: ARManager) throws -> (annotations: [ScreenAnnotation<CardItem>], guideImage: UIImage?)
}

/// Protocol which defines the data an asynchronous strategy needs to provide a `[ScreenAnnotation]`
public protocol AsyncAnnotationLoadingStrategy {
    ///  associated type of this protocol needs to conform to `CardItemModel` and `Codable`
    associatedtype CardItem: CardItemModel, Codable
    /// load screen annotations and guideImage asynchronously
    func load(with manager: ARManager, completionHandler: @escaping ([ScreenAnnotation<CardItem>], GuideImageState) -> Void) throws
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
            annotation.setEntity(to: internalEntity)
            annotations.append(annotation)
        }

        return annotations
    }
}

internal enum LoadingStrategyError: Error {
    case anchorTypeNotSupportedError
    case entityNotFoundError(LosslessStringConvertible)
    case sceneLoadingFailedError
    case jsonDecodingError
    case base64DecodingError
}
