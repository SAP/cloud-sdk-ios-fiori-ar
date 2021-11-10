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
    @Environment(\.presentationMode) var isPresented
    
    @Binding var image: Image?
    @Binding var uiImage: UIImage?
    @Binding var imageData: Data?
    @Binding var fileName: String?
    
    var sourceType: UIImagePickerController.SourceType
    
    init(image: Binding<Image?> = .constant(nil),
         uiImage: Binding<UIImage?> = .constant(nil),
         imageData: Binding<Data?> = .constant(nil),
         fileName: Binding<String?> = .constant(nil),
         sourceType: UIImagePickerController.SourceType)
    {
        self._image = image
        self._uiImage = uiImage
        self._imageData = imageData
        self._fileName = fileName
        self.sourceType = sourceType
    }
    
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
        let uiImage = pickedImage.size.height * pickedImage.scale > 2000 ? resized : pickedImage
        self.picker.uiImage = uiImage
        self.picker.image = Image(uiImage: uiImage)
        self.picker.imageData = uiImage.pngData()
        
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
