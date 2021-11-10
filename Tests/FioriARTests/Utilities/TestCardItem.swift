//
//  MockARManager.swift
//  ExamplesTests
//
//  Created by O'Brien, Patrick on 6/3/21.
//

@testable import FioriAR
import SwiftUI

public struct TestCardItem: CardItemModel {
    public var id: String
    public var title_: String
    public var subtitle_: String?
    public var detailImage_: Data?
    public var actionText_: String?
    public var actionContentURL_: URL?
    public var icon_: String?
    public var position_: SIMD3<Float>?
}
