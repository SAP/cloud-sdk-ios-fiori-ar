//
//  TitleBarView.swift
//
//
//  Created by O'Brien, Patrick on 9/24/21.
//

import SwiftUI

struct TitleBarView<LeftBarLabel, RightBarLabel>: View where LeftBarLabel: View, RightBarLabel: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var title: String
    
    var onLeftAction: (() -> Void)?
    var onRightAction: (() -> Void)?
    var rightDisabled: Bool
    
    var leftBarLabel: () -> LeftBarLabel
    var rightBarLabel: () -> RightBarLabel
    
    init(title: String,
         onLeftAction: (() -> Void)? = nil,
         onRightAction: (() -> Void)? = nil,
         rightDisabled: Bool = false,
         @ViewBuilder leftBarLabel: @escaping () -> LeftBarLabel,
         @ViewBuilder rightBarLabel: @escaping () -> RightBarLabel)
    {
        self.title = title
        self.onLeftAction = onLeftAction
        self.onRightAction = onRightAction
        self.rightDisabled = rightDisabled
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
            
            Text(title)
                .font(.fiori(forTextStyle: .body).weight(.black))
                .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                .lineLimit(1)
                .layoutPriority(1)
            
            HStack {
                Spacer()
                Button(action: { onRightAction?() }, label: {
                    rightBarLabel()
                })
                .disabled(rightDisabled)
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .padding(.top, verticalSizeClass == .compact ? 0 : 44)
        .padding(.horizontal, verticalSizeClass == .compact ? 40 : 0)
    }
}
