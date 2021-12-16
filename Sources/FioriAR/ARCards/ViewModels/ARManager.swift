//
//  ARManager.swift
//
//
//  Created by O'Brien, Patrick on 5/21/21.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

/// Stores and manages common functional for the ARView
public class ARManager {
    internal var arView: ARView?

    /// The Root Entity with the entities that back the real world positions of the Annotations as children
    public var sceneRoot: Entity?
    
    // Work around for iOS 15 rendering issue
    /// Retain AnchorIDs to update AnchorEntity transforms
    var sceneAnchors: [AnchorID: AnchorEntity] = [:]

    var worldMap: ARWorldMap?
    var referenceImages: Set<ARReferenceImage> = []
    var detectionObjects: Set<ARReferenceObject> = []
    var onSceneUpate: ((SceneEvents.Update) -> Void)?
    var subscription: Cancellable!

    private var draggedEntityLatestPosition: CGPoint?
    private var draggedEntity: Entity?

    /// Initializer
    public init() {
        self.setup(canBeFatal: true)
    }

    internal init(canBeFatal: Bool) {
        self.setup(canBeFatal: canBeFatal)
    }

    internal func setup(canBeFatal: Bool = true) {
        self.arView = ARView(frame: .zero)

        do {
            try self.configureSession()
        } catch {
            if canBeFatal {
                fatalError(error.localizedDescription)
            } else {
                print(error)
            }
        }
        self.subscription = self.arView?.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in
            onSceneUpate?($0)
        }
        self.addDepthDragGesture()
    }

    /// Cleans up the arView which is necessary for SwiftUI navigation
    internal func tearDown() {
        self.arView = nil
        self.subscription = nil
        self.onSceneUpate = nil
    }

    internal func removeRoot() {
        self.sceneRoot?.removeFromParent()
        self.sceneRoot = nil
    }

    /// Set the configuration for the ARView's session with run options
    public func configureSession(with configuration: ARConfiguration = ARWorldTrackingConfiguration(), options: ARSession.RunOptions = []) throws {
        #if !targetEnvironment(simulator)
            self.arView?.session.run(configuration, options: options)
        #else
            throw ARManagerError.fioriARDoesNotSupportSimulatorError
        #endif
    }

    /// Set the session for automatic configuration
    public func setAutomaticConfiguration() {
        #if !targetEnvironment(simulator)
            self.arView?.automaticallyConfigureSession = true
        #endif
    }

    internal func setDelegate(to delegate: ARSessionDelegate) {
        #if !targetEnvironment(simulator)
            self.arView?.session.delegate = delegate
        #endif
    }

    internal func addARKitAnchor(for anchor: ARAnchor, children: [Entity] = []) {
        #if !targetEnvironment(simulator)
            let anchorEntity = AnchorEntity(world: anchor.transform) // Work around for iOS 15 rendering issue, ideally use ARAnchor(anchor:)
            children.forEach { anchorEntity.addChild($0) }
            self.addAnchor(anchor: anchorEntity)
            self.sceneAnchors[anchor.identifier] = anchorEntity
        #endif
    }

    // An image should use world tracking so we set the configuration to prevent automatic switching to Image Tracking
    // Object Detection inherently uses world tracking so an automatic configuration can be used
    internal func setupScene(anchorImage: UIImage?, physicalWidth: CGFloat?, scene: HasAnchoring) throws {
        #if !targetEnvironment(simulator)
            switch scene.anchoring.target {
            case .image:
                guard let image = anchorImage, let width = physicalWidth else { return }
                self.sceneRoot = scene
                self.addReferenceImage(for: image, with: width)
            case .object:
                self.setAutomaticConfiguration()
                self.addAnchor(anchor: scene)
            default:
                throw LoadingStrategyError.anchorTypeNotSupportedError
            }
        #endif
    }

    internal func resetAnchorImages() {
        #if !targetEnvironment(simulator)
            if let worldConfig = arView?.session.configuration as? ARWorldTrackingConfiguration {
                worldConfig.detectionImages = []
            } else if let imageConfig = arView?.session.configuration as? ARImageTrackingConfiguration {
                imageConfig.trackingImages = []
            }
        #endif
    }

    /// Adds the given entity which conforms to `HasCollision` as a child of the sceneRoot
    /// HasCollision is internally required for entities to have a touch gesture applied for interaction
    public func addChild(for entity: HasCollision, preservingWorldTransform: Bool = false) {
        self.arView?.installGestures([.scale, .translation], for: entity)
        self.sceneRoot?.addChild(entity, preservingWorldTransform: preservingWorldTransform)
    }

    /// Adds a Entity which conforms to HasAnchoring to the arView.scene
    public func addAnchor(anchor: HasAnchoring) {
        self.arView?.scene.addAnchor(anchor)
    }

    /// Removes the specified HasAnchoring from the scene
    public func removeAnchor(anchor: HasAnchoring) {
        self.arView?.scene.removeAnchor(anchor)
    }

    /// Finds Entity in the scene from the given name, returns nil if the entity does not exist in the scene
    public func findEntity(named: String) -> Entity? {
        self.arView?.scene.findEntity(named: named)
    }

    internal func removeEntityGestures() {
        self.arView?
            .gestureRecognizers?
            .filter { $0 is EntityGestureRecognizer }
            .forEach {
                arView?.removeGestureRecognizer($0)
            }
    }

    /// Adds an ARReferenceImage to the configuration for the session to discover
    /// Optionally can set the configuration to ARImageTrackingConfiguration
    public func addReferenceImage(for image: UIImage, _ name: String? = nil, with physicalWidth: CGFloat, configuration: ARConfiguration = ARWorldTrackingConfiguration(), resetImages: Bool = false) {
        guard let referenceImage = createReferenceImage(image, name, physicalWidth) else { return }
        if resetImages {
            self.referenceImages.removeAll()
        }
        self.referenceImages.insert(referenceImage)
        if let worldConfig = configuration as? ARWorldTrackingConfiguration {
            worldConfig.detectionImages = self.referenceImages
            do { try self.configureSession(with: worldConfig) } catch { print(error.localizedDescription) }
        } else if let imageConfig = configuration as? ARImageTrackingConfiguration {
            imageConfig.trackingImages = self.referenceImages
            do { try self.configureSession(with: imageConfig) } catch { print(error.localizedDescription) }
        }
    }

    private func createReferenceImage(_ uiImage: UIImage, _ name: String? = nil, _ physicalWidth: CGFloat) -> ARReferenceImage? {
        guard let cgImage = createCGImage(uiImage: uiImage) else { return nil }
        let image = ARReferenceImage(cgImage, orientation: .up, physicalWidth: physicalWidth)
        image.name = name
        return image
    }

    private func createCGImage(uiImage: UIImage) -> CGImage? {
        guard let ciImage = CIImage(image: uiImage) else { return nil }
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
}

