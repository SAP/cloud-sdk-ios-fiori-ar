//
//  ARCardsDefaultContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriARKit
import SwiftUI

struct ARCardsDefaultContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<StringIdentifyingCardItem>()
    
    var body: some View {
        SingleImageARCardView(arModel: arModel,
                              image: Image("qrImage"),
                              cardAction: { id in
                                  // set the card action for id corresponding to the CardItemModel
                                  print(id)
                              })
            .onAppear(perform: loadInitialData)
    }
    
    func loadInitialData() {
        let cardItems = Tests.carEngineCardItems
        guard let anchorImage = UIImage(named: "qrImage") else { return }
        let strategy = RealityComposerStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, rcFile: "ExampleRC", rcScene: "ExampleScene")
        let url = Bundle.main.url(forResource: "Tests", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let blah = RealityComposerStrategy(cardContents: cardItems, rcFile: "", rcScene: "", json: "")
        arModel.load(loadingStrategy: strategy)
    }
}
