//
//  ImagePickerView.swift
//
//
//  Created by Diaz, Ernesto on 9/17/21.
//

import PhotosUI
import SwiftUI
import UIKit

struct ImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var isPresented
    
    @Binding var uiImage: UIImage?
    
    init(uiImage: Binding<UIImage?>) {
        self._uiImage = uiImage
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(imagePicker: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = context.coordinator

        return imagePicker
    }
    
    func updateUIViewController(_ imagePicker: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        var imagePicker: ImagePickerView
        
        init(imagePicker: ImagePickerView) {
            self.imagePicker = imagePicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    // Large images causes unexpected layout issues in SwiftUI
                    if let pickedImage = object as? UIImage,
                       let resizedImage = (pickedImage.size.height * pickedImage.scale) > 2000 ? pickedImage.resize(to: 0.5) : pickedImage
                    {
                        self.imagePicker.uiImage = resizedImage
                    }
                }
            }
            self.imagePicker.isPresented.wrappedValue.dismiss()
        }
    }

    typealias UIViewControllerType = PHPickerViewController
}
