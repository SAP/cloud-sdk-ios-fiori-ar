//
//  PagingView.swift
//
//
//  Created by O'Brien, Patrick on 10/12/21.
//

import SwiftUI

struct PagingView<Left, Right>: View where Left: View, Right: View {
    @Binding private var firstPage: Bool
    
    let left: () -> Left
    let right: () -> Right
    
    init(firstPage: Binding<Bool>, @ViewBuilder left: @escaping () -> Left, @ViewBuilder right: @escaping () -> Right) {
        _firstPage = firstPage
        self.left = left
        self.right = right
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack {
                    left()
                }
                .frame(width: geo.size.width, height: geo.size.height)

                VStack {
                    right()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .offset(x: firstPage ? 0 : -geo.size.width)
            .animation(.default, value: firstPage)
        }
    }
}
