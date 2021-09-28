//
//  TitleBarView.swift
//
//
//  Created by O'Brien, Patrick on 9/24/21.
//

import SwiftUI

struct TitleBarView<LeftBarLabel, RightBarLabel>: View where LeftBarLabel: View, RightBarLabel: View {
    var title: String
    var onLeftAction: (() -> Void)?
    var onRightAction: (() -> Void)?
    
    var leftBarLabel: () -> LeftBarLabel
    var rightBarLabel: () -> RightBarLabel
    
    init(onLeftAction: (() -> Void)? = nil,
         onRightAction: (() -> Void)? = nil,
         title: String,
         @ViewBuilder leftBarLabel: @escaping () -> LeftBarLabel,
         @ViewBuilder rightBarLabel: @escaping () -> RightBarLabel)
    {
        self.onLeftAction = onLeftAction
        self.onRightAction = onRightAction
        self.title = title
        self.leftBarLabel = leftBarLabel
        self.rightBarLabel = rightBarLabel
    }
    
    var body: some View {
        HStack {
            HStack {
                Button(action: { onLeftAction?() }, label: {
                    leftBarLabel()
                })
                Spacer()
            }
            
            Text(title).bold()
            
            HStack {
                Spacer()
                Button(action: { onRightAction?() }, label: {
                    rightBarLabel()
                })
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .padding(.top, 44)
    }
}
