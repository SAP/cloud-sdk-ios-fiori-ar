//
//  VectorLoadingStrategy.swift
//
//
//  Created by O'Brien, Patrick on 10/13/21.
//

import ARKit
import Foundation
import RealityKit
import SwiftUI

public struct VectorLoadingStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy {
    public var cardContents: [CardItem]
    public var anchorImage: UIImage
    public var physicalWidth: CGFloat
    
    public init(cardContents: [CardItem], anchorImage: UIImage, physicalWidth: CGFloat) {
        self.cardContents = cardContents
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
    }
    
    public func load(with manager: ARManager) throws -> [ScreenAnnotation<CardItem>] {
        var annotations = [ScreenAnnotation<CardItem>]()
        
        manager.sceneRoot = Entity()
        manager.addReferenceImage(for: self.anchorImage, with: self.physicalWidth, resetImages: true)
        
        for cardItem in self.cardContents {
            var annotation = ScreenAnnotation(card: cardItem, isCardVisible: cardItem.position_ != nil)
            
            if let position = cardItem.position_ {
                let internalEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                internalEntity.generateCollisionShapes(recursive: true)
                internalEntity.position = position
                annotation.setInternalEntity(with: internalEntity)
                annotation.hideInternalEntity()
                
                manager.arView?.installGestures([.scale, .translation], for: internalEntity)
                manager.sceneRoot?.addChild(internalEntity)
            }
            
            annotations.append(annotation)
        }
        
        return annotations
    }
}
