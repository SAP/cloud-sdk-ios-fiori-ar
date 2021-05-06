// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  DemoEntities.swift
//  ARTestApp
//
//  Created by O'Brien, Patrick on 12/11/20.
//

import Foundation
import RealityKit
import UIKit

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
