// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  SwiftUIView.swift
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
    
    func animateOnAppear(animation: Animation, active enabled: Bool = true , _ action: @escaping () -> Void) -> some View {
        return onAppear {
            guard enabled else { return }
            withAnimation(animation) {
                action()
            }
        }
    }
    
    func animateOnDisappear(animation: Animation, active enabled: Bool = true , _ action: @escaping () -> Void) -> some View {
        return onDisappear {
            guard enabled else { return }
            withAnimation(animation) {
                action()
            }
        }
    }
}

public extension View {
    func carouselOptions(_ options: CarouselOptions) -> some View {
        environment(\.carouselOptions, options)
    }
}


