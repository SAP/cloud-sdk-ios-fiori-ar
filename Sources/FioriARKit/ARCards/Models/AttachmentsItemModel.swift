//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 9/16/21.
//

import SwiftUI

public struct AttachmentItemModel: Identifiable {
    public var id = UUID()
    public var title: String = ""
    public var subtitle: String = ""
    public var info: String = ""
    public var image: Image?
    public var icon: Image?
    
    // Placeholder concept for now
    static let addAttachmentModel = AttachmentItemModel(title: Self.addAttachment)
    static let addAttachment = "AddAttachment"
}
