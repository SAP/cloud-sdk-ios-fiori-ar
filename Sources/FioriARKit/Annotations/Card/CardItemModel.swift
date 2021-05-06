// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  SwiftUIView.swift
//  
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import SwiftUI

public protocol CardItemModel: Identifiable, TitleComponent, DescriptionTextComponent, DetailImageComponent, ActionTextComponent, IconComponent { }

public protocol TitleComponent {
    var title_: String { get }
}

public protocol DescriptionTextComponent {
    var descriptionText_: String? { get }
}

public protocol DetailImageComponent {
    var detailImage_: Image? { get }
}

public protocol ActionTextComponent {
    var actionText_: String? { get }
}

public protocol IconComponent {
    var icon_: Image? { get }
}
