//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import SwiftUI

public protocol CardItemModel: Identifiable, Equatable, TitleComponent, SubtitleComponent, DetailImageComponent, ActionTextComponent, ActionContentComponent, IconComponent, PositionComponent {}

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

public protocol ActionContentComponent {
    var actionContentURL_: URL? { get }
}

public protocol IconComponent {
    var icon_: String? { get }
}

public protocol PositionComponent {
    var position_: SIMD3<Float>? { get set }
}

public struct CodableCardItem: CardItemModel, Codable {
    public var id: String
    public var title_: String
    public var subtitle_: String?
    public var detailImage_: Data?
    public var actionText_: String?
    public var actionContentURL_: URL?
    public var icon_: String?
    public var position_: SIMD3<Float>?
    
    public init(id: String,
                title_: String,
                subtitle_: String? = nil,
                detailImage_: Data? = nil,
                actionText_: String? = nil,
                actionContentURL_: URL? = nil,
                icon_: String? = nil,
                position_: SIMD3<Float>? = nil)
    {
        self.id = id
        self.title_ = title_
        self.subtitle_ = subtitle_
        self.detailImage_ = detailImage_
        self.actionText_ = actionText_
        self.actionContentURL_ = actionContentURL_
        self.icon_ = icon_
        self.position_ = position_
    }
}
