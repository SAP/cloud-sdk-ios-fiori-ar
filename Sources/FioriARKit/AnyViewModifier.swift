//
//  AnyViewModifier.swift
//
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import SwiftUI

public extension EnvironmentValues {
    var markerModifier: AnyViewModifier {
        get { self[MarkerModifierKey.self] }
        set { self[MarkerModifierKey.self] = newValue }
    }
}

struct MarkerModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

public struct AnyViewModifier: ViewModifier {
    var apply: (Content) -> AnyView
    var _concat: ((AnyViewModifier) -> AnyView)?
    
    public init<V: View>(_ transform: @escaping (Content) -> V) {
        self.apply = { AnyView(transform($0)) }
    }

    public func body(content: Content) -> AnyView {
        self.apply(content)
    }
}
