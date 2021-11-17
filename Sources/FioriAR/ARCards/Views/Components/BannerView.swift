//
//  BannerView.swift
//
//
//  Created by O'Brien, Patrick on 11/12/21.
//

import SwiftUI

struct BannerView: View {
    @Binding var message: BannerMessage?
    
    var body: some View {
        VStack {
            if let message = message {
                HStack {
                    Text(message.rawValue)
                        .foregroundColor(Color.white)
                    Spacer()
                    Button("Close") {
                        withAnimation { self.message = nil }
                    }
                }
                .font(.system(size: 15))
                .padding(16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black)
        )
        .frame(width: 351, height: 52)
    }
}

enum BannerMessage: String {
    case sceneUpdated = "Scene Updated"
    case pinAnnotationsFirst = "Pin all Annotations First"
    case failure = "Oops, something went wrong..."
    case loading = "Loading..."
    case completed = "Sync Finished"
}
