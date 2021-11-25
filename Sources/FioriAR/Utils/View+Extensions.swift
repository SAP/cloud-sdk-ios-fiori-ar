//
//  View+Extensions.swift
//
//
//  Created by O'Brien, Patrick on 5/3/21.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
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

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func adaptsToKeyboard() -> some View {
        modifier(AdaptsToKeyboard())
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
    
    /// Passes the Card Editing callback down from the environment
    ///
    /// - Parameters:
    ///     - perform: Returns a CardEditing with an associated value `CodableCardItem` that has been created, updated, or deleted
    func onSceneEdit(perform action: @escaping (SceneEditing) -> Void) -> some View {
        environment(\.onSceneEdit, action)
    }
}
