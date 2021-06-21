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
        let realityFilePath = FileManager.default.getDocumentsDirectory().appendingPathComponent(FileManager.realityFiles).appendingPathComponent("ExampleRC.reality")
        guard let anchorImage = UIImage(named: "qrImage"), let url = Bundle.main.url(forResource: "Tests", withExtension: "json") else { return }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let strategy = try RealityFileStrategy(jsonData: jsonData, anchorImage: anchorImage, physicalWidth: 0.1, realityFilePath: realityFilePath, rcScene: "ExampleScene")
            arModel.load(loadingStrategy: strategy)
        } catch {
            print(error)
        }
    }
}
