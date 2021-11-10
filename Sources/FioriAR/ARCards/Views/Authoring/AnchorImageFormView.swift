//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 10/25/21.
//

import ARKit
import SwiftUI

struct AnchorImageFormView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @Binding var anchorImage: UIImage?
    @Binding var physicalWidth: String
    @Binding var imageName: String?
    
    @State private var internalAnchorImage: UIImage?
    @State private var internalPhysicalWidth: String = ""
    @State private var internalImageName: String?
    
    @State private var actionSheetPresented = false
    @State private var pickerPresented = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var physicalWidthValidationText = ""
    @State private var imageValidationText = ""
    @State private var validatingAnchorImage = false
    
    var onDismiss: (() -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SheetHandle()
                
                HStack {
                    Text("Upload Image Anchor")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    DismissView {
                        onDismiss?()
                    }
                }
                .padding(.top, 11)
                .padding(.horizontal, 16)
                .padding(.bottom, 27)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Dimension")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                        
                        Spacer()
                    }
                    .padding(.leading, 8)
                    
                    VStack(spacing: 20) {
                        HStack {
                            Text("Please enter the real-world physical width of anchor image.")
                                .font(.system(size: 15))
                                .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                            Spacer()
                        }
                        
                        TextDetail(textField: $internalPhysicalWidth, titleText: "Width", placeholder: "0.00 cm")
                            .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                            .keyboardType(.decimalPad)
                        
                        if !physicalWidthValidationText.isEmpty {
                            HStack {
                                Text(physicalWidthValidationText)
                                    .font(.system(size: 15))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: 230)
                    .animation(.default, value: physicalWidthValidationText)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Anchor Image")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                        
                        Spacer()
                    }
                    .padding(.leading, 8)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Please tap the area below to upload anchor image.")
                                .font(.system(size: 15))
                                .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                            Spacer()
                            if validatingAnchorImage {
                                ProgressView()
                            }
                        }
                        
                        ImageSelectionView(detailImage: internalAnchorImage?.pngData(), imageHeight: 145)
                            .onTapGesture {
                                actionSheetPresented.toggle()
                            }
                        if !imageValidationText.isEmpty {
                            HStack {
                                Text(imageValidationText)
                                    .font(.system(size: 15))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .animation(.default, value: imageValidationText)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                
                Button(action: {
                    // Validate Image is selected and Physical Width is valid
                    if validateInput() {
                        validateAnchorImage(completionHandler: {
                            anchorImage = internalAnchorImage
                            physicalWidth = internalPhysicalWidth
                            imageName = internalImageName
                            onDismiss?()
                        })
                    }
                }, label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 343, height: 40)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.fioriNextTint)
                        )
                        .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 4, y: 2)
                        .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 2)
                })
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, verticalSizeClass == .compact ? 40 : 0)
        }
        .onTapGesture(perform: hideKeyboard)
        .background(Color.fioriNextPrimaryBackground)
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.keyboard)
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
            ImagePickerView(uiImage: $internalAnchorImage, fileName: $internalImageName, sourceType: pickerSource)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    func validateInput() -> Bool {
        self.imageValidationText = self.internalAnchorImage == nil ? "Please Select Image" : ""
        self.physicalWidthValidationText = self.internalPhysicalWidth.isEmpty ? "Please input a physical Width" : Double(self.internalPhysicalWidth) == nil ? "Please input a Numeric Value" : ""

        return self.imageValidationText.isEmpty && self.physicalWidthValidationText.isEmpty
    }

    func validateAnchorImage(completionHandler: @escaping (() -> Void)) {
        self.validatingAnchorImage = true
    
        if let anchorImage = internalAnchorImage,
           let cgImage = anchorImage.cgImage,
           let castedWidth = Double(internalPhysicalWidth)
        {
            let arImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: CGFloat(castedWidth) / 100)
            arImage.validate { error in
                self.validatingAnchorImage = false
                if error == nil {
                    completionHandler()
                } else {
                    self.imageValidationText = "Invalid Image"
                }
            }
        }
    }
}
