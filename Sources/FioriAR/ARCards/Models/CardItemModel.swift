//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import SwiftUI

/// Protocol to be implemented by a model to represent an AR annotation card
public protocol CardItemModel: Identifiable, Equatable, TitleComponent, SubtitleComponent, DetailImageComponent, ActionTextComponent, ActionContentComponent, IconComponent, PositionComponent {}

/// Protocol representing a component with a title
public protocol TitleComponent {
    /// Title
    var title_: String { get }
}

/// Protocol representing a component with a subtitle
public protocol SubtitleComponent {
    /// Subtitle
    var subtitle_: String? { get }
}

/// Protocol representing a component with a detail/cover image
public protocol DetailImageComponent {
    /// Detail / Cover image
    var detailImage_: Data? { get }
}

/// Protocol representing a component with an action text
public protocol ActionTextComponent {
    /// Action text to be displayed for a card
    var actionText_: String? { get }
}

/// Protocol representing a component with a triggerable action
public protocol ActionContentComponent {
    /// URL to be invoked when action gets triggered
    var actionContentURL_: URL? { get }
}

/// Protocol representing a component with an icon
public protocol IconComponent {
    /// Icon used for the marker/card
    var icon_: String? { get }
}

/// Protocol representing a component with a position on the x, y and z position
public protocol PositionComponent {
    /// Position of the annotation anchor on the x, y and z axis
    var position_: SIMD3<Float>? { get set }
}

/// A concrete type of `CardItemModel` which conforms to `Codable`. Used for card authoring scena
public struct CodableCardItem: CardItemModel, Codable {
    /// Identifier
    public var id: String
    /// Titile
    public var title_: String
    /// Subtitle
    public var subtitle_: String?
    /// Detail / Cover image (read-only)
    public var detailImage_: Data? {
        self.image_?.data
    }

    /// Detail / Cover image (writable)
    /// Note: prefer this property over `detailImage_`
    public var image_: CardImage?
    /// Action text to be displayed for a card
    public var actionText_: String?
    /// URL to be invoked when action gets triggered
    public var actionContentURL_: URL?
    /// Icon used for the marker/card
    public var icon_: String?
    /// Position of the annotation anchor on the x, y and z axis
    public var position_: SIMD3<Float>?

    /// Initializer
    ///
    /// - Parameters:
    ///   - id: Card's title
    ///   - title_: Card's title
    ///   - subtitle_: Card's subtitle
    ///   - detailImage_: Card's image (read-only) **Legacy. Use `image` instead**
    ///   - image: Cards's image
    ///   - actionText_: Card's action
    ///   - actionContentURL_: URL to be invoked card's when action gets triggered
    ///   - icon_: Cards's icon
    ///   - position_: Position of the marker on the x, y and z axis
    public init(id: String,
                title_: String,
                subtitle_: String? = nil,
                detailImage_: Data? = nil,
                image: CardImage? = nil,
                actionText_: String? = nil,
                actionContentURL_: URL? = nil,
                icon_: String? = nil,
                position_: SIMD3<Float>? = nil)
    {
        self.id = id
        self.title_ = title_
        self.subtitle_ = subtitle_
        if detailImage_ != nil {
            self.image_ = CardImage(data: detailImage_)
        } else {
            self.image_ = image
        }
        self.actionText_ = actionText_
        self.actionContentURL_ = actionContentURL_
        self.icon_ = icon_
        self.position_ = position_
    }
}

extension Array where Element == CodableCardItem {
    var asIdSet: Set<String> {
        let ids = self.map(\.id)
        return Set(ids)
    }
}
