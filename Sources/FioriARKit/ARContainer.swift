//
//  ARContainer.swift
//  ARTestApp
//
//  Created by O'Brien, Patrick on 1/20/21.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

internal struct ARContainer: UIViewRepresentable {
    var arStorage: ARManager
    
    func makeUIView(context: Context) -> ARView {
        self.arStorage.arView ?? ARView(frame: .zero)
    }

    func updateUIView(_ arView: ARView, context: Context) {}
}

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
            let annotation = ScreenAnnotation(card: cardItem)
            annotation.setInternalEntity(with: internalEntity)
            annotations.append(annotation)
        }

        return annotations
    }
}

typealias AnchorID = UUID
