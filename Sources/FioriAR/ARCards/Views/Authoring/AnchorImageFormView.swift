//
//  AnchorImageFormView.swift
//
//
//  Created by O'Brien, Patrick on 10/25/21.
//

import ARKit
import SwiftUI

struct AnchorImageFormView: View {
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    @Binding var anchorImage: UIImage?
    @Binding var physicalWidth: String
    @Binding var imageName: String?
    
    @State private var internalAnchorImage: UIImage?
    @State private var internalPhysicalWidth: String
    @State private var internalImageName: String?
    
    @State private var actionSheetPresented = false
    @State private var pickerPresented = false
    @State private var pickerSource: ImagePickerSource = .photoLibrary
    
    @State private var physicalWidthValidationText = ""
    @State private var imageValidationText = ""
    @State private var validatingAnchorImage = false
    
    var _onDismiss: (() -> Void)?
    
    init(anchorImage: Binding<UIImage?>, physicalWidth: Binding<String>, imageName: Binding<String?>, onDismiss: (() -> Void)? = nil) {
        _anchorImage = anchorImage
        _physicalWidth = physicalWidth
        _imageName = imageName
        _internalAnchorImage = State(initialValue: anchorImage.wrappedValue)
        _internalPhysicalWidth = State(initialValue: physicalWidth.wrappedValue.isEmpty ? "" : String(format: "%.2f", (Double(physicalWidth.wrappedValue) ?? 0.1) * 100))
        _internalImageName = State(initialValue: imageName.wrappedValue)
        self._onDismiss = onDismiss
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SheetHandle()
                
                HStack {
                    Text("Upload Image Anchor", bundle: .fioriAR)
                        .font(.fiori(forTextStyle: .headline).weight(.bold))
                        .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                    
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
                        Text("Dimension", bundle: .fioriAR)
                            .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                            .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                        
                        Spacer()
                    }
                    .padding(.leading, 8)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Enter the width of the real-world image.", bundle: .fioriAR)
                                .font(.fiori(forTextStyle: .subheadline))
                                .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                            Spacer()
                        }
                        .padding(.bottom, 16)
                        
                        TextDetail(textField: $internalPhysicalWidth, titleText: "Width", placeholder: "0.00 cm", fontWeight: .regular)
                            .keyboardType(.decimalPad)
                        
                        if !physicalWidthValidationText.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.preferredColor(.negativeLabel, background: .lightConstant))
                                Text(physicalWidthValidationText)
                                    .font(.fiori(forTextStyle: .footnote))
                                    .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: 230)
                    .animation(.default, value: physicalWidthValidationText)
                    .background(Color.preferredColor(.primaryBackground, background: .lightConstant))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Image Anchor", bundle: .fioriAR)
                            .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                            .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                        
                        Spacer()
                    }
                    .padding(.leading, 8)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Tap the area below to upload the image anchor.", bundle: .fioriAR)
                                .font(.fiori(forTextStyle: .subheadline))
                                .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                            Spacer()
                            if validatingAnchorImage {
                                ProgressView()
                            }
                        }
                        .padding(.bottom, 16)
                        
                        ImageSelectionView(detailImage: CardImage(data: internalAnchorImage?.pngData()), imageHeight: 145, contentMode: .fit)
                            .onTapGesture {
                                actionSheetPresented.toggle()
                            }
                            
                        HStack {
                            if !imageValidationText.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.preferredColor(.negativeLabel))
                                    Text(imageValidationText)
                                        .font(.fiori(forTextStyle: .footnote))
                                        .foregroundColor(Color.preferredColor(.tertiaryLabel))
                                }
                            }
                            Spacer()
                            if internalAnchorImage != nil {
                                Button("Remove".localizedString) {
                                    withAnimation {
                                        internalAnchorImage = nil
                                    }
                                }
                                .font(.fiori(forTextStyle: .footnote).weight(.bold))
                                .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .animation(.default, value: imageValidationText)
                    .background(Color.preferredColor(.primaryBackground, background: .lightConstant))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                
                Button(action: {
                    if validateInput() {
                        validateAnchorImage(completionHandler: {
                            anchorImage = internalAnchorImage
                            physicalWidth = String(format: "%.4f", (Double(internalPhysicalWidth) ?? 0.1) / 100)
                            imageName = internalImageName
                            _onDismiss?()
                        })
                    }
                }, label: {
                    Text("Done", bundle: .fioriAR)
                        .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                        .foregroundColor(Color.preferredColor(.secondaryGroupedBackground, background: .lightConstant))
                        .frame(width: 343, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.preferredColor(.tintColor, background: .lightConstant))
                        )
                        .shadow(color: Color.preferredColor(.tintColor, background: .lightConstant).opacity(0.16), radius: 4, y: 2)
                        .shadow(color: Color.preferredColor(.tintColor, background: .lightConstant).opacity(0.16), radius: 2)
                })
                    .padding(.bottom, 32)
            }
            .padding(.leading, safeAreaInsets.leading)
            .padding(.trailing, safeAreaInsets.trailing)
        }
        .onTapGesture(perform: hideKeyboard)
        .background(Color.preferredColor(.primaryGroupedBackground, background: .lightConstant))
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.keyboard)
        .actionSheet(isPresented: $actionSheetPresented) {
            ActionSheet(title: Text("Choose an Option", bundle: .fioriAR),
                        message: nil,
                        buttons: [.default(Text("Camera", bundle: .fioriAR), action: {
                            pickerSource = .camera
                            pickerPresented.toggle()
                        }), .default(Text("Photos", bundle: .fioriAR), action: {
                            pickerSource = .photoLibrary
                            pickerPresented.toggle()
                        }), .cancel()])
        }
        .fullScreenCover(isPresented: $pickerPresented) {
            PickerSelectionView(uiImage: $internalAnchorImage, imageSource: pickerSource)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    func validateInput() -> Bool {
        self.imageValidationText = self.internalAnchorImage == nil ? "Please select image.".localizedString : ""
        self.physicalWidthValidationText = self.internalPhysicalWidth.isEmpty ? "Please input a physical width.".localizedString : Double(self.internalPhysicalWidth) == nil ? "Please input a numeric value.".localizedString : ""
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
                    self.imageValidationText = "Upload higher-quality image.".localizedString
                }
            }
        }
    }
}
