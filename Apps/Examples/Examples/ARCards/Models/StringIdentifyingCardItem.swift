//
//  StringIdentifyingCardItem.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/13/21.
//

import FioriAR
import SwiftUI

public struct StringIdentifyingCardItem: CardItemModel {
    public var id: String
    public var title_: String
    public var subtitle_: String?
    public var detailImage_: Data?
    public var image_: CardImage?
    public var actionText_: String?
    public var actionContentURL_: URL?
    public var icon_: String?
    public var position_: SIMD3<Float>?
}
