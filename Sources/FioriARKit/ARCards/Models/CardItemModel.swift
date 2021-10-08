//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import SwiftUI

public protocol CardItemModel: Identifiable, TitleComponent, SubtitleComponent, DetailImageComponent, ActionTextComponent, IconComponent {}

public protocol TitleComponent {
    var title_: String { get }
}

public protocol SubtitleComponent {
    var descriptionText_: String? { get }
}

public protocol DetailImageComponent {
    var detailImage_: Data? { get }
}

public protocol ActionTextComponent {
    var actionText_: String? { get }
}

public protocol IconComponent {
    var icon_: String? { get }
}

public struct CodableCardItem: CardItemModel, Codable {
    public var id: String
    public var title_: String
    public var descriptionText_: String?
    public var detailImage_: Data?
    public var actionText_: String?
    public var icon_: String?
    public var position_: Vector3?
    
    public init(id: String, title_: String, descriptionText_: String? = nil, detailImage_: Data? = nil, actionText_: String? = nil, icon_: String? = nil, position_: Vector3? = nil) {
        self.id = id
        self.title_ = title_
        self.descriptionText_ = descriptionText_
        self.detailImage_ = detailImage_
        self.actionText_ = actionText_
        self.icon_ = icon_
        self.position_ = position_
    }
}

public struct Vector3: Codable {
    public var x: Float
    public var y: Float
    public var z: Float
    
    static let zero = Vector3(x: .zero, y: .zero, z: .zero)
}
