//
//  SwiftUIView.swift
//
//
//  Created by Diaz, Ernesto on 9/17/21.
//

import SwiftUI

struct UploadAnchorImageTabView: View {
    @State private var selectedImage: UIImage?
    @State private var imageName: String?
    @State private var isImagePickerPresented = false
    @State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType?
//    var onAddAnchorImage: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 36) {
            if let _ = selectedImage {
                ImageAnchorView(selectedImage: $selectedImage, imageName: imageName ?? "")
                
            } else {
                VStack(spacing: 46) {
                    Text("The anchor is an image that the software can recognize to successfully place the markers in relation to the anchor. Make sure that the anchor image is scannable on the site of the experience.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 17))
                    Button(action: { showActionSheet.toggle() }, label: {
                        Text("Upload Anchor Image")
                            .font(.system(size: 15))
                            .bold()
                            .frame(width: 187, height: 40)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.fnBlue)
                            )
                    })
                }
                .padding(.top, 148)
                .padding(.horizontal, 32)
            }
        }
        .actionSheet(isPresented: $showActionSheet, content: { () -> ActionSheet in
            ActionSheet(title: Text("Select Image"), message: Text(""), buttons: [
                ActionSheet.Button.default(Text("Camera"), action: {
                    self.isImagePickerPresented.toggle()
                    self.sourceType = .camera
                    self.imageName = nil
                }),
                ActionSheet.Button.default(Text("Library"), action: {
                    self.isImagePickerPresented.toggle()
                    self.sourceType = .photoLibrary
                }),
                ActionSheet.Button.cancel()
            ])
        })
        .sheet(isPresented: self.$isImagePickerPresented) {
            CameraView(takenImage: self.$selectedImage, fileName: self.$imageName, sourceType: self.sourceType!)
        }
    }
}

struct ImageAnchorView: View {
    @Binding var selectedImage: UIImage?
    var imageName: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Image Anchor")
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .font(.system(size: 18))
                
                Spacer()
            }
            
            VStack(spacing: 29) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 343, height: 257)
                        .padding(.top, 32)
                }
            
                HStack {
                    Text(imageName)
                        .foregroundColor(Color.gray)
                    Spacer()
                    Button("Delete") {
                        selectedImage = nil
                    }
                    .foregroundColor(Color.black)
                }
                .font(.system(size: 13))
                .padding(.horizontal, 16)
                .padding(.bottom, 21)
            }
            .frame(width: 343, height: 357)
            .background(Color.imageGrey)
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
