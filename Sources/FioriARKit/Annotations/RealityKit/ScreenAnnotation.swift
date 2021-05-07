//
//  File.swift
//
//
//  Created by O'Brien, Patrick on 3/16/21.
//

import CoreGraphics
import SwiftUI
import RealityKit

/// Wrapper struct for the **CardItem : CardItemModel**  and the real world anchoring position. Used to set the internal entity.

public struct ScreenAnnotation<CardItem: CardItemModel>: Identifiable, Equatable {

    public var id: CardItem.ID {
        card.id
    }
    
    public var icon: Image? {
        card.icon_
    }
    
    public var card: CardItem
    
    public internal(set) var isMarkerVisible: Bool
    public internal(set) var isCardVisible: Bool
    
    internal var marker: MarkerAnchor
    internal var screenPosition: CGPoint
    internal var isSelected: Bool

    public init(card: CardItem, isMarkerVisible: Bool = false, isCardVisible: Bool = true, isSelected: Bool = false) {
        self.marker = MarkerAnchor()
        self.card = card
        self.isMarkerVisible = isMarkerVisible
        self.isCardVisible = isCardVisible
        self.screenPosition = CGPoint(x: -200, y: -200)
        self.isSelected = isSelected
    }
    
    public func setInternalEntity(with entity: Entity) {
        self.marker.internalEnitity = entity
    }
    
    internal mutating func setMarkerVisibility(to isVisible: Bool) {
        self.isMarkerVisible = isVisible
    }
    
    internal mutating func setCardVisibility(to isVisible: Bool) {
        self.isCardVisible = isVisible
    }
    
    public static func == (lhs: ScreenAnnotation<CardItem>, rhs: ScreenAnnotation<CardItem>) -> Bool {
        lhs.id == rhs.id
    }
}
