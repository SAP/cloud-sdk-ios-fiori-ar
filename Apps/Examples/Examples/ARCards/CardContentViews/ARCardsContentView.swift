//
//  ARCardsDefaultContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriARKit
import SwiftUI

struct ARCardsDefaultContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<StringIdentifyingCardItem>() // ARAnnotationViewModel<CodableCardItem>()

    var body: some View {
        ARAnnotationsView(arModel: arModel,
                          cardAction: { id in
                              // set the card action for id corresponding to the CardItemModel
                              print(id)
                          })
            .onAppear(perform: loadInitialData) // loadSimulatedAsyncExampleData
    }
    
    func loadInitialData() {
        let cardItems = Tests.carEngineCardItems
        guard let anchorImage = UIImage(named: "qrImage") else { return }
        let strategy = RCProjectStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, rcFile: "ExampleRC", rcScene: "ExampleScene")
        
        do {
            try self.arModel.load(loadingStrategy: strategy)
        } catch {
            print(error)
        }
    }
    
//    func loadSimulatedAsyncExampleData() {
//        let cardItems = Tests.codableEngineCardItems
//        guard let anchorImage = UIImage(named: "qrImage") else { return }
//        let strategy = RCProjectStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, rcFile: "ExampleRC", rcScene: "ExampleScene")
//
//        do {
//            try arModel.loadAsync(loadingStrategy: strategy)
//        } catch {
//            print(error)
//        }
//    }
}
