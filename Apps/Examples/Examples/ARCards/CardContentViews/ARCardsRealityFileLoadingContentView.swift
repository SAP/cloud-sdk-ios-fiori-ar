//
//  ARCardsRealityFileloadingContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 6/17/21.
//

import FioriARKit
import SwiftUI

struct ARCardsRealityFileLoadingContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<StringIdentifyingCardItem>()
    
    var body: some View {
        SingleImageARCardView(arModel: arModel,
                              image: Image("qrImage"),
                              cardAction: { id in
                                  // set the card action for id corresponding to the CardItemModel
                                  print(id)
                              })
            .onAppear(perform: loadInitialDataFromRealityFile)
    }

    func loadInitialDataFromRealityFile() {
        let cardItems = Tests.carEngineCardItems
        let realityFilePath = FileManager.default.getDocumentsDirectory().appendingPathComponent(FileManager.realityFiles).appendingPathComponent("ExampleRC.reality")
        guard let anchorImage = UIImage(named: "qrImage") else { return }
        let strategy = RealityFileStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, realityFilePath: realityFilePath, rcScene: "ExampleScene")
        arModel.load(loadingStrategy: strategy)
    }
}
