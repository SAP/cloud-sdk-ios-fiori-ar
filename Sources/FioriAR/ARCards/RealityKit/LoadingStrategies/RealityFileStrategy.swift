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
/// ## Usage
/// ```
/// let cardItems = [ExampleCardItem(id: 0, title_: "Hello"), ExampleCardItem(id: 1, title_: "World")]
/// guard let anchorImage = UIImage(named: "qrImage") else { return }
/// let realityFilePath = FileManager.default.getDocumentsDirectory().appendingPathComponent(FileManager.realityFiles).appendingPathComponent("ExampleRC.reality")
/// let strategy = RealityFileStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, realityFilePath: realityFilePath, rcScene: "ExampleScene")
/// arModel.load(loadingStrategy: strategy)
/// ```
public struct RealityFileStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy, SceneLoadable where CardItem.ID: LosslessStringConvertible {
    /// An array of **CardItem : `CardItemModel`** which represent what will be displayed in the default CardView
    public var cardContents: [CardItem]
    /// Image to be converted to ARReferenceImage and added to ARConfiguration for discovery, can be nil if detecting an object Anchor
    public var anchorImage: UIImage?
    /// The width of the image in meters
    public var physicalWidth: CGFloat?
    /// URL path to a .reality file that makes contains the scene, exported from Reality Composer
    public var realityFilePath: URL
    /// Name given to the scene in the Reality Composer app.
    public var rcScene: String
    
    /// Constructor for loading annotations using an Image as an anchor with a Reality Composer scene
    /// If Object Anchor is used anchorImage and PhysicalWidth are ignored and can be set to nil
    /// - Parameters:
    ///   - cardContents: An array of **CardItem : `CardItemModel`** which represent what will be displayed in the default CardView
    ///   - anchorImage: Image to be converted to ARReferenceImage and added to ARConfiguration for discovery, can be nil if detecting an object Anchor
    ///   - physicalWidth: The width of the image in meters
    ///   - realityFilePath: URL path to a .reality file that makes contains the scene, exported from Reality Composer
    ///   - rcScene: Name given to the scene in the Reality Composer app.
    public init(cardContents: [CardItem], anchorImage: UIImage? = nil, physicalWidth: CGFloat? = nil, realityFilePath: URL, rcScene: String) {
        self.cardContents = cardContents
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
        self.realityFilePath = realityFilePath
        self.rcScene = rcScene
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
    public init(jsonData: Data, anchorImage: UIImage? = nil, physicalWidth: CGFloat? = nil, realityFilePath: URL, rcScene: String) throws where CardItem == CodableCardItem {
        self.cardContents = try JSONDecoder().decode([CodableCardItem].self, from: jsonData)
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
        self.realityFilePath = realityFilePath
        self.rcScene = rcScene
    }
    
    /// Loads the Reality Files Scene and extracts the Entities pairing them with the data that corresponds to their ID into a list of `ScreenAnnotation`
    public func load(with manager: ARManager) throws -> (annotations: [ScreenAnnotation<CardItem>], guideImage: UIImage?) {
        let scene = try RCScanner.loadSceneFromRealityFile(realityFileURL: self.realityFilePath, sceneName: self.rcScene)
        let annotations = try syncCardContentsWithScene(manager: manager, anchorImage: anchorImage, physicalWidth: physicalWidth, scene: scene, cardContents: cardContents)
        
        return (annotations, self.anchorImage)
    }
}
