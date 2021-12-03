//
//  AnchorImageTabView.swift
//
//
//  Created by Diaz, Ernesto on 9/17/21.
//

import SwiftUI

struct AnchorImageTabView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @Binding var anchorImage: UIImage?
    @Binding var physicalWidth: String
    
    @State private var imageName: String?
    @State private var anchorImageFormPresented = false
    
    let onDismiss: (() -> Void)?
    
    var body: some View {
        VStack {
            if let _ = anchorImage {
                ImageAnchorView(anchorImage: $anchorImage, imageName: imageName ?? "")
                    .onTapGesture {
                        anchorImageFormPresented.toggle()
                    }
            } else {
                VStack(spacing: 46) {
                    Text("The anchor is an image in the real world that the software uses to place markers in relation to the anchor. Choose an image that can be recognized by the software.", bundle: .fioriAR)
                        .multilineTextAlignment(.center)
                        .font(.fiori(forTextStyle: .body))
                        .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                    Button(action: { anchorImageFormPresented.toggle() }, label: {
                        Text("Upload Image Anchor", bundle: .fioriAR)
                            .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                            .foregroundColor(Color.preferredColor(.secondaryGroupedBackground, background: .lightConstant))
                            .frame(width: 187, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.preferredColor(.tintColor, background: .lightConstant))
                            )
                            .shadow(color: Color.preferredColor(.tintColor, background: .lightConstant).opacity(0.16), radius: 4, y: 2)
                            .shadow(color: Color.preferredColor(.tintColor, background: .lightConstant).opacity(0.16), radius: 2)
                    })
                }
                .padding(.top, verticalSizeClass == .compact ? 30 : 148)
                .padding(.horizontal, 32)
            }
            Spacer()
        }
        .background(Color.white)
        .sheet(isPresented: $anchorImageFormPresented, onDismiss: onDismiss) {
            AnchorImageFormView(anchorImage: $anchorImage,
                                physicalWidth: $physicalWidth,
                                imageName: $imageName) {
                anchorImageFormPresented.toggle()
            }
        }
    }
}

struct ImageAnchorView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Binding var anchorImage: UIImage?
    var imageName: String
    
    init(anchorImage: Binding<UIImage?>, imageName: String = "") {
        self._anchorImage = anchorImage
        self.imageName = imageName
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Image Anchor", bundle: .fioriAR)
                    .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                    .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                Spacer()
            }
            .padding(.bottom, 16)
            if let anchorImage = anchorImage {
                Image(uiImage: anchorImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 343)
                    .cornerRadius(16)
                    .padding(.bottom, 8)
            }
            HStack {
                Text("Tap the image to edit it.", bundle: .fioriAR)
                    .font(.fiori(forTextStyle: .footnote).weight(.bold))
                    .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                Spacer()
            }
        }
        .frame(width: 343)
        .padding(.horizontal, verticalSizeClass == .compact ? 0 : 16)
    }
}
