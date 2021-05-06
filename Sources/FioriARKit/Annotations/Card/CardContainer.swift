// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 2/9/21.
//

import SwiftUI

internal struct CardContainer<Label: View, CardItem: CardItemModel>: View {
    
    var _isSelected: Bool
    var _cardItemModel: CardItem
    var _isCardVisible: Bool
    
    let _label: (CardItem, Bool) -> Label

    internal init(cardItemModel: CardItem, isSelected: Bool, isCardVisible: Bool, @ViewBuilder label: @escaping (CardItem, Bool) -> Label) {
        self._cardItemModel = cardItemModel
        self._isSelected = isSelected
        self._isCardVisible = isCardVisible
        self._label = label
    }
    
    @ViewBuilder var label_: some View {
        _label(_cardItemModel, _isSelected)
    }
}

extension CardContainer {
    internal var body: some View {
        Group {
            if _isCardVisible {
                label_
            }
        }
    }
}
