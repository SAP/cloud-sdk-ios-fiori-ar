//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import SwiftUI

public protocol CardItemModel: Identifiable, TitleComponent, SubtitleComponent, DetailImageComponent, ActionTextComponent, IconComponent, PositionComponent {}

public protocol TitleComponent {
    var title_: String { get }
}

public protocol SubtitleComponent {
    var subtitle_: String? { get }
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

public protocol PositionComponent {
    var position_: SIMD3<Float>? { get set }
}

public struct CodableCardItem: CardItemModel, Codable, Equatable {
    public var id: String
    public var title_: String
    public var subtitle_: String?
    public var detailImage_: Data?
    public var actionText_: String?
    public var icon_: String?
    public var position_: SIMD3<Float>?
    
    public init(id: String, title_: String, subtitle_: String? = nil, detailImage_: Data? = nil, actionText_: String? = nil, icon_: String? = nil, position_: SIMD3<Float>? = nil) {
        self.id = id
        self.title_ = title_
        self.subtitle_ = subtitle_
        self.detailImage_ = detailImage_
        self.actionText_ = actionText_
        self.icon_ = icon_
        self.position_ = position_
    }
    
    public static func == (lhs: CodableCardItem, rhs: CodableCardItem) -> Bool {
        lhs.id == rhs.id
    }
}
