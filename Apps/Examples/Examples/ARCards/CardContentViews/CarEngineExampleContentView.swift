//
//  CarEngineExampleContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/13/21.
//

import SwiftUI
import FioriARKit

struct CarEngineExampleContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<StringIdentifyingCardItem>()
    
    var body: some View {
        SingleImageARCardView(arModel: arModel,
                                image: Image("carSticker"),
                                cardAction: { id in
                                    // set the card action for id corresponding to the CardItemModel
                                    print(id)
                                })
                .onAppear(perform: loadData)
    }
    
    func loadData() {
        let cardItems = Tests.carEngineCardItems
        let strategy = RealityComposerStrategy(cardContents: cardItems, rcFile: "CarEngineRC", rcScene: "EngineScene")
        arModel.load(loadingStrategy: strategy)
    }
}
