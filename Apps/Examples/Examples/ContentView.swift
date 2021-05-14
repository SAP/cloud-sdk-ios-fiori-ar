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
                NavigationLink(destination:
                                ARCardsDefaultContentView()
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                ) {
                    Text("ARCards - Default")
                }
                
                NavigationLink(destination:
                                ARCardsViewBuilderContentView()
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                ) {
                    Text("ARCards - ViewBuilder")
                }
                
                NavigationLink(destination:
                                CarEngineExampleContentView()
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                ) {
                    Text("2016 Honda Engine Example")
                }
                
                NavigationLink(destination: DownloadsView()) {
                    Text("Download Image Anchors")
                }
                
            }.navigationBarTitle("Examples")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

