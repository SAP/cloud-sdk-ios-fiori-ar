//
//  RealityComposerStrategy.swift
//  
//
//  Created by O'Brien, Patrick on 3/2/21.
//

import Foundation
import RealityKit
import UIKit
import ARKit


/// A loading strategy that uses the RealityComposer app. After creating the Reality Composer scene, tthe entities in the scene correlate to a real world location relative to the image or object anchor. This strategy wraps the anchors that represents these locations with the CardItemModels that they correspond to in a ScreenAnnotation struct for a single source of truth. Loading the data into the ARAnnotationViewModel should be done in the onAppear method.
///
/// ## Parameters:
///
///   - cardContents: An array of **CardItem : CardItemModel** which represent what will be displayed in the default CardView
///   - rcFile: Name of the Reality Composer File without the extension. *Note: .rcproject file, not a .reality file*
///   - sceneName: Name given to the scene in the Reality Composer app.
///
/// ## Usage
///
/// ```
/// let cardItems = [ExampleCardItem(id: 0, title_: "Hello"), ExampleCardItem(id: 1, title_: "World")]
/// let strategy = RealityComposerStrategy(cardContents: cardItems, rcFile: "ExampleRC", rcScene: "ExampleScene")
/// arModel.load(loadingStrategy: strategy)
///
/// ```

public struct RealityComposerStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy where CardItem.ID : LosslessStringConvertible {
    public var cardContents: [CardItem]
    public var rcFile: String
    public var rcScene: String
    
    public init(cardContents: [CardItem], rcFile: String, rcScene: String) {
        self.cardContents = cardContents
        self.rcFile = rcFile
        self.rcScene = rcScene
    }
    
    public func load(arView: ARView) -> [ScreenAnnotation<CardItem>] {
        var annotations = [ScreenAnnotation<CardItem>]()
        
        guard let scene = try? RCScanner.loadScene(rcFileName: rcFile, sceneName: rcScene) else {
            print("Scene Failed to Load")
            return []
        }

        arView.scene.addAnchor(scene)

        for cardItem in cardContents {
            if let internalEntity = scene.findEntity(named: String(cardItem.id)) {
                let annotation = ScreenAnnotation(card: cardItem)
                annotation.setInternalEntity(with: internalEntity)
                annotations.append(annotation)
            }
        }
        
        return annotations
    }
}
