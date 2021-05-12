//
//  DemoEntities.swift
//  ARTestApp
//
//  Created by O'Brien, Patrick on 12/11/20.
//

import Foundation
import RealityKit
import UIKit

/// Wrapper class which can be used as a Entity  in the scene although the internal entity is preferred
/// It contains an internal Entity that defines the position of the annotation in 3D space and is used to work with Reality Composer

// Potential Uses:
//  - Debuggin Mode
//  - Editing Mode for adjusting position in app

internal class MarkerAnchor: Entity, HasAnchoring {
    
    public var internalEnitity: Entity! {
        didSet {
            hideInternalEntity()
        }
    }

    internal required init() {
        let internalEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .red, isMetallic: false)])
        internalEntity.generateCollisionShapes(recursive: true)
        self.internalEnitity = internalEntity
    }
    
    internal func hideInternalEntity() {
        let invisibleMaterial = OcclusionMaterial()
        self.internalEnitity.components[ModelComponent.self] = ModelComponent(mesh: MeshResource.generateBox(size: 0.1), materials: [invisibleMaterial])
    }
}
