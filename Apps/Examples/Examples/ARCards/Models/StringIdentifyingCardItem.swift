//
//  StringIdentifyingCardItem.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/13/21.
//

import FioriARKit
import SwiftUI

public struct StringIdentifyingCardItem: CardItemModel {
    public var id: String
    public var title_: String
    public var descriptionText_: String?
    public var detailImage_: Image?
    public var actionText_: String?
    public var icon_: Image?
    
    public init(id: String, title_: String, descriptionText_: String? = nil, detailImage_: Image? = nil, actionText_: String? = nil, icon_: Image? = nil) {
        self.id = id
        self.title_ = title_
        self.descriptionText_ = descriptionText_
        self.detailImage_ = detailImage_
        self.actionText_ = actionText_
        self.icon_ = icon_
    }
}
