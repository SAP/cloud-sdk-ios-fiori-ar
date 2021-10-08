//
//  MockARManager.swift
//  ExamplesTests
//
//  Created by O'Brien, Patrick on 6/3/21.
//

@testable import FioriARKit
import SwiftUI

public struct TestCardItem: CardItemModel {
    public var id: String
    public var title_: String
    public var subtitle_: String?
    public var detailImage_: Data?
    public var actionText_: String?
    public var icon_: String?
    
    public init(id: String, title_: String, subtitle_: String? = nil, detailImage_: Data? = nil, actionText_: String? = nil, icon_: String? = nil) {
        self.id = id
        self.title_ = title_
        self.subtitle_ = subtitle_
        self.detailImage_ = detailImage_
        self.actionText_ = actionText_
        self.icon_ = icon_
    }
}
