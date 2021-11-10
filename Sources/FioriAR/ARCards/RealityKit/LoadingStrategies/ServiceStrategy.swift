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
public enum SceneIdentifyingAttribute {
    case id(Int)
    case alias(String)
}

public class ServiceStrategy<CardItem: CardItemModel>: ObservableObject, AsyncAnnotationLoadingStrategy where CardItem: Codable {
    public var networkingAPI: ARCardsNetworkingService
    public var sceneIdentifier: SceneIdentifyingAttribute
    
    var arscene: ARScene?

    private var cancellables = Set<AnyCancellable>()
    
    public init(serviceURL: URL, sapURLSession: SAPURLSession, sceneIdentifier: SceneIdentifyingAttribute) {
        self.networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: serviceURL.absoluteString)
        self.sceneIdentifier = sceneIdentifier
    }
    
    public func load(with manager: ARManager, completionHandler: @escaping ([ScreenAnnotation<CodableCardItem>], UIImage?) -> Void) throws {
        var annotations = [ScreenAnnotation<CodableCardItem>]()

        self.networkingAPI.getScene(self.sceneIdentifier)
//        self.scenePublisher(identifier: self.sceneIdentifier)
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
                manager.addReferenceImage(for: scene.referenceAnchorImage, with: scene.referenceAnchorImagePhysicalWidth)

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

                completionHandler(annotations, scene.referenceAnchorImage)
            }
            .store(in: &self.cancellables)
    }
}
