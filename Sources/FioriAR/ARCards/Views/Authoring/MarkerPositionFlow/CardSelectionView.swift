//
//  CardSelectionView.swift
//
//
//  Created by O'Brien, Patrick on 10/19/21.
//

import SwiftUI

struct CardSelectionView<CardItem: CardItemModel>: View {
    var cardItem: CardItem?
    var onSelect: (() -> Void)?
    
    var body: some View {
        VStack {
            ZStack {
                Color.preferredColor(.primaryBackground, background: .lightConstant)
                CardPreview(cardItem: cardItem)
            }
            Spacer()
            Button(action: { onSelect?() }, label: {
                Text("Next", bundle: .fioriAR)
                    .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                    .foregroundColor(Color.preferredColor(.secondaryGroupedBackground, background: .lightConstant))
                    .frame(width: 343, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.preferredColor(.tintColor, background: .lightConstant))
                    )
                    .shadow(color: Color.preferredColor(.tintColor, background: .lightConstant).opacity(0.16), radius: 4, y: 2)
                    .shadow(color: Color.preferredColor(.tintColor, background: .lightConstant).opacity(0.16), radius: 2)
            })
                .padding(.bottom, 46)
        }
    }
}
