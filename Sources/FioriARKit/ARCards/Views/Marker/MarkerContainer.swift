//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 2/4/21.
//

import SwiftUI

internal struct MarkerContainer<Label: View>: View {
    var _state: MarkerControl.State
    var _icon: Image?
    var _screenPosition: CGPoint
    var _isMarkerVisible: Bool
    
    let _label: (MarkerControl.State, Image?) -> Label
    
    internal init(state: MarkerControl.State, icon: Image?, screenPosition: CGPoint, isMarkerVisible: Bool, @ViewBuilder label: @escaping (MarkerControl.State, Image?) -> Label) {
        self._state = state
        self._icon = icon
        self._screenPosition = screenPosition
        self._isMarkerVisible = isMarkerVisible
        self._label = label
    }
    
    internal var label_: some View {
        _label(_state, _icon)
    }
}

extension MarkerContainer {
    var body: some View {
        Group {
            if _isMarkerVisible {
                label_
                    .position(_screenPosition)
            }
        }
    }
}
