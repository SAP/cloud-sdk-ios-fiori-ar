//
//  ExampleCardItem.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriARKit
import SwiftUI

public struct ExampleCardItem: CardItemModel {
    public var id: Int
    public var title_: String
    public var descriptionText_: String?
    public var detailImage_: Data?
    public var actionText_: String?
    public var icon_: String?
    
    public init(id: Int, title_: String, descriptionText_: String? = nil, detailImage_: Data? = nil, actionText_: String? = nil, icon_: String? = nil) {
        self.id = id
        self.title_ = title_
        self.descriptionText_ = descriptionText_
        self.detailImage_ = detailImage_
        self.actionText_ = actionText_
        self.icon_ = icon_
    }
}
