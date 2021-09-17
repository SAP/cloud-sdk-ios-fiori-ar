//
//  SwiftUIView.swift
//
//
//  Created by Diaz, Ernesto on 9/17/21.
//

import UIKit
import Photos
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    
    @Binding var takenImage: UIImage?
    @Binding var fileName: String?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: CameraView
    
    init(picker: CameraView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Gets file name if image is from photo library
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let assetResources = PHAssetResource.assetResources(for: asset)
            self.picker.fileName = assetResources.first!.originalFilename
        }
        
        guard let takenImage = info[.originalImage] as? UIImage else { return }
        self.picker.takenImage = takenImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
}
