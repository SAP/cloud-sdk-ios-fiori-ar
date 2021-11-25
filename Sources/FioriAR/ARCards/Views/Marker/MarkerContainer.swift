//
//  MarkerContainer.swift
//
//
//  Created by O'Brien, Patrick on 2/4/21.
//

import SwiftUI

struct MarkerContainer<Label: View>: View {
    var _state: MarkerControl.State
    var _icon: Image?
    var _screenPosition: CGPoint?
    
    let _label: (MarkerControl.State, Image?) -> Label
    
    init(state: MarkerControl.State, icon: String?, screenPosition: CGPoint?, @ViewBuilder label: @escaping (MarkerControl.State, Image?) -> Label) {
        self._state = state
        self._icon = icon == nil ? nil : Image(systemName: icon!)
        self._screenPosition = screenPosition
        self._label = label
    }
    
    var label_: some View {
        _label(_state, _icon)
    }
}

extension MarkerContainer {
    var body: some View {
        Group {
            if let position = _screenPosition, _state != .notVisible, _state != .world {
                label_
                    .position(position)
            }
        }
    }
}
