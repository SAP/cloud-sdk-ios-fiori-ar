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
    
    var _onDismiss: (() -> Void)?
    
    init(anchorImage: Binding<UIImage?>, physicalWidth: Binding<String>, imageName: Binding<String?>, onDismiss: (() -> Void)? = nil) {
        _anchorImage = anchorImage
        _physicalWidth = physicalWidth
        _imageName = imageName
        _internalAnchorImage = State(initialValue: anchorImage.wrappedValue)
        _internalPhysicalWidth = State(initialValue: physicalWidth.wrappedValue)
        _internalImageName = State(initialValue: imageName.wrappedValue)
        self._onDismiss = onDismiss
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SheetHandle()
                
                HStack {
                    Text("Upload Image Anchor")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    ActionView(icon: Image(systemName: "xmark")) {
                        _onDismiss?()
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
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Please enter the real-world physical width of anchor image.")
                                .font(.system(size: 15))
                                .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                            Spacer()
                        }
                        .padding(.bottom, 16)
                        
                        TextDetail(textField: $internalPhysicalWidth, titleText: "Width", placeholder: "0.00 cm")
                            .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                            .keyboardType(.decimalPad)
                        
                        if !physicalWidthValidationText.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color.fioriNextNegativeLabel)
                                Text(physicalWidthValidationText)
                                    .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                                Spacer()
                            }
                            .font(.system(size: 13))
                            .padding(.top, 8)
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
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Please tap the area below to upload anchor image.")
                                .font(.system(size: 15))
                                .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                            Spacer()
                            if validatingAnchorImage {
                                ProgressView()
                            }
                        }
                        .padding(.bottom, 16)
                        
                        ImageSelectionView(detailImage: internalAnchorImage?.pngData(), imageHeight: 145, contentMode: .fit)
                            .onTapGesture {
                                actionSheetPresented.toggle()
                            }
                            
                        HStack {
                            if !imageValidationText.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(Color.fioriNextNegativeLabel)
                                    Text(imageValidationText)
                                        .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                                }
                                .font(.system(size: 13))
                            }
                            Spacer()
                            if internalAnchorImage != nil {
                                Button("Delete") {
                                    withAnimation {
                                        internalAnchorImage = nil
                                    }
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.black)
                            }
                        }
                        .padding(.top, 8)
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
                    if validateInput() {
                        validateAnchorImage(completionHandler: {
                            anchorImage = internalAnchorImage
                            physicalWidth = internalPhysicalWidth
                            imageName = internalImageName
                            _onDismiss?()
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
                    DispatchQueue.main.async {
                        completionHandler()
                    }
                } else {
                    self.imageValidationText = "Invalid Image"
                }
            }
        }
    }
}
