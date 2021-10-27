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
                                    .fill(Color.fioriNextTint)
                            )
                            .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 4, y: 2)
                            .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 2)
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
        VStack(spacing: 16) {
            HStack {
                Text("Image Anchor")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.black)
                Spacer()
            }
            ZStack {
                Color.fioriNextSecondaryFill.opacity(0.24)
                VStack {
                    if let anchorImage = anchorImage {
                        Image(uiImage: anchorImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 196)
                            .clipped()
                            .contentShape(Rectangle())
                            .padding(.top, verticalSizeClass == .compact ? 0 : 60)
                            .padding(.horizontal, verticalSizeClass == .compact ? 180 : 0)
                    }
                    
                    Spacer()
                        
                    HStack {
                        Text(imageName)
                        Spacer()
                        Button("Delete") {
                            anchorImage = nil
                        }
                    }
                    .foregroundColor(Color.black)
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.bottom, verticalSizeClass == .compact ? 13 : 21)
                }
            }
            .frame(maxHeight: verticalSizeClass == .compact ? .infinity : 357)
            .cornerRadius(10, corners: verticalSizeClass == .compact ? [.topLeft, .topRight] : .allCorners)
        }
        .padding(.horizontal, verticalSizeClass == .compact ? 0 : 16)
    }
}
