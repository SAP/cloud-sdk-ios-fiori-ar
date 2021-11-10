//
//  ARCardsDefaultContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriAR
import SwiftUI

struct ARCardsJSONLoadingContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<CodableCardItem>()
    
    var body: some View {
        ARAnnotationsView(arModel: arModel,
                          guideImage: UIImage(named: "qrImage"),
                          cardAction: { id in
                              // set the card action for id corresponding to the CardItemModel
                              print(id)
                          })
            .onAppear(perform: loadInitialData)
    }
    
    func loadInitialData() {
        let realityFilePath = FileManager.default.getDocumentsDirectory().appendingPathComponent(FileManager.realityFiles).appendingPathComponent("ExampleRC.reality")
        guard let anchorImage = UIImage(named: "qrImage"), let jsonUrl = Bundle.main.url(forResource: "Tests", withExtension: "json") else { return }
        
        do {
            let jsonData = try Data(contentsOf: jsonUrl)
            let strategy = try RealityFileStrategy(jsonData: jsonData, anchorImage: anchorImage, physicalWidth: 0.1, realityFilePath: realityFilePath, rcScene: "ExampleScene")
            try arModel.load(loadingStrategy: strategy)
        } catch {
            print(error)
        }
    }
}
