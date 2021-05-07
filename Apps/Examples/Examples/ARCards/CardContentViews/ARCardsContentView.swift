//
//  ARCardsDefaultContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import SwiftUI
import FioriARKit

struct ARCardsDefaultContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<ExampleCardItem>()
    
    var body: some View {
        ARAnnotationContentView(arModel: arModel,
                                image: Image("qrImage"),
                                cardAction: { id in
                                    // set the card action for id corresponding to the CardItemModel
                                })
                .onAppear(perform: loadData)
    }
    
    func loadData() {
        let cardItems = Tests.cardItems
        let strategy = RealityComposerStrategy(cardContents: cardItems, rcFile: "ExampleRC", rcScene: "ExampleScene")
        arModel.load(loadingStrategy: strategy)
    }
}
