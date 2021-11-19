//
//  SwiftUIView.swift
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
    
    var body: some View {
        VStack {
            if let _ = anchorImage {
                ImageAnchorView(anchorImage: $anchorImage, imageName: imageName ?? "")
                    .onTapGesture {
                        anchorImageFormPresented.toggle()
                    }
            } else {
                VStack(spacing: 46) {
                    Text("The anchor is an image that the software can recognize to successfully place the markers in relation to the anchor. Make sure that the anchor image is scannable on the site of the experience.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.black)
                        .font(.system(size: 17))
                    Button(action: { anchorImageFormPresented.toggle() }, label: {
                        Text("Upload Anchor Image")
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 187, height: 40)
                            .foregroundColor(.white)
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
        .sheet(isPresented: $anchorImageFormPresented) {
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
                Text("Anchor Image")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.black)
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
                Text("Tab the image to edit")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray)
                Spacer()
            }
        }
        .frame(width: 343)
        .padding(.horizontal, verticalSizeClass == .compact ? 0 : 16)
    }
}
