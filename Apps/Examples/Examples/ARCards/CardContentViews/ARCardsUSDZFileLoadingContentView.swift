//
//  ARCardsUSDZFileLoadingContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 6/22/21.
//

import FioriARKit
import SwiftUI

struct ARCardsUSDZFileLoadingContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<DecodableCardItem>()
    
    var body: some View {
        SingleImageARCardView(arModel: arModel,
                              image: Image("qrImage"),
                              cardAction: { id in
                                  // set the card action for id corresponding to the CardItemModel
                                  print(id)
                              })
            .onAppear(perform: loadInitialDataFromUSDZFile)
    }

    func loadInitialDataFromUSDZFile() {
        let usdzFilePath = FileManager.default.getDocumentsDirectory().appendingPathComponent(FileManager.usdzFiles).appendingPathComponent("ExampleRC.usdz")
        guard let absoluteUsdzPath = URL(string: "file://" + usdzFilePath.path),
              let anchorImage = UIImage(named: "qrImage"),
              let jsonUrl = Bundle.main.url(forResource: "Tests", withExtension: "json") else { return }
        
        do {
            let jsonData = try Data(contentsOf: jsonUrl)
            let strategy = try UsdzFileStrategy(jsonData: jsonData, anchorImage: anchorImage, physicalWidth: 0.1, usdzFilePath: absoluteUsdzPath)
            arModel.load(loadingStrategy: strategy)
        } catch {
            print(error)
        }
    }
}
