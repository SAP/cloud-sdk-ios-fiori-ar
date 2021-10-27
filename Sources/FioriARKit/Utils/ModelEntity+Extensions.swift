//
//  Entity+Extensions.swift
//
//
//  Created by O'Brien, Patrick on 10/21/21.
//

import RealityKit

extension ModelEntity {
    static func generateEntity(radius: Float = 0.03) -> ModelEntity {
        let newEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: radius), materials: [OcclusionMaterial()])
        newEntity.generateCollisionShapes(recursive: true)
        return newEntity
    }
}

extension AnchorEntity {
    static let cameraAnchor = "CameraAnchor"
}
