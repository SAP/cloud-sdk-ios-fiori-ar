// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  File.swift
//  
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import SwiftUI

extension EnvironmentValues {
    public var markerModifier: AnyViewModifier {
        get { return self[MarkerModifierKey.self] }
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
        apply(content)
    }
}
