//
//  ContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriARKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ARCardListView()) {
                    Text("ARCards")
                }

                NavigationLink(destination: DownloadsView()) {
                    Text("Download Image Anchors")
                }

                NavigationLink(destination: DemoARService()) {
                    Text("Demo how to interact with SAP Mobile Services and its AR feature")
				}

                NavigationLink(destination: ARCardAuthoringContentView()) {
                    Text("Card Authoring")
                }
            }.navigationBarTitle("Examples")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
