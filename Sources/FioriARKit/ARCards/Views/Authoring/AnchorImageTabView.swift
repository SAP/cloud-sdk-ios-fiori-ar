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
    
    @State private var actionSheetPresented = false
    @State private var pickerPresented = false
    
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var imageName: String?
    
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
                    Button(action: { actionSheetPresented.toggle() }, label: {
                        Text("Upload Anchor Image")
                            .font(.system(size: 15))
                            .bold()
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
        .actionSheet(isPresented: $actionSheetPresented) {
            ActionSheet(title: Text("Choose an option..."),
                        message: Text("Selection for Anchor Image"),
                        buttons: [.default(Text("Camera"), action: {
                            pickerSource = .camera
                            pickerPresented.toggle()
                        }), .default(Text("Photos"), action: {
                            pickerSource = .photoLibrary
                            pickerPresented.toggle()
                        }), .cancel()])
        }
        .fullScreenCover(isPresented: $pickerPresented) {
            ImagePickerView(uiImage: $anchorImage, fileName: $imageName, sourceType: pickerSource)
                .edgesIgnoringSafeArea(.all)
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
                    .bold()
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
                            .foregroundColor(Color.black)
                        Spacer()
                        Button(action: {
                            anchorImage = nil
                        }, label: {
                            Text("Delete")
                                .foregroundColor(Color.black)
                                .bold()
                        })
                    }
                    .font(.system(size: 13))
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
