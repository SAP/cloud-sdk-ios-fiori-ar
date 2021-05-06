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
            }
            .navigationBarTitle("Examples")
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

