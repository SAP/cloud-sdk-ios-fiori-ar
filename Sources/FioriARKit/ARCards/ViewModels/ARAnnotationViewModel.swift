//
//  DemoViewModels.swift
//  ARTestApp
//
//  Created by O'Brien, Patrick on 1/20/21.
//

import SwiftUI
import ARKit
import RealityKit
import Combine


open class ARAnnotationViewModel<CardItem: CardItemModel>: NSObject, HasARModel, ARSessionDelegate {
    
    internal var arView: ARView?
    
    /**
     An array of **ScreenAnnotations** which are displayed in the scene  contain the marker position and their card contents
    
     - The annotations internal entities within this list should be in the ARView scene.
     - Set by the annotation loading strategy
     */
    @Published public internal(set) var annotations: [ScreenAnnotation<CardItem>] = [ScreenAnnotation<CardItem>]()
    
    /// The ScreenAnnotation that is focused on in the scene. The CardView and MarkerView will be in their selected states
    @Published public internal(set) var currentAnnotation: ScreenAnnotation<CardItem>?
    
    /// The position of the ARAnchor thats discovered
    @Published internal var anchorPosition: CGPoint?
    
    /**
     When false it indicates that the Image or Object has not been discovered and the subsequent animations have finished
    
     - When the Image/Object Anchor is discovered there is a 3 second delay for animations to complete until the ContentView with Cards and Markers are displayed
     */
    @Published internal var discoveryFlowHasFinished = false

    /// The ARAnchor that represents the position
    private var arkitAnchor: ARAnchor?
    
    /// :nodoc:
    private var subscription: Cancellable!
    
    public override init() {
        super.init()
        arView = ARView(frame: .zero)
        arView?.automaticallyConfigureSession = true
        arView?.session.delegate = self
    }
    
    // MARK: ViewModel Lifecycle
    
    /// Updates scene on frame change
    /// Used to project the location of the Entities from the world space onto the screen space
    // Potential to add a closure here for developer to add logic on frame change
    public func updateScene(on event: SceneEvents.Update) {
        for (index, entity) in annotations.enumerated() {
            guard let projectedPoint = arView?.project(entity.marker.internalEnitity.position(relativeTo: nil)) else { return }
            annotations[index].screenPosition = projectedPoint
        }
    }
    
    internal func cleanUpSession() {
        annotations.removeAll()
        currentAnnotation = nil
        subscription = nil
        arView = nil
    }
    
    // MARK: Annotation Management
    
    /// Loads a strategy into the arModel and sets **annotations** member from the returned [ScreenAnnotation]
    public func load<Strategy: AnnotationLoadingStrategy>(loadingStrategy: Strategy) where CardItem == Strategy.CardItem {
        guard let arview = arView else { return }
        self.annotations = loadingStrategy.load(arView: arview)
        currentAnnotation = annotations.first

        subscription = arview.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in
            self.updateScene(on: $0)
        }
    }
    
    public func setMarkerVisibility(for id: CardItem.ID, to isVisible: Bool) {
        for (index, annotation) in self.annotations.enumerated() {
            if annotation.id == id { annotations[index].setMarkerVisibility(to: isVisible) }
        }
    }
    
    // TODO: The carousel must recalculate and refresh the size of its container on card removal/insertion to center cards
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
        guard let objectCenter = arView?.project(anchorTranslation) else { return nil }
        return objectCenter
    }

    // MARK: ARSession Delegate
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if let imageAnchor = anchors.compactMap({ $0 as? ARImageAnchor }).first {
            arkitAnchor = imageAnchor
            showAnnotationsAfterDiscoveryFlow()
        } else if let objectAnchor = anchors.compactMap({ $0 as? ARObjectAnchor }).first {
            arkitAnchor = objectAnchor
            showAnnotationsAfterDiscoveryFlow()
        }
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard !discoveryFlowHasFinished else { return }

        if let arkitAnchor = arkitAnchor {
            anchorPosition = getAnchorPosition(for: arkitAnchor)
        }
    }
}
