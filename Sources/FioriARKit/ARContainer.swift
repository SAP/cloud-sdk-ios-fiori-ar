//
//  ARContainer.swift
//  ARTestApp
//
//  Created by O'Brien, Patrick on 1/20/21.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

internal struct ARContainer: UIViewRepresentable {
    var arStorage: ARManagement
    
    func makeUIView(context: Context) -> ARView {
        self.arStorage.arView ?? ARView(frame: .zero)
    }

    func updateUIView(_ arView: ARView, context: Context) {}
}

/// The Protocol which stores the ARView an defines common functionality
public protocol ARManagement: AnyObject {
    var arView: ARView? { get set }
    var onSceneUpate: ((SceneEvents.Update) -> Void)? { get set }
    var sceneRoot: HasAnchoring? { get set }

    func configureSession(with configuration: ARConfiguration, options: ARSession.RunOptions)
    func setAutomaticConfiguration()
    func addReferenceImage(for image: UIImage, _ name: String, with physicalWidth: CGFloat, configuration: ARConfiguration)
    func addAnchor(for entity: HasAnchoring)
    func tearDown()
}

public extension ARManagement {
    /// Set the ARView to automatically configure
    func setAutomaticConfiguration() {
        self.arView?.automaticallyConfigureSession = true
    }
    
    /// Set the configuration for the ARView's session with options
    func configureSession(with configuration: ARConfiguration, options: ARSession.RunOptions = []) {
        self.configureSession(with: configuration, options: options)
    }
    
    /// Adds an ARReferenceImage to the configuration for the session to discover
    func addReferenceImage(for image: UIImage, _ name: String = "", with physicalWidth: CGFloat, configuration: ARConfiguration = ARWorldTrackingConfiguration()) {
        self.addReferenceImage(for: image, name, with: physicalWidth, configuration: configuration)
    }
}

/// Protocol which defines the data a strategy needs to provide a `[ScreenAnnotation]`
public protocol AnnotationLoadingStrategy {
    associatedtype CardItem: CardItemModel
    var cardContents: [CardItem] { get }
    func load(with manager: ARManagement) throws -> [ScreenAnnotation<CardItem>]
}

internal protocol SceneLoadable where CardItem.ID: LosslessStringConvertible {
    associatedtype CardItem: CardItemModel

    func syncCardContentsWithScene(manager: ARManagement,
                                   anchorImage: UIImage?,
                                   physicalWidth: CGFloat?,
                                   scene: HasAnchoring,
                                   cardContents: [CardItem]) throws -> [ScreenAnnotation<CardItem>]
}

extension SceneLoadable {
    func syncCardContentsWithScene(manager: ARManagement,
                                   anchorImage: UIImage?,
                                   physicalWidth: CGFloat?,
                                   scene: HasAnchoring,
                                   cardContents: [CardItem]) throws -> [ScreenAnnotation<CardItem>]
    {
        var annotations = [ScreenAnnotation<CardItem>]()

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

        for cardItem in cardContents {
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

typealias AnchorID = UUID