private extension ARManager {
    @objc func calculateEntityDepthOnDrag(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self.arView)
        if gesture.state == .failed || gesture.state == .cancelled {
            return
        }
        if gesture.state == .began {
            if let rayResult = arView?.ray(through: location) {
                let results = self.arView?.scene.raycast(origin: rayResult.origin, direction: rayResult.direction)
                if let firstResult = results?.first {
                    self.draggedEntity = firstResult.entity
                    self.draggedEntityLatestPosition = location
                }
            }
        } else if let draggedEntity = draggedEntity, let draggedEntityLatestPosition = draggedEntityLatestPosition {
            let deltaY = Float(location.y - draggedEntityLatestPosition.y) / 700
            draggedEntity.position.y -= deltaY
            self.draggedEntityLatestPosition = location

            if gesture.state == .ended {
                self.draggedEntity = nil
                self.draggedEntityLatestPosition = nil
            }
        }
    }

    func addDepthDragGesture() {
        let pr = UIPanGestureRecognizer(target: self, action: #selector(self.calculateEntityDepthOnDrag))
        pr.minimumNumberOfTouches = 2
        self.arView?.addGestureRecognizer(pr)
    }
}

private enum ARManagerError: Error, LocalizedError {
    case fioriARDoesNotSupportSimulatorError

    public var errorDescription: String? {
        switch self {
        case .fioriARDoesNotSupportSimulatorError:
            return NSLocalizedString("FioriAR does not support the Simulator", comment: "")
        }
    }
}
