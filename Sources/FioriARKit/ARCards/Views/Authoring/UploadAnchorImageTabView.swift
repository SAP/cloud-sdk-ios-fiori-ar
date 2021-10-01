//
//  SwiftUIView.swift
//
//
//  Created by Diaz, Ernesto on 9/17/21.
//

import SwiftUI

struct UploadAnchorImageTabView: View {
    @Environment(\.verticalSizeClass) var vSizeClass
    
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
                                    .fill(Color.fioriNextBlue)
                            )
                    })
                }
                .padding(.top, vSizeClass == .compact ? 30 : 148)
                .padding(.horizontal, 32)
            }
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
            ImagePickerView(image: .constant(nil), uiImage: $anchorImage, fileName: $imageName, sourceType: pickerSource)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ImageAnchorView: View {
    @Environment(\.verticalSizeClass) var vSizeClass
    @Binding var anchorImage: UIImage?
    var imageName: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Image Anchor")
                    .bold()
                Spacer()
            }
            ZStack {
                Color.fioriNextSecondaryGrey.opacity(0.24)
                VStack(spacing: 60) {
                    if let anchorImage = anchorImage {
                        Image(uiImage: anchorImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: vSizeClass == .compact ? 98 : 196)
                            .clipped()
                            .contentShape(Rectangle())
                            .padding(.top, 60)
                    }
                        
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
                    .padding(.bottom, 21)
                }
            }
            .cornerRadius(10)
        }
        .frame(height: vSizeClass == .compact ? 178 : 357)
        .padding(16)
    }
}
