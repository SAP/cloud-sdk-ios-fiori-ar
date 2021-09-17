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
            if selectedImage != nil{
                ImageAnchorView(selectedImage: self.$selectedImage, imageName: self.$imageName)
            } else {
                Text("The anchor is an image that the software can recognize to successfully place the markers in relation to the anchor. Make sure that the anchor image is scannable on the site of the experience.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17))
                    .padding(.horizontal, 46)
                Button(action: { showActionSheet.toggle() }, label: {
                    Text("Upload Anchor Image")
                        .font(.system(size: 15))
                        .bold()
                        .frame(width: 187, height: 40)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.sapBlue)
                        )
                })
            }
        }.padding(.top, 148)
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
    @Binding var imageName: String?
    
    
    var body: some View{
        if selectedImage != nil {
            HStack {
                Text("Anchor Image")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.sRGB, red: 0.13, green: 0.21, blue: 0.28, opacity: 1.0))
//                    .frame(width: 99, height: 20, alignment: .center)
                Image(systemName: "info.circle")
                    .frame(width: 15, height: 15, alignment: .center)
            }
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.sRGB, red: 0.36, green: 0.45, blue: 0.55, opacity: 0.24))
                VStack {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio(CGSize(width: 343, height: 257), contentMode: .fit)
                        .border(.black, width: 1)
                    HStack{
                        Text(imageName ?? "") //find way to get this
                            .foregroundColor(Color(.sRGB, red: 0.28, green: 0.37, blue: 0.46, opacity: 0.9))
                        Spacer()
                        Button("Delete") {
                            self.selectedImage = nil
                        }
                    }
                    .padding()
                }
            }
            .frame(width: 343, height: 357)
        }
    }
}
