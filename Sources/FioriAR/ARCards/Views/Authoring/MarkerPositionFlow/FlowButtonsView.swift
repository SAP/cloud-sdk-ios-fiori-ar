//
//  FlowButtonsView.swift
//
//
//  Created by O'Brien, Patrick on 10/19/21.
//

import SwiftUI

struct FlowButtonsView<CardItem>: View where CardItem: CardItemModel {
    @Binding var flowState: MarkerFlowState
    
    var cardItem: CardItem?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if flowState == .beforeDrop || flowState == .dropped {
                Button(action: {
                    if flowState == .beforeDrop {
                        flowState = .dropped
                    } else if flowState == .dropped {
                        flowState = .preview
                    }
                }, label: {
                    Text(flowState == .beforeDrop ? "Drop Marker".localizedString : "Preview".localizedString)
                        .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                        .foregroundColor(Color.preferredColor(.secondaryGroupedBackground, background: .lightConstant))
                        .frame(width: 343, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.preferredColor(.tintColor, background: .lightConstant))
                        )
                })
                    .padding(.bottom, 100)
            }
            
            if flowState == .preview {
                CardPreview(cardItem: cardItem)
                    .padding(.bottom, 46)
            }
        }
    }
}
