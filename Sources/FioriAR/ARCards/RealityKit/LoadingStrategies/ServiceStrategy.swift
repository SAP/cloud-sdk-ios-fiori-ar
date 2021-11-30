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

/// Unique attribute and its value identifiying a scene stored in SAP Mobile Services
public enum SceneIdentifyingAttribute {
    /// identifier
    case id(Int)
    /// alias
    case alias(String)
}
    
/// A loading strategy that makes a network fetch request to Mobile Services to return the data necessary to display an AR Annotation Scene.
/// This strategy wraps the anchors that represents these locations with the CardItemModels that they correspond to in a ScreenAnnotation struct for a single source of truth.
/// Loading the data into the ARAnnotationViewModel should be done in the onAppear method.
///
/// - Parameters:
///  - serviceURL: Server URL for your application in SAP Mobile Services
///  - sapURLSession: SAPURLSession to provide credentials to Mobile Services
///  - sceneIdentifier: `SceneIdentifyingAttribute` for which scene to fetch either by id `Int` or alias `String`
///
/// ## Usage
/// ```
/// @StateObject var serviceStrategy = ServiceStrategy<CodableCardItem>(
///     serviceURL: URL(string: IntegrationTest.System.redirectURL)!,
///     sapURLSession: SAPURLSession.createOAuthURLSession(
///         clientID: IntegrationTest.System.clientID,
///         authURL: IntegrationTest.System.authURL,
///         redirectURL: IntegrationTest.System.redirectURL,
///         tokenURL: IntegrationTest.System.tokenURL
///     ),
///     sceneIdentifier: SceneIdentifyingAttribute.id(IntegrationTest.TestData.sceneId)
///
///  arModel.loadAsync(loadingStrategy: serviceStrategy)
/// ```
public class ServiceStrategy<CardItem: CardItemModel>: ObservableObject, AsyncAnnotationLoadingStrategy where CardItem: Codable {
    private var networkingAPI: ARCardsNetworkingService

    /// Unique attribute and its value identifiying a scene stored in SAP Mobile Services
    public var sceneIdentifier: SceneIdentifyingAttribute
    
    var arscene: ARScene?

    private var cancellables = Set<AnyCancellable>()

    /// Initializer
    /// - Parameters:
    ///   - serviceURL: Server URL for your application in SAP Mobile Services
    ///   - sapURLSession: networking API from SAPFoundation framework
    ///   - sceneIdentifier: unique value identifiying a scene stored in SAP Mobile Services
    public init(serviceURL: URL, sapURLSession: SAPURLSession, sceneIdentifier: SceneIdentifyingAttribute) {
        self.networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: serviceURL.absoluteString)
        self.sceneIdentifier = sceneIdentifier
    }

    /// Performs network requests to load scene information from SAP Mobile Services
    /// - Parameters:
    ///   - manager: handling the ARView
    ///   - completionHandler: providing the cards and image anchor of the requested scene once loaded
    public func load(with manager: ARManager, completionHandler: @escaping ([ScreenAnnotation<CodableCardItem>], GuideImageState) -> Void) throws {
        var annotations = [ScreenAnnotation<CodableCardItem>]()

        self.networkingAPI.getScene(self.sceneIdentifier)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print(completion)
                case .failure(let error):
                    completionHandler([], .failure)
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

                completionHandler(annotations, .finished(scene.referenceAnchorImage))
            }
            .store(in: &self.cancellables)
    }
}
