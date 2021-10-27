//
//  CardSelectionView.swift
//
//
//  Created by O'Brien, Patrick on 10/19/21.
//

import SwiftUI

struct CardSelectionView<CardItem: CardItemModel>: View {
    var cardItem: CardItem?
    var displayActions: Bool = true
    var onBack: (() -> Void)?
    var onSelect: (() -> Void)?
    
    var body: some View {
        VStack {
            ZStack {
                Color.fioriNextPrimaryBackground
                CardPreview(cardItem: cardItem)
            }
            
            Spacer()
            
            HStack {
                Button(action: { onBack?() }, label: {
                    Text("Back")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 122, height: 40)
                        .foregroundColor(.black)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
                        .shadow(color: Color.black.opacity(0.24), radius: 2)
                })
                
                Button(action: { onSelect?() }, label: {
                    Text("Select")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 213, height: 40)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.fioriNextTint)
                        )
                        .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 4, y: 2)
                        .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 2)
                })
            }
            .padding(.bottom, 46)
        }
    }
}
