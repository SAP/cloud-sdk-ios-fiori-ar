//
//  ImagePickerView.swift
//
//
//  Created by Diaz, Ernesto on 9/17/21.
//

import Photos
import SwiftUI
import UIKit

struct ImageCameraPickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var isPresented
    
    @Binding var uiImage: UIImage?
    
    init(uiImage: Binding<UIImage?>) {
        self._uiImage = uiImage
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(imagePicker: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.delegate = context.coordinator
        return cameraPicker
    }
    
    func updateUIViewController(_ picker: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var imagePicker: ImageCameraPickerView
        
        init(imagePicker: ImageCameraPickerView) {
            self.imagePicker = imagePicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let cameraImage = info[.originalImage] as? UIImage, let rotatedImage = cameraImage.resize(to: 1) {
                self.imagePicker.uiImage = rotatedImage
            }
            self.imagePicker.isPresented.wrappedValue.dismiss()
        }
    }

    typealias UIViewControllerType = UIImagePickerController
}
