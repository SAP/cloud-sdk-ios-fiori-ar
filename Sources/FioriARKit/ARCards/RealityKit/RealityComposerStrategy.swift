//
//  AnnotationStrategies.swift
//
//
//  Created by O'Brien, Patrick on 3/2/21.
//

import ARKit
import Foundation
import RealityKit
import SwiftUI

/// A loading strategy that uses the RealityComposer app. After creating the Reality Composer scene, tthe entities in the scene correlate to a real world location relative to the image or object anchor.
/// This strategy wraps the anchors that represents these locations with the CardItemModels that they correspond to in a ScreenAnnotation struct for a single source of truth.
/// Loading the data into the ARAnnotationViewModel should be done in the onAppear method.
///
/// If an Object Anchor is used the anchorImage and physicalWidth can be set to nil and are ignored
///
/// - Parameters:
///  - cardContents: An array of **CardItem : `CardItemModel`** which represent what will be displayed in the default CardView
///  - anchorImage: Image to be converted to ARReferenceImage and added to ARConfiguration for discovery, can be nil if detecting an object Anchor
///  - physicalWidth: The width of the image in meters
///  - rcFile: Name of the Reality Composer File without the extension. *Note: .rcproject file, not a .reality file*
///  - sceneName: Name given to the scene in the Reality Composer app.
///
/// ## Usage
/// ```
/// let cardItems = [ExampleCardItem(id: 0, title_: "Hello"), ExampleCardItem(id: 1, title_: "World")]
/// guard let anchorImage = UIImage(named: "qrImage") else { return }
/// let strategy = RealityComposerStrategy(cardContents: cardItems, anchorImage: anchorImage, rcFile: "ExampleRC", rcScene: "ExampleScene")
/// arModel.load(loadingStrategy: strategy)
/// ```

public struct RealityComposerStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy where CardItem.ID: LosslessStringConvertible {
    public var cardContents: [CardItem]
    public var anchorImage: UIImage?
    public var physicalWidth: CGFloat?
    public var rcFile: String
    public var rcScene: String
    
    /// Constructor for loading annotations using an Image as an anchor with a Reality Composer scene
    public init(cardContents: [CardItem], anchorImage: UIImage? = nil, physicalWidth: CGFloat? = nil, rcFile: String, rcScene: String) {
        self.cardContents = cardContents
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
        self.rcFile = rcFile
        self.rcScene = rcScene
    }

    /**
     Constructor for loading annotations using Data from a JSON Array
        JSON key/value::
         "id": String,
         "title": String,
         "descriptionText": String?,
         "detailImage": Data?, // base64 encoding of Image
         "actionText": String?,
         "icon": String? // systemName of SFSymbol
     
        Example:
        [
         {
             "id": "WasherFluid",
             "title": "Recommended Washer Fluid",
             "descriptionText": "Rain X",
             "detailImage": null,
             "actionText": null,
             "icon": null
         },
         {
             "id": "Coolant",
             "title": "Genuine Coolant",
             "descriptionText": "Price: 20.99",
             "detailImage": "iVBORw0KGgoAAAANSUhE...",
             "actionText": "Order",
             "icon": "cart.fill"
         }
        ]
     */
    public init(jsonData: Data, anchorImage: UIImage? = nil, physicalWidth: CGFloat? = nil, rcFile: String, rcScene: String) throws where CardItem == DecodableCardItem {
        self.cardContents = try JSONDecoder().decode([DecodableCardItem].self, from: jsonData)
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
        self.rcFile = rcFile
        self.rcScene = rcScene
    }
    
    /// Loads the Reality Composer Scene and extracts the Entities pairing them with the data that corresponds to their ID into a list of `ScreenAnnotation`
    public func load(with manager: ARManagement) throws -> [ScreenAnnotation<CardItem>] {
        var annotations = [ScreenAnnotation<CardItem>]()
        
        guard let scene = try? RCScanner.loadScene(rcFileName: rcFile, sceneName: rcScene) else {
            throw LoadingStrategyError.sceneLoadingFailedError
        }
        
        // An image should use world tracking so we set the configuration to prevent automatic switching to Image Tracking
        // Object Detection inherently uses world tracking so an automatic configuration can be used
        switch scene.anchoring.target {
        case .image:
            guard let image = anchorImage, let width = physicalWidth else { return [] }
            manager.sceneRoot = scene
            manager.addReferenceImage(for: image, with: width)
        case .object:
            manager.setAutomaticConfiguration()
            manager.addAnchor(for: scene)
        default:
            throw LoadingStrategyError.anchorTypeNotSupportedError
        }
        
        for cardItem in self.cardContents {
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

internal enum LoadingStrategyError: Error {
    case anchorTypeNotSupportedError
    case entityNotFoundError(LosslessStringConvertible)
    case sceneLoadingFailedError
    case jsonDecodingError
    case base64DecodingError
}
