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
                Color.fioriNextPrimaryBackground
                CardPreview(cardItem: cardItem)
            }
            Spacer()
            Button(action: { onSelect?() }, label: {
                Text("Next")
                    .font(.system(size: 15, weight: .bold))
                    .frame(width: 343, height: 40)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.fioriNextTint)
                    )
                    .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 4, y: 2)
                    .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 2)
            })
                .padding(.bottom, 46)
        }
    }
}
