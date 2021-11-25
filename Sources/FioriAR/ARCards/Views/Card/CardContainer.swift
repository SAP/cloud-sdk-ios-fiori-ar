//
//  CardContainer.swift
//
//
//  Created by O'Brien, Patrick on 2/9/21.
//

import SwiftUI

struct CardContainer<Label: View, CardItem: CardItemModel>: View {
    var _isSelected: Bool
    var _cardItemModel: CardItem
    
    let _label: (CardItem, Bool) -> Label

    init(cardItemModel: CardItem, isSelected: Bool, @ViewBuilder label: @escaping (CardItem, Bool) -> Label) {
        self._cardItemModel = cardItemModel
        self._isSelected = isSelected
        self._label = label
    }
    
    @ViewBuilder var label_: some View {
        _label(_cardItemModel, _isSelected)
    }
}

extension CardContainer {
    var body: some View {
        label_
    }
}
