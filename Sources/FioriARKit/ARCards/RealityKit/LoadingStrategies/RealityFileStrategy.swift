//
//  RealityFileStrategy.swift
//
//
//  Created by O'Brien, Patrick on 6/21/21.
//

import ARKit
import Foundation
import RealityKit
import SwiftUI

/// A loading strategy that uses the RealityComposer app. After creating the Reality Composer scene, the entities in the scene correlate to a real world location relative to the image or object anchor.
/// This strategy wraps the anchors that represents these locations with the CardItemModels that they correspond to in a ScreenAnnotation struct for a single source of truth.
/// Loading the data into the ARAnnotationViewModel should be done in the onAppear method.
///
/// - Parameters:
///  - cardContents: An array of **CardItem : `CardItemModel`** which represent what will be displayed in the default CardView
///  - anchorImage: Image to be converted to ARReferenceImage and added to ARConfiguration for discovery, can be nil if detecting an object Anchor
///  - physicalWidth: The width of the image in meters
///  - realityFileURL: URL path to a .reality file that makes contains the scene, exported from Reality Composer
///  - sceneName: Name given to the scene in the Reality Composer app.
///
/// ## Usage
/// ```
/// let cardItems = [ExampleCardItem(id: 0, title_: "Hello"), ExampleCardItem(id: 1, title_: "World")]
/// guard let anchorImage = UIImage(named: "qrImage") else { return }
/// let realityFilePath = FileManager.default.getDocumentsDirectory().appendingPathComponent(FileManager.realityFiles).appendingPathComponent("ExampleRC.reality")
/// let strategy = RealityFileStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, realityFilePath: realityFilePath, rcScene: "ExampleScene")
/// arModel.load(loadingStrategy: strategy)
/// ```
public struct RealityFileStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy, SceneLoadable where CardItem.ID: LosslessStringConvertible {
    public var cardContents: [CardItem]
    public var anchorImage: UIImage?
    public var physicalWidth: CGFloat?
    public var realityFilePath: URL
    public var rcScene: String
    
    /// Constructor for loading annotations using an Image as an anchor with a Reality Composer scene
    /// If Object Anchor is used anchorImage and PhysicalWidth are ignored and can be set to nil
    public init(cardContents: [CardItem], anchorImage: UIImage? = nil, physicalWidth: CGFloat? = nil, realityFilePath: URL, rcScene: String) {
        self.cardContents = cardContents
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
        self.realityFilePath = realityFilePath
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
    public init(jsonData: Data, anchorImage: UIImage? = nil, physicalWidth: CGFloat? = nil, realityFilePath: URL, rcScene: String) throws where CardItem == DecodableCardItem {
        self.cardContents = try JSONDecoder().decode([DecodableCardItem].self, from: jsonData)
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
        self.realityFilePath = realityFilePath
        self.rcScene = rcScene
    }
    
    /// Loads the Reality Files Scene and extracts the Entities pairing them with the data that corresponds to their ID into a list of `ScreenAnnotation`
    public func load(with manager: ARManagement) throws -> [ScreenAnnotation<CardItem>] {
        let scene = try RCScanner.loadSceneFromRealityFile(realityFileURL: self.realityFilePath, sceneName: self.rcScene)
        let annotations = try syncCardContentsWithScene(manager: manager, anchorImage: anchorImage, physicalWidth: physicalWidth, scene: scene, cardContents: cardContents)
        
        return annotations
    }
}
