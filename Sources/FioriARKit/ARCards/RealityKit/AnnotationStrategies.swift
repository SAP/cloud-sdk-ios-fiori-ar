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
    public init(cardContents: [CardItem], anchorImage: UIImage, physicalWidth: CGFloat, rcFile: String, rcScene: String) {
        self.cardContents = cardContents
        self.anchorImage = anchorImage
        self.physicalWidth = physicalWidth
        self.rcFile = rcFile
        self.rcScene = rcScene
    }
    
    /// Constructor for loading annotations using an Object as an anchor with a Reality Composer scene
    public init(cardContents: [CardItem], rcFile: String, rcScene: String) {
        self.cardContents = cardContents
        self.anchorImage = nil
        self.physicalWidth = nil
        self.rcFile = rcFile
        self.rcScene = rcScene
    }
    
    /// Loads the Reality Composer Scene and extracts the Entities pairing them with the data that corresponds to their ID into a list of `ScreenAnnotation`
    public func load(with manager: ARManagement) throws -> [ScreenAnnotation<CardItem>] {
        var annotations = [ScreenAnnotation<CardItem>]()
        
        guard let scene = try? RCScanner.loadScene(rcFileName: rcFile, sceneName: rcScene) else {
            throw LoadingStrategyError.sceneLoadingFailed
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
            throw LoadingStrategyError.anchorTypeNotSupported
        }
        
        for cardItem in self.cardContents {
            guard let internalEntity = scene.findEntity(named: String(cardItem.id)) else {
                throw LoadingStrategyError.entityNotFound(cardItem.id)
            }
            let annotation = ScreenAnnotation(card: cardItem)
            annotation.setInternalEntity(with: internalEntity)
            annotations.append(annotation)
        }
        
        return annotations
    }
}

private enum LoadingStrategyError: Error {
    case anchorTypeNotSupported
    case entityNotFound(LosslessStringConvertible)
    case sceneLoadingFailed
}
