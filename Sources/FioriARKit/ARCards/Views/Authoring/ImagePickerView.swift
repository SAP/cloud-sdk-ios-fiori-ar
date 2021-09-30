//
//  ImagePickerView.swift
//
//
//  Created by Diaz, Ernesto on 9/17/21.
//

import Photos
import SwiftUI
import UIKit

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var takenImage: Image?
    @Binding var fileName: String?
    
    @Environment(\.presentationMode) var isPresented
    
    var sourceType: UIImagePickerController.SourceType
    
    func makeCoordinator() -> Coordinator {
        Coordinator(picker: self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage,
              let resized = pickedImage.resize(to: 0.50) else { return }
        // Large images causes unexpected layout issues in SwiftUI
        self.picker.takenImage = Image(uiImage: pickedImage.size.height * pickedImage.scale > 2000 ? resized : pickedImage)
        self.picker.isPresented.wrappedValue.dismiss()
    }
}

private extension UIImage {
    func resize(to percent: CGFloat) -> UIImage? {
        let newSize = CGSize(width: self.size.width * percent, height: self.size.height * percent)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}