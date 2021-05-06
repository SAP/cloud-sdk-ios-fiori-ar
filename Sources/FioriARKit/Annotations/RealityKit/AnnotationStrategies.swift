// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  File.swift
//  
//
//  Created by O'Brien, Patrick on 3/2/21.
//

import Foundation
import RealityKit
import UIKit
import ARKit

public struct RealityComposerStrategy<CardItem: CardItemModel>: AnnotationLoadingStrategy where CardItem.ID == Int {
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
