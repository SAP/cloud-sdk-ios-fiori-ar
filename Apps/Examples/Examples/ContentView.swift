//
//  ContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
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
                
                NavigationLink(destination: DownloadsView()) {
                    Text("Download Image Anchors")
                }
                
            }.navigationBarTitle("Examples")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
