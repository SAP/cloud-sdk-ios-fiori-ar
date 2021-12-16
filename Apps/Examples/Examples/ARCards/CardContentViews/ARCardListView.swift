//
//  ARCardListView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 6/29/21.
//

import SwiftUI

struct ARCardListView: View {
    var body: some View {
        List {
            NavigationLink(destination: ARCardsUSDZFileLoadingContentView()) {
                Text("USDZ File Strategy")
            }
            
            NavigationLink(destination: ARCardsRealityFileLoadingContentView()) {
                Text("Reality File Strategy")
            }
            
            NavigationLink(destination: ARCardsDefaultContentView()) {
                Text("RCProject Strategy")
            }

            NavigationLink(destination: ARCardsViewBuilderContentView()) {
                Text("ViewBuilder Example")
            }
            
            NavigationLink(destination: CarEngineExampleContentView()) {
                Text("2016 Engine Example")
            }
            
            NavigationLink(destination: ARCardsJSONLoadingContentView()) {
                Text("JSON Decoding Example")
            }
            
            NavigationLink(destination: ARCardsServiceView()) {
                Text("Service Strategy - View Only")
            }
            
            NavigationLink(destination: ARCardAuthoringContentView()) {
                Text("Card Authoring")
            }
            
            NavigationLink(destination: SceneAuthoringWithUIKitView()) {
                Text("Card Authoring - UIKit")
            }
            
        }.navigationBarTitle("ARCards")
    }
}
