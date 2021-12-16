//
//  ContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriAR
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ARCardListView()) {
                    Text("ARCards")
                }
                
                NavigationLink(destination: ARCardAuthoringContentView()) {
                    Text("Card Authoring")
                }

                NavigationLink(destination: DownloadsView()) {
                    Text("Download Image Anchors")
                }
            }.navigationBarTitle("Examples")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
