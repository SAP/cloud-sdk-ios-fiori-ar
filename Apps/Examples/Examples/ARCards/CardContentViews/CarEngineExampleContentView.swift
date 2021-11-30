//
//  CarEngineExampleContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/13/21.
//

import FioriAR
import SwiftUI

struct CarEngineExampleContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<StringIdentifyingCardItem>()
    
    var body: some View {
        ARAnnotationsView(arModel: arModel,
                          guideImage: UIImage(named: "qrImage"),
                          cardAction: { id in
                              // set the card action for id corresponding to the CardItemModel
                              print(id)
                          })
            .onAppear(perform: loadData)
    }
    
    func loadData() {
        let cardItems = Tests.carEngineCardItems
        guard let anchorImage = UIImage(named: "carSticker") else { return }
        let strategy = RCProjectStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.15, rcFile: "CarEngineRC1", rcScene: "EngineScene")
        do {
            try self.arModel.load(loadingStrategy: strategy)
        } catch {
            print(error)
        }
    }
}
