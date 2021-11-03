//
//  ServiceStrategy.swift
//
//
//  Created by O'Brien, Patrick on 10/13/21.
//

import ARKit
import Combine
import Foundation
import RealityKit
import SAPFoundation
import SwiftUI

/// Identifier for which scene the ARService fetches
public enum SceneIdentifier {
    case sceneID(id: String)
    case sceneAlias(alias: String)
}

public struct ServiceStrategy<CardItem: CardItemModel>: AsyncAnnotationLoadingStrategy where CardItem: Codable {
    public var networkingAPI: ARCardsNetworkingService
    public var sceneIdentifier: SceneIdentifier
    
    var arscene: ARScene?
    
    public init(sapURLSession: SAPURLSession, sceneIdentifier: SceneIdentifier) {
        self.networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/augmentedreality/v1")
        self.sceneIdentifier = sceneIdentifier
    }
    
    public func load(with manager: ARManager, completionHandler: @escaping ([ScreenAnnotation<CodableCardItem>], UIImage?) -> Void) throws {
        var annotations = [ScreenAnnotation<CodableCardItem>]()
        
        // Improve logic after ARService refactoring
        var sceneID: String?
        var sceneAlias: String?
        
        switch self.sceneIdentifier {
        case .sceneID(let id):
            sceneID = id
        case .sceneAlias(let alias):
            sceneAlias = alias
        }
        
        _ = self.networkingAPI
            .getScene(for: sceneID!)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { _ in

            } receiveValue: { scene in
                manager.sceneRoot = Entity()
                manager.addReferenceImage(for: scene.annotationAnchorImage, with: scene.annotationAnchorImagePhysicalWidth)
                
                for cardItem in scene.cards {
                    var annotation = ScreenAnnotation(card: cardItem)
                    
                    if let position = cardItem.position_ {
                        let internalEntity = ModelEntity.generateEntity()
                        internalEntity.position = position
                        annotation.setEntity(to: internalEntity)
                        manager.addChild(for: internalEntity)
                    }
                    annotations.append(annotation)
                }
                
                completionHandler(annotations, scene.annotationAnchorImage)
            }
    }
}
