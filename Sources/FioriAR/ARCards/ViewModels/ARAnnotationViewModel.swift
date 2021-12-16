//
//  ARAnnotationViewModel.swift
//  Examples
//
//  Created by O'Brien, Patrick on 1/20/21.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

///  ViewModel for managing an ARCards experience. Provides and sets the annotation data/anchor locations to the view and the flow for the discovery animations.
open class ARAnnotationViewModel<CardItem: CardItemModel>: NSObject, ObservableObject, ARSessionDelegate {
    /// Manages all common functionality for the ARView
    internal var arManager: ARManager!
    
    /// An array of **ScreenAnnotations** which are displayed in the scene  contain the marker position and their card contents
    /// The annotations internal entities within this list should be in the ARView scene. Set by the annotation loading strategy
    @Published public internal(set) var annotations = [ScreenAnnotation<CardItem>]()
    
    /// The ScreenAnnotation that is focused on in the scene. The CardView and MarkerView will be in their selected states
    @Published public internal(set) var currentAnnotation: ScreenAnnotation<CardItem>?
    
    /// The guideImageState for the scanLabel retrieved from the AnnotationLoadingStrategy
    @Published internal var guideImageState: GuideImageState = .notStarted
    
    /// The position of the ARAnchor thats discovered
    @Published internal var anchorPosition: CGPoint?
    
    /// When false it indicates that the Image or Object has not been discovered and the subsequent animations have finished
    /// When the Image/Object Anchor is discovered there is a 3 second delay for animations to complete until the ContentView with Cards and Markers are displayed
    @Published internal var discoveryFlowHasFinished = false
    
    /// The ARImageAnchor or ARPlaneAnchor that is supplied by the ARSessionDelegate upon discovery of image or object in the physical world
    /// Stores useful information such as anchor position and image/object data. In the case of image anchor it is also used to instantiate an AnchorEntity
    private var arkitAnchor: ARAnchor?

    /// Initializer
    override public init() {
        super.init()
        self.arManager = ARManager()
        self.arManager.setDelegate(to: self)
        self.arManager.onSceneUpate = self.updateScene(on:)
    }
    
    internal init(arManager: ARManager) {
        super.init()
        self.arManager = arManager
        self.arManager.setDelegate(to: self)
        self.arManager.onSceneUpate = self.updateScene(on:)
    }
    
    // MARK: ViewModel Lifecycle
    
    /// Updates scene on frame change
    /// Used to project the location of the Entities from the world space onto the screen space
    /// Potential to add a closure here for developer to add logic on frame change
    private func updateScene(on event: SceneEvents.Update) {
        self.annotations
            .indices
            .forEach {
                if let internalEntity = annotations[$0].entity,
                   let projectedPoint = arManager.arView?.project(internalEntity.position(relativeTo: nil))
                {
                    annotations[$0].screenPosition = projectedPoint
                }
            }
    }
    
    func resetAllAnchors() {
        self.annotations.removeAll()
        self.arManager.removeRoot()
        self.anchorPosition = nil
        guard let _ = try? arManager.configureSession(options: [.removeExistingAnchors]) else { return }
    }
    
    func stopSession() {
        self.annotations.removeAll()
        self.anchorPosition = nil
        self.currentAnnotation = nil
        self.arManager.tearDown()
    }
    
    // MARK: Annotation Management
    
    /// Loads a strategy into the arModel and sets **annotations** member from the returned [ScreenAnnotation]
    public func load<Strategy: AnnotationLoadingStrategy>(loadingStrategy: Strategy) throws where CardItem == Strategy.CardItem {
        let sceneData = try loadingStrategy.load(with: self.arManager)
        self.annotations = sceneData.annotations
        self.guideImageState = .finished(sceneData.guideImage ?? UIImage(systemName: "xmark.icloud")!)
        self.setSelectedAnnotation(for: self.annotations.first)
    }
    
    /// Loads an asynchronous strategy into the arModel and sets **annotations** member from the returned [ScreenAnnotation]
    public func loadAsync<Strategy: AsyncAnnotationLoadingStrategy>(loadingStrategy: Strategy) throws where CardItem == Strategy.CardItem {
        try loadingStrategy.load(with: self.arManager, completionHandler: { annotations, guideImageState in
            DispatchQueue.main.async {
                self.annotations = annotations
                self.guideImageState = guideImageState
                self.setSelectedAnnotation(for: self.annotations.first)
            }
        })
    }
    
    func updateCardItemPositions() {
        self.annotations
            .indices
            .forEach {
                annotations[$0].updateCardPosition()
            }
    }
    
    func setAllMarkerState(to state: MarkerControl.State) {
        self.annotations
            .indices
            .forEach {
                annotations[$0].setMarkerState(to: state)
            }
    }
    
