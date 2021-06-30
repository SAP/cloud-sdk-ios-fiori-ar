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
            NavigationLink(destination: ARCardsDefaultContentView()) {
                Text("ARCards - Default")
            }
            
            NavigationLink(destination: ARCardsViewBuilderContentView()) {
                Text("ARCards - ViewBuilder")
            }
            
            NavigationLink(destination: CarEngineExampleContentView()) {
                Text("2016 Engine Example")
            }
            
            NavigationLink(destination: ARCardsJSONLoadingContentView()) {
                Text("JSON Decoding Example")
            }
            
            NavigationLink(destination: ARCardsRealityFileLoadingContentView()) {
                Text("Reality File Example")
            }
        }.navigationBarTitle("ARCards")
    }
}
