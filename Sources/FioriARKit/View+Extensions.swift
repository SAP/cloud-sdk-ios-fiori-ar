//
//  View+Extensions.swift
//
//
//  Created by O'Brien, Patrick on 5/3/21.
//

import SwiftUI

internal struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

internal extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color
                    .clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func animateOnAppear(animation: Animation, active enabled: Bool = true, _ action: @escaping () -> Void) -> some View {
        onAppear {
            guard enabled else { return }
            withAnimation(animation) {
                action()
            }
        }
    }
    
    func animateOnDisappear(animation: Animation, active enabled: Bool = true, _ action: @escaping () -> Void) -> some View {
        onDisappear {
            guard enabled else { return }
            withAnimation(animation) {
                action()
            }
        }
    }
}

public extension View {
    /// Passes the Carousel Options down from the environment
    ///
    /// - Parameters:
    ///     - options: CarouselOptions which modifies the behavior of the Carousel
    func carouselOptions(_ options: CarouselOptions) -> some View {
        environment(\.carouselOptions, options)
    }
}
