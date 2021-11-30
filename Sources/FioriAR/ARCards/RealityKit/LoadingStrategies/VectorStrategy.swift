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

/// A loading strategy that uses the Vectors provided by the `CardItemModel`s  `PositionComponent` to position the Entities relative to the anchor Image.
/// This strategy wraps the anchors that represents these locations with the CardItemModels that they correspond to in a ScreenAnnotation struct for a single source of truth.
/// Loading the data into the ARAnnotationViewModel should be done in the onAppear method.
///
/// ## Usage
/// ```
/// let cardItems = [ExampleCardItem(id: 0, title_: "Hello"), ExampleCardItem(id: 1, title_: "World")]
/// guard let anchorImage = UIImage(named: "qrImage") else { return }
/// let strategy = VectorStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, realityFilePath: realityFilePath)
/// arModel.load(loadingStrategy: strategy)
/// ```
public struct VectorStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy {
    /// An array of **CardItem : `CardItemModel`** which represent what will be displayed in the default CardView
    public var cardContents: [CardItem]
    /// Image to be converted to ARReferenceImage and added to ARConfiguration for discovery, can be nil if detecting an object Anchor
    public var anchorImage: UIImage
    /// The width of the image in meters
    public var physicalWidth: CGFloat

    /// Constructor for loading annotations using an Image as an anchor with a Reality Composer scene
    /// - Parameters:
    ///   - cardContents: An array of **CardItem : `CardItemModel`** which represent what will be displayed in the default CardView
    ///   - anchorImage: Image to be converted to ARReferenceImage and added to ARConfiguration for discovery, can be nil if detecting an object Anchor
    ///   - physicalWidth: The width of the image in meters
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
