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
    var onPublish: (() -> Void)?
    
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
                    Text("Drop Marker")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 343, height: 40)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.fioriNextTint)
                        )
                })
                    .padding(.bottom, 100)
            }
            
            if flowState == .preview {
                VStack(spacing: 20) {
                    CardPreview(cardItem: cardItem)
                    Button(action: {
                        onPublish?()
                        flowState = .arscene
                    }, label: {
                        Text("Publish")
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 343, height: 40)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.fioriNextTint)
                            )
                    })
                }
                .padding(.bottom, 46)
            }
        }
    }
}
