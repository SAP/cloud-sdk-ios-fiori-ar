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
                    Text(message.localizedString)
                        .foregroundColor(Color.preferredColor(.primaryLabel, background: .darkConstant, interface: .elevatedConstant))
                        .lineLimit(2)
                    Spacer()
                    Button("Close".localizedString) {
                        withAnimation { self.message = nil }
                    }
                    .foregroundColor(Color.preferredColor(.tintColor, background: .darkConstant))
                }
                .font(.fiori(forTextStyle: .subheadline))
                .padding(16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black)
        )
        .frame(maxWidth: .infinity)
    }
}

enum BannerMessage: String {
    case cardCreated = "A new annotation card is created."
    case sceneUpdated = "Scene update is successfully published."
    case loading = "Loading..."
    case syncFinished = "Sync finished."
    case failure = "Something went wrong."

    var localizedString: String {
        self.rawValue.localizedString
    }
}
