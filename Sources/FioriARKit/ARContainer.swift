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

public protocol ARManagement: AnyObject {
    var arView: ARView? { get set }
    var onSceneUpate: ((SceneEvents.Update) -> Void)? { get set }
    var sceneRoot: HasAnchoring? { get set }

    func configureSession(with configuration: ARConfiguration, options: ARSession.RunOptions)
    func addReferenceImage(for image: UIImage, _ name: String, with physicalWidth: CGFloat, configuration: ARConfiguration)
    func addAnchor(for entity: HasAnchoring)
    func tearDown()
}

public extension ARManagement {
    func configureSession(with configuration: ARConfiguration, options: ARSession.RunOptions = []) {
        self.configureSession(with: configuration, options: options)
    }
    
    func addReferenceImage(for image: UIImage, _ name: String = "", with physicalWidth: CGFloat, configuration: ARConfiguration = ARWorldTrackingConfiguration()) {
        self.addReferenceImage(for: image, name, with: physicalWidth, configuration: configuration)
    }
}

public protocol AnnotationLoadingStrategy {
    associatedtype CardItem: CardItemModel
    var cardContents: [CardItem] { get }
    func load(with manager: ARManagement) -> [ScreenAnnotation<CardItem>]
}

typealias AnchorID = UUID
public typealias RealityScene = RealityKit.Entity & RealityKit.HasAnchoring
