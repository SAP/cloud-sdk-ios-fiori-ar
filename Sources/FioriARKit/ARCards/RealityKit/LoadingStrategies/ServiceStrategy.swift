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
    case sceneID(id: Int)
    case sceneAlias(alias: String)
}

public class ServiceStrategy<CardItem: CardItemModel>: ObservableObject, AsyncAnnotationLoadingStrategy where CardItem: Codable {
    public var networkingAPI: ARCardsNetworkingService
    public var sceneIdentifier: SceneIdentifier
    
    var arscene: ARScene?

    private var cancellables = Set<AnyCancellable>()
    
    public init(serviceURL: URL, sapURLSession: SAPURLSession, sceneIdentifier: SceneIdentifier) {
        self.networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: serviceURL.absoluteString)
        self.sceneIdentifier = sceneIdentifier
    }
    
    public func load(with manager: ARManager, completionHandler: @escaping ([ScreenAnnotation<CodableCardItem>], UIImage?) -> Void) throws {
        var annotations = [ScreenAnnotation<CodableCardItem>]()
        
        // Improve logic after ARService refactoring
        var sceneID: Int?
        var sceneAlias: String?
        
        switch self.sceneIdentifier {
        case .sceneID(let id):
            sceneID = id
        case .sceneAlias(let alias):
            sceneAlias = alias
        }
        
        self.networkingAPI
            .getScene(for: sceneID!)
            .receive(on: DispatchQueue.main) // initialization of RealityKit' ModelEntity needs to happen on main thread or otherwise the app crashes
            .sink { completion in
                switch completion {
                case .finished:
                    print(completion)
                case .failure(let error):
                    print("Fetching scene failed! \(error.localizedDescription)")
                }
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
            .store(in: &self.cancellables)
    }
}