    func setMarkerState(for cardItem: CardItem?, to state: MarkerControl.State) {
        self.annotations
            .enumerated()
            .filter { $1.id == cardItem?.id }
            .forEach { index, _ in
                annotations[index].setMarkerState(to: state)
            }
    }
    
    func onlyShowEntity(for cardItem: CardItem) {
        self.setAllMarkerState(to: .ghost)
        self.annotations
            .enumerated()
            .filter { $1.id == cardItem.id }
            .forEach { index, _ in
                annotations[index].setMarkerState(to: .world)
            }
    }
    
    func setSelectedAnnotation(for annotation: ScreenAnnotation<CardItem>?) {
        if let annotation = annotation, let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
            self.annotations
                .indices
                .filter { $0 != index }
                .forEach {
                    annotations[$0].setMarkerState(to: .normal)
                }
            self.currentAnnotation = annotation
            self.annotations[index].setMarkerState(to: .selected)
        }
    }
    
    func addNewEntity(to cardItem: CardItem?) {
        guard let cardItem = cardItem else { return }
        
        let newEntity = ModelEntity.generateEntity()
        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.name = AnchorEntity.cameraAnchor
        cameraAnchor.addChild(newEntity)
        newEntity.position.z = -0.25
        
        self.annotations
            .enumerated()
            .filter { $1.id == cardItem.id }
            .forEach { index, _ in
                arManager.addAnchor(anchor: cameraAnchor)
                annotations[index].setEntity(to: newEntity)
            }
    }
    
    func dropEntity(for cardItem: CardItem?) {
        self.annotations
            .enumerated()
            .filter { $1.id == cardItem?.id }
            .forEach { index, _ in
                if let entity = annotations[index].entity as? HasCollision {
                    arManager.addChild(for: entity, preservingWorldTransform: true)
                    deleteCameraAnchor()
                }
            }
    }
    
    func deleteEntity(for cardItem: CardItem?) {
        self.annotations
            .enumerated()
            .filter { $1.id == cardItem?.id }
            .forEach { index, _ in
                annotations[index].removeEntity()
            }
    }
    
    func removeEntitiesFromScene() {
        self.arManager.removeEntityGestures()
        self.annotations
            .indices
            .forEach {
                annotations[$0].removeEntityFromScene()
            }
    }
    
    func reAddEntitiesToScene(exclude: [CardItem] = []) {
        self.annotations
            .enumerated()
            .filter { _, annotation in
                exclude.contains { card in
                    card.id != annotation.id
                }
            }
            .forEach { index, _ in
                if let entity = annotations[index].entity as? HasCollision, let position = annotations[index].card.position_ {
                    entity.position = position
                    arManager.addChild(for: entity)
                }
            }
    }
    
    func deleteCameraAnchor() {
        if let cameraAnchor = arManager.findEntity(named: AnchorEntity.cameraAnchor) as? HasAnchoring {
            self.arManager.removeAnchor(anchor: cameraAnchor)
        }
    }
    
    // MARK: Image / Object Anchor

    private func getAnchorPosition(for arAnchor: ARAnchor) -> CGPoint? {
        let anchorTranslation = SIMD3<Float>(x: arAnchor.transform.columns.3.x, y: arAnchor.transform.columns.3.y, z: arAnchor.transform.columns.3.z)
        return self.arManager.arView?.project(anchorTranslation)
    }
    
    private func showAnnotationsAfterDiscoveryFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + (self.discoveryFlowHasFinished ? 0 : 3)) {
            withAnimation { self.discoveryFlowHasFinished = true }
        }
    }

    // MARK: ARSession Delegate
    
    /// Tells the delegate that one or more anchors have been added to the session.
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if let imageAnchor = anchors.compactMap({ $0 as? ARImageAnchor }).first {
            guard let sceneRoot = arManager.sceneRoot else { return }
            self.arkitAnchor = imageAnchor
            self.arManager.addARKitAnchor(for: imageAnchor, children: [sceneRoot])
            self.showAnnotationsAfterDiscoveryFlow()
        } else if let objectAnchor = anchors.compactMap({ $0 as? ARObjectAnchor }).first {
            self.arkitAnchor = objectAnchor
            self.showAnnotationsAfterDiscoveryFlow()
        }
    }
    
    /// Provides a newly captured camera image and accompanying AR information to the delegate.
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard !self.discoveryFlowHasFinished else { return }

        if let arkitAnchor = arkitAnchor {
            self.anchorPosition = self.getAnchorPosition(for: arkitAnchor)
        }
    }
    
    // Work around for iOS 15 rendering issue
    /// Updates the  anchorEntities when the underlying ARAnchors update
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if let arAnchor = anchors.first, let anchorEntity = arManager.sceneAnchors[arAnchor.identifier] {
            anchorEntity.setTransformMatrix(arAnchor.transform, relativeTo: nil)
        }
    }
}
