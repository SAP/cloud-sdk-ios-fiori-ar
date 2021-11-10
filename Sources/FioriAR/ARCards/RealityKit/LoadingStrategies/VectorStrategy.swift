//
//  VectorStrategy.swift
//
//
//  Created by O'Brien, Patrick on 10/13/21.
//

import ARKit
import Foundation
import RealityKit
import SwiftUI

public struct VectorStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy {
    public var cardContents: [CardItem]
    public var anchorImage: UIImage
    public var physicalWidth: CGFloat
    
    public init(cardContents: [CardItem], anchorImage: UIImage, physicalWidth: CGFloat) {
        self.cardContents = cardContents
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
    }
    
    /**
     Constructor for loading annotations using Data from a JSON Array
        JSON key/value:
         "id": String,
         "title_": String,
         "subtitle_": String?,
         "detailImage_": Data?, // base64 encoding of Image
         "actionText_": String?,
         "icon_": String? // systemName of SFSymbol
     
        Example:
        [
         {
             "id": "WasherFluid",
             "title_": "Recommended Washer Fluid",
             "subtitle_": "Rain X",
             "detailImage_": null,
             "actionText_": null,
             "icon_": null
         },
         {
             "id": "Coolant",
             "title_": "Genuine Coolant",
             "subtitle_": "Price: 20.99",
             "detailImage_": "iVBORw0KGgoAAAANSUhE...",
             "actionText_": "Order",
             "icon_": "cart.fill"
         }
        ]
     */
    public init(jsonData: Data, anchorImage: UIImage, physicalWidth: CGFloat) throws where CardItem == CodableCardItem {
        self.cardContents = try JSONDecoder().decode([CodableCardItem].self, from: jsonData)
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
    }
    
    /// Loads `[ScreenAnnotation]` for cardContents and creates an ModelEntity for the cards with a position available
    public func load(with manager: ARManager) throws -> (annotations: [ScreenAnnotation<CardItem>], guideImage: UIImage?) {
        var annotations = [ScreenAnnotation<CardItem>]()
        
        manager.sceneRoot = Entity()
        manager.addReferenceImage(for: self.anchorImage, with: self.physicalWidth, resetImages: true)
        
        for cardItem in self.cardContents {
            var annotation = ScreenAnnotation(card: cardItem)
            
            if let position = cardItem.position_ {
                let internalEntity = ModelEntity.generateEntity()
                internalEntity.position = position
                annotation.setEntity(to: internalEntity)
                manager.addChild(for: internalEntity)
            }
            annotations.append(annotation)
        }
        return (annotations, self.anchorImage)
    }
}
