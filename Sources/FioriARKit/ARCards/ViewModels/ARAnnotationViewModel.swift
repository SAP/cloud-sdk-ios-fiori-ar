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
    
    /// The position of the ARAnchor thats discovered
    @Published internal var anchorPosition: CGPoint?
    
    /// When false it indicates that the Image or Object has not been discovered and the subsequent animations have finished
    /// When the Image/Object Anchor is discovered there is a 3 second delay for animations to complete until the ContentView with Cards and Markers are displayed
    @Published internal var discoveryFlowHasFinished = false
    
    /// The ARImageAnchor or ARPlaneAnchor that is supplied by the ARSessionDelegate upon discovery of image or object in the physical world
    /// Stores useful information such as anchor position and image/object data. In the case of image anchor it is also used to instantiate an AnchorEntity
    private var arkitAnchor: ARAnchor?
    
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
        for (index, entity) in self.annotations.enumerated() {
            guard let projectedPoint = arManager.arView?.project(entity.marker.internalEnitity.position(relativeTo: nil)) else { return }
            self.annotations[index].screenPosition = projectedPoint
        }
    }
    
    internal func cleanUpSession() {
        self.annotations.removeAll()
        self.currentAnnotation = nil
        self.arManager.tearDown()
    }
    
    // MARK: Annotation Management
    
    /// Loads a strategy into the arModel and sets **annotations** member from the returned [ScreenAnnotation]
    public func load<Strategy: AnnotationLoadingStrategy>(loadingStrategy: Strategy) where CardItem == Strategy.CardItem {
        do { self.annotations = try loadingStrategy.load(with: self.arManager) } catch { print("Annotation Loading Error: \(error)") }
        self.currentAnnotation = self.annotations.first
    }
    
    /// Sets the visibility of the Marker View for  a CardItem identified by its ID *Note: The `MarkerAnchor` still exists in the scene*
    public func setMarkerVisibility(for id: CardItem.ID, to isVisible: Bool) {
        for (index, annotation) in self.annotations.enumerated() where annotation.id == id {
            self.annotations[index].setMarkerVisibility(to: isVisible)
        }
    }
    
    // The carousel must recalculate and refresh the size of its container on card removal/insertion to center cards
//    public func setCardVisibility(for id: CardItem.ID, to isVisible: Bool) {
//        for (index, annotation) in self.annotations.enumerated() {
//            if annotation.id == id { annotations[index].setCardVisibility(to: isVisible) }
//        }
//    }
    // Cards are initially set to visible
    private func showAnnotationsAfterDiscoveryFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { self.discoveryFlowHasFinished = true }
            
            for (index, _) in self.annotations.enumerated() {
                self.annotations[index].setMarkerVisibility(to: true)
            }
        }
    }
    
    private func getAnchorPosition(for arAnchor: ARAnchor) -> CGPoint? {
        let anchorTranslation = SIMD3<Float>(x: arAnchor.transform.columns.3.x, y: arAnchor.transform.columns.3.y, z: arAnchor.transform.columns.3.z)
        return self.arManager.arView?.project(anchorTranslation)
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
}
