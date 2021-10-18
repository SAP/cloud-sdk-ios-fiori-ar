//
//  ScreenAnnotation.swift
//
//
//  Created by O'Brien, Patrick on 3/16/21.
//

import CoreGraphics
import RealityKit
import SwiftUI

/// Wrapper struct for the **CardItem : CardItemModel**  and the real world anchoring position. Used to set the internal entity.

public struct ScreenAnnotation<CardItem: CardItemModel>: Identifiable, Equatable {
    public var id: CardItem.ID {
        self.card.id
    }
    
    internal var isSelected: Bool
    
    public var card: CardItem
    internal var entity: Entity?
    
    public internal(set) var isMarkerVisible: Bool
    public internal(set) var isCardVisible: Bool
    
    internal var screenPosition: CGPoint?

    public init(card: CardItem, isMarkerVisible: Bool = false, isCardVisible: Bool = true, isSelected: Bool = false) {
        self.card = card
        self.isMarkerVisible = isMarkerVisible
        self.isCardVisible = isCardVisible
        self.isSelected = isSelected
    }

    internal func setInternalEntityVisibility(to isVisible: Bool) {
        isVisible ? self.showInternalEntity() : self.hideInternalEntity()
    }
    
    internal mutating func toggleDimension() {
        if self.isMarkerVisible {
            self.setMarkerVisibility(to: false)
            self.showInternalEntity()
        } else {
            self.setMarkerVisibility(to: true)
            self.hideInternalEntity()
        }
    }
    
    // MARK: Screen
    
    internal mutating func setMarkerVisibility(to isVisible: Bool) {
        self.isMarkerVisible = isVisible
    }
    
    internal mutating func setCardVisibility(to isVisible: Bool) {
        self.isCardVisible = isVisible
    }
    
    internal mutating func setCardPosition(to position: SIMD3<Float>?) {
        self.card.position_ = position
    }
    
    // MARK: Entity
    
    /// Sets the internal within the EntityManager
    public mutating func setInternalEntity(with entity: Entity) {
        self.entity = entity
    }
    
    internal func hideInternalEntity() {
        self.entity?.components[ModelComponent.self] = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.03), materials: [OcclusionMaterial()])
    }
    
    internal func showInternalEntity() {
        self.entity?.components[ModelComponent.self] = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .red, isMetallic: false)])
    }
    
    public static func == (lhs: ScreenAnnotation<CardItem>, rhs: ScreenAnnotation<CardItem>) -> Bool {
        lhs.id == rhs.id
    }
}
