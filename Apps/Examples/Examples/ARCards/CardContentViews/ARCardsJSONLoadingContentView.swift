//
//  ARCardsDefaultContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriARKit
import SwiftUI

struct ARCardsJSONLoadingContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<DecodableCardItem>()
    
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
        guard let anchorImage = UIImage(named: "qrImage"), let url = Bundle.main.url(forResource: "Tests", withExtension: "json") else { return }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let strategy = try RealityComposerStrategy(jsonData: jsonData, anchorImage: anchorImage, physicalWidth: 0.1, rcFile: "ExampleRC", rcScene: "ExampleScene")
            arModel.load(loadingStrategy: strategy)
        } catch {
            print(error)
        }
    }
}
